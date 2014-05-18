library leaflet.map;

import 'dart:html';
import 'dart:math' as math;

import '../core/core.dart' as core;
import '../core/core.dart' show EventType;
import '../geo/geo.dart';
import '../geo/crs/crs.dart';
import '../geometry/geometry.dart' as geom;
import '../layer/layer.dart';
import '../layer/tile/tile.dart';

part 'options.dart';

final containerProp = new Expando<Element>('_leaflet');

class BaseMap extends Object with core.Events {
  /*Map<String, Object> options = {
    'crs': crs.EPSG3857,
    'fadeAnimation': DomUtil.TRANSITION && !Browser.android23,
    'trackResize': true,
    'markerZoomAnimation': DomUtil.TRANSITION && Browser.any3d
  };*/
  MapStateOptions stateOptions;
  InteractionOptions interactionOptions;
  KeyboardNavigationOptions keyboardNavigationOptions;
  PanningInertiaOptions panningInertiaOptions;
  ControlOptions controlOptions;
  AnimationOptions animationOptions;
  LocateOptions locateOptions;
  ZoomPanOptions zoomPanOptions;

  List _handlers;

  Map _layers;
  Map _zoomBoundLayers;
  int _tileLayersNum, _tileLayersToLoad;

  factory BaseMap.elem(Element id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }

  factory BaseMap.id(String id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }

  BaseMap(var id, {MapStateOptions stateOptions: null, InteractionOptions interactionOptions: null,
      KeyboardNavigationOptions keyboardNavigationOptions: null, PanningInertiaOptions panningInertiaOptions: null,
      ControlOptions controlOptions: null, AnimationOptions animationOptions: null, LocateOptions locateOptions: null,
      ZoomPanOptions zoomPanOptions: null}) {
    if (stateOptions == null) {
      stateOptions = new MapStateOptions();
    }
    this.stateOptions = stateOptions;
    if (interactionOptions == null) {
      interactionOptions = new InteractionOptions();
    }
    this.interactionOptions = interactionOptions;
    if (keyboardNavigationOptions == null) {
      keyboardNavigationOptions = new KeyboardNavigationOptions();
    }
    this.keyboardNavigationOptions = keyboardNavigationOptions;
    if (panningInertiaOptions == null) {
      panningInertiaOptions = new PanningInertiaOptions();
    }
    this.panningInertiaOptions = panningInertiaOptions;
    if (controlOptions == null) {
      controlOptions = new ControlOptions();
    }
    this.controlOptions = controlOptions;
    if (animationOptions == null) {
      animationOptions = new AnimationOptions();
    }
    this.animationOptions = animationOptions;
    if (locateOptions == null) {
      locateOptions = new LocateOptions();
    }
    this.locateOptions = locateOptions;
    if (zoomPanOptions == null) {
      zoomPanOptions = new ZoomPanOptions();
    }
    this.zoomPanOptions = zoomPanOptions;


    this._initContainer(id);
    this._initLayout();

    // hack for https://github.com/Leaflet/Leaflet/issues/1980
//    this._onResize = L.bind(this._onResize, this);

    this._initEvents();

    if (stateOptions.maxBounds != null) {
      this.setMaxBounds(stateOptions.maxBounds);
    }

    if (stateOptions.center != null && zoomPanOptions.zoom != null) {
      this.setView(new LatLng.latLng(stateOptions.center), zoomPanOptions.zoom, new ZoomPanOptions(reset: true));
    }

    this._handlers = [];

    this._layers = {};
    this._zoomBoundLayers = {};
    this._tileLayersNum = 0;

    this.callInitHooks();

    this._addLayers(stateOptions.layers);
  }


  // public methods that modify map state

  // Sets the view of the map (geographical center and zoom) with the given
  // animation options.
  //
  // Replaced by animation-powered implementation in Map.PanAnimation
  setView(LatLng center, num zoom, [ZoomPanOptions options = null]) {
    zoom = zoom == null ? this.getZoom() : zoom;
    this._resetView(new LatLng.latLng(center), this._limitZoom(zoom));
  }

  num _zoom;
  bool _loaded;

  // Sets the zoom of the map.
  setZoom(num zoom, [ZoomOptions options=null]) {
    if (!this._loaded) {
      this._zoom = this._limitZoom(zoom);
      return;
    }
    this.setView(this.getCenter(), zoom, new ZoomPanOptions(zoom: options));
  }

  // Increases the zoom of the map by delta (1 by default).
  zoomIn([num delta = 1, ZoomOptions options = null]) {
    return this.setZoom(this._zoom + delta, options);
  }

  // Decreases the zoom of the map by delta (1 by default).
  zoomOut([num delta = 1, ZoomOptions options = null]) {
    return this.setZoom(this._zoom - delta, options);
  }

  // Zooms the map while keeping a specified point on the map stationary (e.g. used internally for scroll zoom and double-click zoom).
  setZoomAroundLatLng(LatLng latlng, num zoom, [ZoomOptions options = null]) {
    setZoomAround(latLngToContainerPoint(latlng), zoom, options);
  }

  // Zooms the map while keeping a specified point on the map stationary (e.g. used internally for scroll zoom and double-click zoom).
  setZoomAround(geom.Point containerPoint, num zoom, [ZoomOptions options = null]) {
    final scale = this.getZoomScale(zoom),
        viewHalf = this.getSize().divideBy(2),

        centerOffset = containerPoint.subtract(viewHalf).multiplyBy(1 - 1 / scale),
        newCenter = this.containerPointToLatLng(viewHalf.add(centerOffset));

    this.setView(newCenter, zoom, new ZoomPanOptions(zoom: options));
  }

  // Sets a map view that contains the given geographical bounds with the maximum zoom level possible.
  fitBounds(LatLngBounds bounds, [ZoomPanOptions options = null]) {
    if (options == null) {
      options = new ZoomPanOptions();
    }
//    bounds = bounds.getBounds ? bounds.getBounds() : new LatLngBounds.latLngBounds(bounds);

    geom.Point paddingTL;
    if (options.paddingTopLeft != null) {
      paddingTL = new geom.Point.point(options.paddingTopLeft);
    } else if (options.padding != null) {
      paddingTL = new geom.Point.point(options.padding);
    } else {
      paddingTL = new geom.Point(0, 0);
    }
    geom.Point paddingBR;
    if (options.paddingTopLeft != null) {
      paddingBR = new geom.Point.point(options.paddingBottomRight);
    } else if (options.padding != null) {
      paddingBR = new geom.Point.point(options.padding);
    } else {
      paddingBR = new geom.Point(0, 0);
    }

    var zoom = this.getBoundsZoom(bounds, false, paddingTL.add(paddingBR));
    final paddingOffset = paddingBR.subtract(paddingTL).divideBy(2),

        swPoint = this.project(bounds.getSouthWest(), zoom),
        nePoint = this.project(bounds.getNorthEast(), zoom),
        center = this.unproject(swPoint.add(nePoint).divideBy(2).add(paddingOffset), zoom);

    if (options != null && options.maxZoom != null) {
      zoom = math.min(options.maxZoom, zoom);
    }

    return this.setView(center, zoom, options);
  }

  // Sets a map view that mostly contains the whole world with the maximum zoom level possible.
  void fitWorld([ZoomPanOptions options = null]) {
    this.fitBounds(new LatLngBounds.array([[-90, -180], [90, 180]]), options);
  }

  // Pans the map to a given center. Makes an animated pan if new center is not more than one screen away from the current one.
  void panTo(LatLng center, [PanOptions options = null]) { // (LatLng)
    this.setView(center, this._zoom, new ZoomPanOptions(pan: options));
  }

  // Pans the map by a given number of pixels (animated).
  void panBy(geom.Point offset) {
    // replaced with animated panBy in Map.PanAnimation.js
    this.fire(EventType.MOVESTART);

    this._rawPanBy(new geom.Point.point(offset));

    this.fire(EventType.MOVE);
    this.fire(EventType.MOVEEND);
  }

  // Restricts the map view to the given bounds (see map maxBounds option).
  setMaxBounds(LatLngBounds bounds) {
    bounds = new LatLngBounds.latLngBounds(bounds);

    this.stateOptions.maxBounds = bounds;

    if (bounds == null) {
      return this.off(EventType.MOVEEND, this._panInsideMaxBounds, this);
    }

    if (this._loaded) {
      this._panInsideMaxBounds();
    }

    return this.on(EventType.MOVEEND, this._panInsideMaxBounds, this);
  }

  // Pans the map to the closest view that would lie inside the given bounds
  // (if it's not already), controlling the animation using the options
  // specific, if any.
  void panInsideBounds(LatLngBounds bounds, [PanOptions options = null]) {
    var center = this.getCenter(),
      newCenter = this._limitCenter(center, this._zoom, bounds);

    if (center.equals(newCenter)) { return; }

    this.panTo(newCenter, options);
  }

  // Adds the given layer to the map. If optional insertAtTheBottom is set to
  // true, the layer is inserted under all others (useful when switching base
  // tile layers).
  void addLayer(Layer layer) {
    // TODO method is too big, refactor

    var id = core.Util.stamp(layer);

    if (this._layers[id]) { return; }

    this._layers[id] = layer;

    // TODO getMaxZoom, getMinZoom in ILayer (instead of options)
    if (layer is TileLayer) {
      if (!layer.options.maxZoom.isNaN || !layer.options.minZoom.isNaN) {
        this._zoomBoundLayers[id] = layer;
        this._updateZoomLevels();
      }
    }

    // TODO looks ugly, refactor!!!
    if (this.animationOptions.zoomAnimation && layer is TileLayer) {
      this._tileLayersNum++;
      this._tileLayersToLoad++;
      layer.on(EventType.LOAD, this._onTileLayerLoad, this);
    }

    if (this._loaded) {
      this._layerAdd(layer);
    }

    return;
  }

  // Removes the given layer from the map.
  void removeLayer(Layer layer) {
    var id = core.Util.stamp(layer);

    if (!this._layers[id]) { return; }

    if (this._loaded) {
      layer.onRemove(this);
    }

    this._layers.remove(id);

    if (this._loaded) {
      this.fire('layerremove', {layer: layer});
    }

    if (this._zoomBoundLayers.containsKey(id)) {
      this._zoomBoundLayers.remove(id);
      this._updateZoomLevels();
    }

    // TODO looks ugly, refactor
    if (this.animationOptions.zoomAnimation && layer is TileLayer) {
      this._tileLayersNum--;
      this._tileLayersToLoad--;
      layer.off('load', this._onTileLayerLoad, this);
    }

    return;
  }

  // Returns true if the given layer is currently added to the map.
  bool hasLayer(Layer layer) {
    if (layer == null) { return false; }

    return this._layers.containsKey(core.Util.stamp(layer));
  }

  /*eachLayer(method, context) {
    for (var i in this._layers) {
      method.call(context, this._layers[i]);
    }
    return this;
  }*/

  bool _sizeChanged;
  LatLng _initialCenter;

  // Checks if the map container size changed and updates the map if so — call
  // it after you've changed the map size dynamically, also animating pan by
  // default. If options.pan is false, panning will not occur. If
  // options.debounceMoveend is true, it will delay moveend event so that it
  // doesn't happen often even if the method is called many times in a row.
  void invalidateSize(bool animate, [bool pan=true, bool debounceMoveend=false]) {
    if (!this._loaded) { return; }

    /*options = L.extend({
      animate: false,
      pan: true
    }, options == true ? {animate: true} : options);*/

    var oldSize = this.getSize();
    this._sizeChanged = true;
    this._initialCenter = null;

    var newSize = this.getSize(),
        oldCenter = oldSize.divideBy(2).round(),
        newCenter = newSize.divideBy(2).round(),
        offset = oldCenter.subtract(newCenter);

    if (!offset.x && !offset.y) { return; }

    if (animate && pan) {
      this.panBy(offset);

    } else {
      if (pan) {
        this._rawPanBy(offset);
      }

      this.fire('move');

      if (debounceMoveend) {
        clearTimeout(this._sizeTimer);
        this._sizeTimer = setTimeout(bind(this.fire, this, EventType.MOVEEND), 200);
      } else {
        this.fire(EventType.MOVEEND);
      }
    }

    this.fire(EventType.RESIZE, {
      'oldSize': oldSize,
      'newSize': newSize
    });
  }

  // TODO handler.addTo
  /*addHandler(name, HandlerClass) {
    if (!HandlerClass) { return this; }

    var handler = this[name] = new HandlerClass(this);

    this._handlers.push(handler);

    if (this.options[name]) {
      handler.enable();
    }

    return this;
  }*/

  // Destroys the map and clears all related event listeners.
  remove() {
    if (this._loaded) {
      this.fire(EventType.UNLOAD);
    }

    this._initEvents(false);

    /*try {
      // throws error in IE6-8
      delete(this._container._leaflet);
    } catch (e) {
      this._container._leaflet = undefined;
    }*/
    containerProp[_container] = null;

    this._clearPanes();
    if (this._clearControlPos) {
      this._clearControlPos();
    }

    this._clearHandlers();

    return this;
  }


  // public methods for getting map state

  // Returns the geographical center of the map view.
  LatLng getCenter() {
    this._checkIfLoaded();

    if (this._initialCenter && !this._moved()) {
      return this._initialCenter;
    }
    return this.layerPointToLatLng(this._getCenterLayerPoint());
  }

  // Returns the current zoom of the map view.
  num getZoom() {
    return this._zoom;
  }

  // Returns the LatLngBounds of the current map view.
  LatLngBounds getBounds() {
    final bounds = this.getPixelBounds(),
        sw = this.unproject(bounds.getBottomLeft()),
        ne = this.unproject(bounds.getTopRight());

    return new LatLngBounds(sw, ne);
  }

  // Returns the minimum zoom level of the map.
  num getMinZoom() {
    return this.stateOptions.minZoom == null ?
      (this._layersMinZoom == null ? 0 : this._layersMinZoom) :
      this.stateOptions.minZoom;
  }

  // Returns the maximum zoom level of the map.
  num getMaxZoom() {
    return this.stateOptions.maxZoom == null ?
      (this._layersMaxZoom == null ? double.INFINITY : this._layersMaxZoom) :
      this.stateOptions.maxZoom;
  }

  // Returns the maximum zoom level on which the given bounds fit to the map
  // view in its entirety. If inside (optional) is set to true, the method
  // instead returns the minimum zoom level on which the map view fits into
  // the given bounds in its entirety.
  num getBoundsZoom(LatLngBounds bounds, [bool inside = false, geom.Point padding = null]) {
    if (padding == null) {
      padding = new geom.Point(0, 0);
    }
    bounds = new LatLngBounds.latLngBounds(bounds);

    num zoom = this.getMinZoom() - (inside ? 1 : 0);
    final maxZoom = this.getMaxZoom(),
        size = this.getSize(),

        nw = bounds.getNorthWest(),
        se = bounds.getSouthEast();

    bool zoomNotFound = true;
    var boundsSize;

    padding = new Point.point(padding);

    do {
      zoom++;
      boundsSize = this.project(se, zoom).subtract(this.project(nw, zoom)).add(padding);
      zoomNotFound = !inside ? size.contains(boundsSize) : boundsSize.x < size.x || boundsSize.y < size.y;

    } while (zoomNotFound && zoom <= maxZoom);

    if (zoomNotFound && inside) {
      return null;
    }

    return inside ? zoom : zoom - 1;
  }

  geom.Point _size;

  // Returns the current size of the map container.
  geom.Point getSize() {
    if (this._size == null || this._sizeChanged) {
      this._size = new geom.Point(
        this._container.clientWidth,
        this._container.clientHeight);

      this._sizeChanged = false;
    }
    return this._size.clone();
  }

  // Returns the bounds of the current map view in projected pixel coordinates
  // (sometimes useful in layer and overlay implementations).
  Bounds getPixelBounds() {
    var topLeftPoint = this._getTopLeftPoint();
    return new Bounds(topLeftPoint, topLeftPoint.add(this.getSize()));
  }

  geom.Point _initialTopLeftPoint;

  // Returns the projected pixel coordinates of the top left point of the map
  // layer (useful in custom layer and overlay implementations).
  geom.Point getPixelOrigin() {
    this._checkIfLoaded();
    return this._initialTopLeftPoint;
  }

  // Returns an object with different map panes (to render overlays in).
  Map<String, Element> get panes => new Map.from(_panes);

  // Returns the container element of the map.
  Element getContainer() {
    return this._container;
  }


  // TODO replace with universal implementation after refactoring projections

  getZoomScale(toZoom) {
    var crs = this.options.crs;
    return crs.scale(toZoom) / crs.scale(this._zoom);
  }

  getScaleZoom(scale) {
    return this._zoom + (Math.log(scale) / Math.LN2);
  }


  // conversion methods

  project(latlng, [zoom=null]) { // (LatLng[, Number]) -> Point
    zoom = zoom == null ? this._zoom : zoom;
    return this.options.crs.latLngToPoint(L.latLng(latlng), zoom);
  }

  unproject(point, [zoom=null]) { // (Point[, Number]) -> LatLng
    zoom = zoom == null ? this._zoom : zoom;
    return this.options.crs.pointToLatLng(L.point(point), zoom);
  }

  layerPointToLatLng(point) { // (Point)
    var projectedPoint = L.point(point).add(this.getPixelOrigin());
    return this.unproject(projectedPoint);
  }

  latLngToLayerPoint(latlng) { // (LatLng)
    var projectedPoint = this.project(L.latLng(latlng))._round();
    return projectedPoint._subtract(this.getPixelOrigin());
  }

  containerPointToLayerPoint(point) { // (Point)
    return L.point(point).subtract(this._getMapPanePos());
  }

  layerPointToContainerPoint(point) { // (Point)
    return L.point(point).add(this._getMapPanePos());
  }

  containerPointToLatLng(point) {
    var layerPoint = this.containerPointToLayerPoint(L.point(point));
    return this.layerPointToLatLng(layerPoint);
  }

  latLngToContainerPoint(latlng) {
    return this.layerPointToContainerPoint(this.latLngToLayerPoint(L.latLng(latlng)));
  }

  mouseEventToContainerPoint(e) { // (MouseEvent)
    return L.DomEvent.getMousePosition(e, this._container);
  }

  mouseEventToLayerPoint(e) { // (MouseEvent)
    return this.containerPointToLayerPoint(this.mouseEventToContainerPoint(e));
  }

  mouseEventToLatLng(e) { // (MouseEvent)
    return this.layerPointToLatLng(this.mouseEventToLayerPoint(e));
  }


  // map initialization methods

  Element _container;

  _initContainerID(String id) {
    final container = DomUtil.get(id);
    if (container == null) {
      throw new Exception('Map container not found.');
    }
    _initContainer(container);
  }

  _initContainer(Element container) {
    this._container = container;

    if (containerProp[container] != null) {
      throw new Exception('Map container is already initialized.');
    }

    containerProp[container] = true;
  }

  _initLayout() {
    var container = this._container;

    DomUtil.addClass(container, 'leaflet-container' +
      (core.Browser.touch ? ' leaflet-touch' : '') +
      (core.Browser.retina ? ' leaflet-retina' : '') +
      (core.Browser.ielt9 ? ' leaflet-oldie' : '') +
      (this.animationOptions.fadeAnimation ? ' leaflet-fade-anim' : ''));

    var position = DomUtil.getStyle(container, 'position');

    if (position != 'absolute' && position != 'relative' && position != 'fixed') {
      container.style.position = 'relative';
    }

    this._initPanes();

    if (this._initControlPos) {
      this._initControlPos();
    }
  }

  Map<String, Element> _panes;
  var _mapPane, _tilePane;

  _initPanes() {
    var panes = this._panes = {};

    this._mapPane = panes['mapPane'] = this._createPane('leaflet-map-pane', this._container);

    this._tilePane = panes['tilePane'] = this._createPane('leaflet-tile-pane', this._mapPane);
    panes['objectsPane'] = this._createPane('leaflet-objects-pane', this._mapPane);
    panes['shadowPane'] = this._createPane('leaflet-shadow-pane');
    panes['overlayPane'] = this._createPane('leaflet-overlay-pane');
    panes['markerPane'] = this._createPane('leaflet-marker-pane');
    panes['popupPane'] = this._createPane('leaflet-popup-pane');

    var zoomHide = ' leaflet-zoom-hide';

    if (!this.options['markerZoomAnimation']) {
      dom.DomUtil.addClass(panes['markerPane'], zoomHide);
      dom.DomUtil.addClass(panes['shadowPane'], zoomHide);
      dom.DomUtil.addClass(panes['popupPane'], zoomHide);
    }
  }

  _createPane(String className, [var container=null]) {
    return dom.DomUtil.create('div', className, container != null ? container : this._panes['objectsPane']);
  }

  _clearPanes() {
    this._container.removeChild(this._mapPane);
  }

  _addLayers([var layers=null]) {
    layers = layers ? (layers is List ? layers : [layers]) : [];

    for (var i = 0, len = layers.length; i < len; i++) {
      this.addLayer(layers[i]);
    }
  }


  // private methods that modify map state

  _resetView(center, zoom, [preserveMapOffset=false, afterZoomAnim=false]) {

    var zoomChanged = (this._zoom != zoom);

    if (!afterZoomAnim) {
      this.fire('movestart');

      if (zoomChanged) {
        this.fire('zoomstart');
      }
    }

    this._zoom = zoom;
    this._initialCenter = center;

    this._initialTopLeftPoint = this._getNewTopLeftPoint(center);

    if (!preserveMapOffset) {
      L.DomUtil.setPosition(this._mapPane, new L.geom.Point(0, 0));
    } else {
      this._initialTopLeftPoint._add(this._getMapPanePos());
    }

    this._tileLayersToLoad = this._tileLayersNum;

    var loading = !this._loaded;
    this._loaded = true;

    if (loading) {
      this.fire('load');
      this.eachLayer(this._layerAdd, this);
    }

    this.fire('viewreset', {hard: !preserveMapOffset});

    this.fire('move');

    if (zoomChanged || afterZoomAnim) {
      this.fire('zoomend');
    }

    this.fire('moveend', {hard: !preserveMapOffset});
  }

  _rawPanBy(offset) {
    L.DomUtil.setPosition(this._mapPane, this._getMapPanePos().subtract(offset));
  }

  _getZoomSpan() {
    return this.getMaxZoom() - this.getMinZoom();
  }

  _updateZoomLevels() {
    var i,
      minZoom = Infinity,
      maxZoom = -Infinity,
      oldZoomSpan = this._getZoomSpan();

    for (i in this._zoomBoundLayers) {
      var layer = this._zoomBoundLayers[i];
      if (!isNaN(layer.options.minZoom)) {
        minZoom = Math.min(minZoom, layer.options.minZoom);
      }
      if (!isNaN(layer.options.maxZoom)) {
        maxZoom = Math.max(maxZoom, layer.options.maxZoom);
      }
    }

    if (i == null) { // we have no tilelayers
      this._layersMaxZoom = this._layersMinZoom = undefined;
    } else {
      this._layersMaxZoom = maxZoom;
      this._layersMinZoom = minZoom;
    }

    if (oldZoomSpan != this._getZoomSpan()) {
      this.fire('zoomlevelschange');
    }
  }

  bool _panInsideMaxBounds([Object obj=null, core.Event event=null]) {
    this.panInsideBounds(this.stateOptions.maxBounds);
  }

  _checkIfLoaded() {
    if (!this._loaded) {
      throw new Error('Set map center and zoom first.');
    }
  }

  // map events

  _initEvents([bool on = true]) {
    if (dom.DomEvent == null) { return; }

    if (on) {
      dom.DomEvent.on(this._container, 'click', this._onMouseClick, this);
    } else {
      dom.DomEvent.off(this._container, 'click', this._onMouseClick, this);
    }

    var events = ['dblclick', 'mousedown', 'mouseup', 'mouseenter',
                  'mouseleave', 'mousemove', 'contextmenu'],
        i, len;

    len = events.length;
    for (i = 0; i < len; i++) {
      if (on) {
        DomEvent.on(this._container, events[i], this._fireMouseEvent, this);
      } else {
        DomEvent.off(this._container, events[i], this._fireMouseEvent, this);
      }
    }

    if (this.interactionOptions.trackResize) {
      if (on) {
        DomEvent.on(window, 'resize', this._onResize, this);
      } else {
        DomEvent.off(window, 'resize', this._onResize, this);
      }
    }
  }

  _onResize() {
    L.Util.cancelAnimFrame(this._resizeRequest);
    this._resizeRequest = L.Util.requestAnimFrame(
            () { this.invalidateSize({'debounceMoveend': true}); }, this, false, this._container);
  }

  _onMouseClick(e) {
    if (!this._loaded || (!e._simulated &&
            ((this.dragging && this.dragging.moved()) ||
             (this.boxZoom  && this.boxZoom.moved()))) ||
                L.DomEvent._skipped(e)) { return; }

    this.fire('preclick');
    this._fireMouseEvent(e);
  }

  _fireMouseEvent(e) {
    if (!this._loaded || L.DomEvent._skipped(e)) { return; }

    var type = e.type;

    type = (type == 'mouseenter' ? 'mouseover' : (type == 'mouseleave' ? 'mouseout' : type));

    if (!this.hasEventListeners(type)) { return; }

    if (type == 'contextmenu') {
      L.DomEvent.preventDefault(e);
    }

    var containerPoint = this.mouseEventToContainerPoint(e),
        layerPoint = this.containerPointToLayerPoint(containerPoint),
        latlng = this.layerPointToLatLng(layerPoint);

    this.fire(type, {
      latlng: latlng,
      layerPoint: layerPoint,
      containerPoint: containerPoint,
      originalEvent: e
    });
  }

  _onTileLayerLoad([Object obj=null, core.Event event=null]) {
    this._tileLayersToLoad--;
    if (this._tileLayersNum && !this._tileLayersToLoad) {
      this.fire('tilelayersload');
    }
  }

  _clearHandlers() {
    for (var i = 0, len = this._handlers.length; i < len; i++) {
      this._handlers[i].disable();
    }
  }

  whenReady(callback, context) {
    if (this._loaded) {
      callback.call(context || this, this);
    } else {
      this.on('load', callback, context);
    }
    return this;
  }

  _layerAdd(layer) {
    layer.onAdd(this);
    this.fire('layeradd', {layer: layer});
  }


  // private methods for getting map state

  _getMapPanePos() {
    return L.DomUtil.getPosition(this._mapPane);
  }

  _moved() {
    var pos = this._getMapPanePos();
    return pos && !pos.equals([0, 0]);
  }

  _getTopLeftPoint() {
    return this.getPixelOrigin().subtract(this._getMapPanePos());
  }

  _getNewTopLeftPoint(center, zoom) {
    var viewHalf = this.getSize()._divideBy(2);
    // TODO round on display, not calculation to increase precision?
    return this.project(center, zoom)._subtract(viewHalf)._round();
  }

  latLngToNewLayerPoint(latlng, newZoom, newCenter) {
    var topLeft = this._getNewTopLeftPoint(newCenter, newZoom).add(this._getMapPanePos());
    return this.project(latlng, newZoom)._subtract(topLeft);
  }

  // layer point of the current center
  _getCenterLayerPoint() {
    return this.containerPointToLayerPoint(this.getSize()._divideBy(2));
  }

  // offset of the specified place to the current center in pixels
  _getCenterOffset(latlng) {
    return this.latLngToLayerPoint(latlng).subtract(this._getCenterLayerPoint());
  }

  // adjust center for view to get inside bounds
  _limitCenter(center, zoom, bounds) {

    if (!bounds) { return center; }

    var centerPoint = this.project(center, zoom),
        viewHalf = this.getSize().divideBy(2),
        viewBounds = new L.Bounds(centerPoint.subtract(viewHalf), centerPoint.add(viewHalf)),
        offset = this._getBoundsOffset(viewBounds, bounds, zoom);

    return this.unproject(centerPoint.add(offset), zoom);
  }

  // adjust offset for view to get inside bounds
  _limitOffset(offset, bounds) {
    if (!bounds) { return offset; }

    var viewBounds = this.getPixelBounds(),
        newBounds = new L.Bounds(viewBounds.min.add(offset), viewBounds.max.add(offset));

    return offset.add(this._getBoundsOffset(newBounds, bounds));
  }

  // returns offset needed for pxBounds to get inside maxBounds at a specified zoom
  _getBoundsOffset(pxBounds, maxBounds, zoom) {
    var nwOffset = this.project(maxBounds.getNorthWest(), zoom).subtract(pxBounds.min),
        seOffset = this.project(maxBounds.getSouthEast(), zoom).subtract(pxBounds.max),

        dx = this._rebound(nwOffset.x, -seOffset.x),
        dy = this._rebound(nwOffset.y, -seOffset.y);

    return new L.geom.Point(dx, dy);
  }

  _rebound(left, right) {
    return left + right > 0 ?
      (left - right).round / 2 :
      math.max(0, left.ceil()) - math.max(0, right.floor());
  }

  _limitZoom(zoom) {
    var min = this.getMinZoom(),
        max = this.getMaxZoom();

    return math.max(min, math.min(max, zoom));
  }
}