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

  /*factory BaseMap.elem(Element id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }

  factory BaseMap.id(String id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }*/

  BaseMap(Element container, {MapStateOptions stateOptions: null, InteractionOptions interactionOptions: null,
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


    _initContainer(container);
    _initLayout();

    // hack for https://github.com/Leaflet/Leaflet/issues/1980
//    this._onResize = L.bind(this._onResize, this);

    _initEvents();

    if (stateOptions.maxBounds != null) {
      setMaxBounds(stateOptions.maxBounds);
    }

    if (stateOptions.center != null && zoomPanOptions.zoom != null) {
      setView(new LatLng.latLng(stateOptions.center), zoomPanOptions.zoom, new ZoomPanOptions(reset: true));
    }

    _handlers = [];

    _layers = {};
    _zoomBoundLayers = {};
    _tileLayersNum = 0;

    callInitHooks();

    _addLayers(stateOptions.layers);
  }


  // public methods that modify map state

  /**
   * Sets the view of the map (geographical center and zoom) with the given
   * animation options.
   *
   * Replaced by animation-powered implementation in Map.PanAnimation
   */
  setView(LatLng center, num zoom, [ZoomPanOptions options = null]) {
    zoom = zoom == null ? getZoom() : zoom;
    _resetView(new LatLng.latLng(center), _limitZoom(zoom));
  }

  num _zoom;
  bool _loaded;

  /**
   * Sets the zoom of the map.
   */
  setZoom(num zoom, [ZoomOptions options=null]) {
    if (!_loaded) {
      _zoom = _limitZoom(zoom);
      return;
    }
    setView(getCenter(), zoom, new ZoomPanOptions(zoom: options));
  }

  /**
   * Increases the zoom of the map by delta (1 by default).
   */
  zoomIn([num delta = 1, ZoomOptions options = null]) {
    return setZoom(_zoom + delta, options);
  }

  /**
   * Decreases the zoom of the map by delta (1 by default).
   */
  zoomOut([num delta = 1, ZoomOptions options = null]) {
    return setZoom(_zoom - delta, options);
  }

  /**
   * Zooms the map while keeping a specified point on the map stationary
   * (e.g. used internally for scroll zoom and double-click zoom).
   */
  setZoomAroundLatLng(LatLng latlng, num zoom, [ZoomOptions options = null]) {
    setZoomAround(latLngToContainerPoint(latlng), zoom, options);
  }

  /**
   * Zooms the map while keeping a specified point on the map stationary
   * (e.g. used internally for scroll zoom and double-click zoom).
   */
  setZoomAround(geom.Point containerPoint, num zoom, [ZoomOptions options = null]) {
    final scale = getZoomScale(zoom),
        viewHalf = getSize().divideBy(2),

        centerOffset = containerPoint.subtract(viewHalf).multiplyBy(1 - 1 / scale),
        newCenter = containerPointToLatLng(viewHalf.add(centerOffset));

    setView(newCenter, zoom, new ZoomPanOptions(zoom: options));
  }

  /**
   * Sets a map view that contains the given geographical bounds with the
   * maximum zoom level possible.
   */
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

    var zoom = getBoundsZoom(bounds, false, paddingTL.add(paddingBR));
    final paddingOffset = paddingBR.subtract(paddingTL).divideBy(2),

        swPoint = project(bounds.getSouthWest(), zoom),
        nePoint = project(bounds.getNorthEast(), zoom),
        center = unproject(swPoint.add(nePoint).divideBy(2).add(paddingOffset), zoom);

    if (options != null && options.maxZoom != null) {
      zoom = math.min(options.maxZoom, zoom);
    }

    return setView(center, zoom, options);
  }

  /**
   * Sets a map view that mostly contains the whole world with the maximum
   * zoom level possible.
   */
  void fitWorld([ZoomPanOptions options = null]) {
    fitBounds(new LatLngBounds.array([[-90, -180], [90, 180]]), options);
  }

  /**
   * Pans the map to a given center. Makes an animated pan if new center is
   * not more than one screen away from the current one.
   */
  void panTo(LatLng center, [PanOptions options = null]) { // (LatLng)
    setView(center, _zoom, new ZoomPanOptions(pan: options));
  }

  /**
   * Pans the map by a given number of pixels (animated).
   */
  void panBy(geom.Point offset) {
    // replaced with animated panBy in Map.PanAnimation.js
    fire(EventType.MOVESTART);

    _rawPanBy(new geom.Point.point(offset));

    fire(EventType.MOVE);
    fire(EventType.MOVEEND);
  }

  /**
   * Restricts the map view to the given bounds (see map maxBounds option).
   */
  void setMaxBounds(LatLngBounds bounds) {
    bounds = new LatLngBounds.latLngBounds(bounds);

    stateOptions.maxBounds = bounds;

    if (bounds == null) {
      return off(EventType.MOVEEND, _panInsideMaxBounds, this);
    }

    if (_loaded) {
      _panInsideMaxBounds();
    }

    on(EventType.MOVEEND, _panInsideMaxBounds, this);
  }

  /**
   * Pans the map to the closest view that would lie inside the given bounds
   * (if it's not already), controlling the animation using the options
   * specific, if any.
   */
  void panInsideBounds(LatLngBounds bounds, [PanOptions options = null]) {
    var center = getCenter(),
      newCenter = _limitCenter(center, _zoom, bounds);

    if (center.equals(newCenter)) { return; }

    panTo(newCenter, options);
  }

  /**
   * Adds the given layer to the map. If optional insertAtTheBottom is set to
   * true, the layer is inserted under all others (useful when switching base
   * tile layers).
   */
  void addLayer(Layer layer) {
    // TODO method is too big, refactor

    var id = core.Util.stamp(layer);

    if (_layers[id]) { return; }

    _layers[id] = layer;

    // TODO getMaxZoom, getMinZoom in ILayer (instead of options)
    if (layer is TileLayer) {
      if (!layer.options.maxZoom.isNaN || !layer.options.minZoom.isNaN) {
        _zoomBoundLayers[id] = layer;
        _updateZoomLevels();
      }
    }

    // TODO looks ugly, refactor!!!
    if (animationOptions.zoomAnimation && layer is TileLayer) {
      _tileLayersNum++;
      _tileLayersToLoad++;
      layer.on(EventType.LOAD, _onTileLayerLoad, this);
    }

    if (_loaded) {
      _layerAdd(layer);
    }

    return;
  }

  /**
   * Removes the given layer from the map.
   */
  void removeLayer(Layer layer) {
    var id = core.Util.stamp(layer);

    if (!_layers.containsKey(id)) { return; }

    if (_loaded) {
      layer.onRemove(this);
    }

    _layers.remove(id);

    if (_loaded) {
      fire(EventType.LAYERREMOVE, {'layer': layer});
    }

    if (_zoomBoundLayers.containsKey(id)) {
      _zoomBoundLayers.remove(id);
      _updateZoomLevels();
    }

    // TODO looks ugly, refactor
    if (animationOptions.zoomAnimation && layer is TileLayer) {
      _tileLayersNum--;
      _tileLayersToLoad--;
      layer.off('load', _onTileLayerLoad, this);
    }

    return;
  }

  /**
   * Returns true if the given layer is currently added to the map.
   */
  bool hasLayer(Layer layer) {
    if (layer == null) { return false; }

    return _layers.containsKey(core.Util.stamp(layer));
  }

  /*eachLayer(method, context) {
    for (var i in _layers) {
      method.call(context, _layers[i]);
    }
    return this;
  }*/

  bool _sizeChanged;
  LatLng _initialCenter;

  /**
   * Checks if the map container size changed and updates the map if so — call
   * it after you've changed the map size dynamically, also animating pan by
   * default. If options.pan is false, panning will not occur. If
   * options.debounceMoveend is true, it will delay moveend event so that it
   * doesn't happen often even if the method is called many times in a row.
   */
  void invalidateSize({bool animate: true, bool pan: true, bool debounceMoveend: false}) {
    if (!_loaded) { return; }

    /*options = L.extend({
      animate: false,
      pan: true
    }, options == true ? {animate: true} : options);*/

    var oldSize = getSize();
    _sizeChanged = true;
    _initialCenter = null;

    var newSize = getSize(),
        oldCenter = oldSize.divideBy(2).round(),
        newCenter = newSize.divideBy(2).round(),
        offset = oldCenter.subtract(newCenter);

    if (!offset.x && !offset.y) { return; }

    if (animate && pan) {
      panBy(offset);

    } else {
      if (pan) {
        _rawPanBy(offset);
      }

      fire(EventType.MOVE);

      if (debounceMoveend) {
        clearTimeout(_sizeTimer);
        _sizeTimer = setTimeout(bind(this.fire, this, EventType.MOVEEND), 200);
      } else {
        fire(EventType.MOVEEND);
      }
    }

    fire(EventType.RESIZE, {
      'oldSize': oldSize,
      'newSize': newSize
    });
  }

  // TODO handler.addTo
  /*addHandler(name, HandlerClass) {
    if (!HandlerClass) { return this; }

    var handler = this[name] = new HandlerClass(this);

    _handlers.push(handler);

    if (options[name]) {
      handler.enable();
    }

    return this;
  }*/

  /**
   * Destroys the map and clears all related event listeners.
   */
  remove() {
    if (_loaded) {
      fire(EventType.UNLOAD);
    }

    _initEvents(false);

    /*try {
      // throws error in IE6-8
      delete(_container._leaflet);
    } catch (e) {
      _container._leaflet = undefined;
    }*/
    containerProp[_container] = null;

    _clearPanes();
    if (_clearControlPos) {
      _clearControlPos();
    }

    _clearHandlers();

    return this;
  }


  /* public methods for getting map state */

  /**
   * Returns the geographical center of the map view.
   */
  LatLng getCenter() {
    _checkIfLoaded();

    if (_initialCenter && !_moved()) {
      return _initialCenter;
    }
    return layerPointToLatLng(_getCenterLayerPoint());
  }

  /**
   * Returns the current zoom of the map view.
   */
  num getZoom() {
    return _zoom;
  }

  /**
   * Returns the LatLngBounds of the current map view.
   */
  LatLngBounds getBounds() {
    final bounds = getPixelBounds(),
        sw = unproject(bounds.getBottomLeft()),
        ne = unproject(bounds.getTopRight());

    return new LatLngBounds(sw, ne);
  }

  /**
   * Returns the minimum zoom level of the map.
   */
  num getMinZoom() {
    return stateOptions.minZoom == null ?
      (_layersMinZoom == null ? 0 : _layersMinZoom) :
      stateOptions.minZoom;
  }

  /**
   * Returns the maximum zoom level of the map.
   */
  num getMaxZoom() {
    return stateOptions.maxZoom == null ?
      (_layersMaxZoom == null ? double.INFINITY : _layersMaxZoom) :
      stateOptions.maxZoom;
  }

  /**
   * Returns the maximum zoom level on which the given bounds fit to the map
   * view in its entirety. If inside (optional) is set to true, the method
   * instead returns the minimum zoom level on which the map view fits into
   * the given bounds in its entirety.
   */
  num getBoundsZoom(LatLngBounds bounds, [bool inside = false, geom.Point padding = null]) {
    if (padding == null) {
      padding = new geom.Point(0, 0);
    }
    bounds = new LatLngBounds.latLngBounds(bounds);

    num zoom = getMinZoom() - (inside ? 1 : 0);
    final maxZoom = getMaxZoom(),
        size = getSize(),

        nw = bounds.getNorthWest(),
        se = bounds.getSouthEast();

    bool zoomNotFound = true;
    var boundsSize;

    padding = new Point.point(padding);

    do {
      zoom++;
      boundsSize = project(se, zoom).subtract(project(nw, zoom)).add(padding);
      zoomNotFound = !inside ? size.contains(boundsSize) : boundsSize.x < size.x || boundsSize.y < size.y;

    } while (zoomNotFound && zoom <= maxZoom);

    if (zoomNotFound && inside) {
      return null;
    }

    return inside ? zoom : zoom - 1;
  }

  geom.Point _size;

  /**
   * Returns the current size of the map container.
   */
  geom.Point getSize() {
    if (_size == null || _sizeChanged) {
      _size = new geom.Point(
        _container.clientWidth,
        _container.clientHeight);

      _sizeChanged = false;
    }
    return _size.clone();
  }

  /**
   * Returns the bounds of the current map view in projected pixel coordinates
   * (sometimes useful in layer and overlay implementations).
   */
  Bounds getPixelBounds() {
    var topLeftPoint = _getTopLeftPoint();
    return new Bounds(topLeftPoint, topLeftPoint.add(getSize()));
  }

  geom.Point _initialTopLeftPoint;

  /**
   * Returns the projected pixel coordinates of the top left point of the map
   * layer (useful in custom layer and overlay implementations).
   */
  geom.Point getPixelOrigin() {
    _checkIfLoaded();
    return _initialTopLeftPoint;
  }

  /**
   * Returns an object with different map panes (to render overlays in).
   */
  Map<String, Element> get panes => new Map.from(_panes);

  /**
   * Returns the container element of the map.
   */
  Element getContainer() {
    return _container;
  }


  // TODO replace with universal implementation after refactoring projections

  getZoomScale(toZoom) {
    final crs = stateOptions.crs;
    return crs.scale(toZoom) / crs.scale(_zoom);
  }

  getScaleZoom(scale) {
    return _zoom + (math.log(scale) / math.LN2);
  }


  /* Conversion methods */

  /**
   * Projects the given geographical coordinates to absolute pixel coordinates
   * for the given zoom level (current zoom level by default).
   */
  geom.Point project(LatLng latlng, [num zoom = null]) {
    zoom = zoom == null ? _zoom : zoom;
    return stateOptions.crs.latLngToPoint(new LatLng.latLng(latlng), zoom);
  }

  /**
   * Projects the given absolute pixel coordinates to geographical coordinates
   * for the given zoom level (current zoom level by default).
   */
  LatLng unproject(geom.Point point, [num zoom = null]) {
    zoom = zoom == null ? _zoom : zoom;
    return stateOptions.crs.pointToLatLng(new geom.Point.point(point), zoom);
  }

  /**
   * Returns the geographical coordinates of a given map layer point.
   */
  LatLng layerPointToLatLng(geom.Point point) {
    final projectedPoint = new geom.Point.point(point).add(getPixelOrigin());
    return unproject(projectedPoint);
  }

  /**
   * Returns the map layer point that corresponds to the given geographical
   * coordinates (useful for placing overlays on the map).
   */
  geom.Point latLngToLayerPoint(LatLng latlng) {
    var projectedPoint = project(new LatLng.latLng(latlng))._round();
    return projectedPoint._subtract(getPixelOrigin());
  }

  /**
   * Converts the point relative to the map container to a point relative
   * to the map layer.
   */
  geom.Point containerPointToLayerPoint(geom.Point point) {
    return new geom.Point.point(point).subtract(_getMapPanePos());
  }

  /**
   * Converts the point relative to the map layer to a point relative to the
   * map container.
   */
  geom.Point layerPointToContainerPoint(geom.Point point) {
    return new geom.Point.point(point).add(_getMapPanePos());
  }

  /**
   * Returns the geographical coordinates of a given map container point.
   */
  LatLng containerPointToLatLng(geom.Point point) {
    final layerPoint = containerPointToLayerPoint(new geom.Point.point(point));
    return layerPointToLatLng(layerPoint);
  }

  /**
   * Returns the map container point that corresponds to the given
   * geographical coordinates.
   */
  geom.Point latLngToContainerPoint(LatLng latlng) {
    return layerPointToContainerPoint(latLngToLayerPoint(new LatLng.latLng(latlng)));
  }

  /**
   * Returns the pixel coordinates of a mouse click (relative to the top left
   * corner of the map) given its event object.
   */
  geom.Point mouseEventToContainerPoint(core.Event e) {
    return DomEvent.getMousePosition(e, _container);
  }

  /**
   * Returns the pixel coordinates of a mouse click relative to the map layer
   * given its event object.
   */
  geom.Point mouseEventToLayerPoint(MouseEvent e) {
    return containerPointToLayerPoint(mouseEventToContainerPoint(e));
  }

  /**
   * Returns the geographical coordinates of the point the mouse clicked on
   * given the click's event object.
   */
  LatLng mouseEventToLatLng(MouseEvent e) {
    return layerPointToLatLng(mouseEventToLayerPoint(e));
  }


  /* Map initialization methods */

  Element _container;

  void _initContainerID(String id) {
    final container = DomUtil.get(id);
    if (container == null) {
      throw new Exception('Map container not found.');
    }
    _initContainer(container);
  }

  void _initContainer(Element container) {
    _container = container;

    if (containerProp[container] != null) {
      throw new Exception('Map container is already initialized.');
    }

    containerProp[container] = true;
  }

  _initLayout() {
    var container = _container;

    DomUtil.addClass(container, 'leaflet-container' +
      (core.Browser.touch ? ' leaflet-touch' : '') +
      (core.Browser.retina ? ' leaflet-retina' : '') +
      (core.Browser.ielt9 ? ' leaflet-oldie' : '') +
      (animationOptions.fadeAnimation ? ' leaflet-fade-anim' : ''));

    var position = DomUtil.getStyle(container, 'position');

    if (position != 'absolute' && position != 'relative' && position != 'fixed') {
      container.style.position = 'relative';
    }

    _initPanes();

    if (_initControlPos) {
      _initControlPos();
    }
  }

  Map<String, Element> _panes;
  Element _mapPane, _tilePane;

  void _initPanes() {
    final panes = _panes = new Map<String, Element>();

    _mapPane = panes['mapPane'] = _createPane('leaflet-map-pane', _container);

    _tilePane = panes['tilePane'] = _createPane('leaflet-tile-pane', _mapPane);
    panes['objectsPane'] = _createPane('leaflet-objects-pane', _mapPane);
    panes['shadowPane'] = _createPane('leaflet-shadow-pane');
    panes['overlayPane'] = _createPane('leaflet-overlay-pane');
    panes['markerPane'] = _createPane('leaflet-marker-pane');
    panes['popupPane'] = _createPane('leaflet-popup-pane');

    var zoomHide = ' leaflet-zoom-hide';

    if (!animationOptions.markerZoomAnimation) {
      DomUtil.addClass(panes['markerPane'], zoomHide);
      DomUtil.addClass(panes['shadowPane'], zoomHide);
      DomUtil.addClass(panes['popupPane'], zoomHide);
    }
  }

  void _createPane(String className, [Element container=null]) {
    return DomUtil.create('div', className, container != null ? container : _panes['objectsPane']);
  }

  void _clearPanes() {
//    _container.removeChild(_mapPane);
    _mapPane.remove();
  }

//  _addLayers([var layers=null]) {
//    layers = layers ? (layers is List ? layers : [layers]) : [];
  void _addLayers(List<Layer> layers) {
    for (var i = 0, len = layers.length; i < len; i++) {
      addLayer(layers[i]);
    }
  }


  // private methods that modify map state

  void _resetView(LatLng center, num zoom, [bool preserveMapOffset=false, bool afterZoomAnim=false]) {

    var zoomChanged = (_zoom != zoom);

    if (!afterZoomAnim) {
      fire(EventType.MOVESTART);

      if (zoomChanged) {
        fire(EventType.ZOOMSTART);
      }
    }

    _zoom = zoom;
    _initialCenter = center;

    _initialTopLeftPoint = _getNewTopLeftPoint(center);

    if (!preserveMapOffset) {
      DomUtil.setPosition(_mapPane, new geom.Point(0, 0));
    } else {
      _initialTopLeftPoint._add(_getMapPanePos());
    }

    _tileLayersToLoad = _tileLayersNum;

    var loading = !_loaded;
    _loaded = true;

    if (loading) {
      fire(EventType.LOAD);
      eachLayer(_layerAdd, this);
    }

    fire(EventType.VIEWRESET, {'hard': !preserveMapOffset});

    fire(EventType.MOVE);

    if (zoomChanged || afterZoomAnim) {
      fire(EventType.ZOOMEND);
    }

    fire(EventType.MOVEEND, {'hard': !preserveMapOffset});
  }

  void _rawPanBy(geom.Point offset) {
    DomUtil.setPosition(_mapPane, _getMapPanePos().subtract(offset));
  }

  _getZoomSpan() {
    return getMaxZoom() - getMinZoom();
  }

  num _layersMaxZoom, _layersMinZoom;

  _updateZoomLevels() {
    int i = null;
    num minZoom = double.INFINITY;
    num maxZoom = double.NEGATIVE_INFINITY;
    final oldZoomSpan = _getZoomSpan();

    for (i in _zoomBoundLayers) {
      var layer = _zoomBoundLayers[i];
      if (!layer.options.minZoom.isNaN) {
        minZoom = math.min(minZoom, layer.options.minZoom);
      }
      if (!layer.options.maxZoom.isNaN) {
        maxZoom = math.max(maxZoom, layer.options.maxZoom);
      }
    }

    if (i == null) { // we have no tilelayers
      _layersMaxZoom = _layersMinZoom = null;
    } else {
      _layersMaxZoom = maxZoom;
      _layersMinZoom = minZoom;
    }

    if (oldZoomSpan != _getZoomSpan()) {
      fire(EventType.ZOOMLEVELSCHANGE);
    }
  }

  bool _panInsideMaxBounds([Object obj=null, core.Event event=null]) {
    panInsideBounds(stateOptions.maxBounds);
  }

  void _checkIfLoaded() {
    if (!_loaded) {
      throw new Exception('Set map center and zoom first.');
    }
  }

  // map events

  void _initEvents([bool on = true]) {
    if (DomEvent == null) { return; }

    if (on) {
      DomEvent.on(_container, 'click', _onMouseClick, this);
    } else {
      DomEvent.off(_container, 'click', _onMouseClick, this);
    }

    final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEUP,
                    EventType.MOUSEENTER, EventType.MOUSELEAVE, EventType.MOUSEMOVE,
                    EventType.CONTEXTMENU];

    for (int i = 0; i < events.length; i++) {
      if (on) {
        DomEvent.on(_container, events[i], _fireMouseEvent, this);
      } else {
        DomEvent.off(_container, events[i], _fireMouseEvent, this);
      }
    }

    if (interactionOptions.trackResize) {
      if (on) {
        DomEvent.on(window, 'resize', _onResize, this);
      } else {
        DomEvent.off(window, 'resize', _onResize, this);
      }
    }
  }

  void _onResize() {
    core.Util.cancelAnimFrame(_resizeRequest);
    _resizeRequest = core.Util.requestAnimFrame(
            () { invalidateSize(debounceMoveend: true); }, this, false, _container);
  }

  void _onMouseClick(core.Event e) {
    if (!_loaded ||
        (!e._simulated && ((this.dragging && this.dragging.moved()) || (this.boxZoom && this.boxZoom.moved()))) ||
        DomEvent._skipped(e)) {
      return;
    }

    fire(EventType.PRECLICK);
    _fireMouseEvent(e);
  }

  void _fireMouseEvent(core.Event e) {
    if (!_loaded || DomEvent._skipped(e)) {
      return;
    }

    EventType type = e.type;

    type = (type == EventType.MOUSEENTER ? EventType.MOUSEOVER : (type == EventType.MOUSELEAVE ? EventType.MOUSEOUT : type));

    if (!hasEventListeners(type)) { return; }

    if (type == EventType.CONTEXTMENU) {
      DomEvent.preventDefault(e);
    }

    final containerPoint = mouseEventToContainerPoint(e),
        layerPoint = containerPointToLayerPoint(containerPoint),
        latlng = layerPointToLatLng(layerPoint);

    fire(type, {
      'latlng': latlng,
      'layerPoint': layerPoint,
      'containerPoint': containerPoint,
      'originalEvent': e
    });
  }

  bool _onTileLayerLoad(Object obj, core.Event event) {
    _tileLayersToLoad--;
    if (_tileLayersNum && _tileLayersToLoad == 0) {
      fire(EventType.TILELAYERSLOAD);
    }
  }

  void _clearHandlers() {
    for (int i = 0; i < _handlers.length; i++) {
      _handlers[i].disable();
    }
  }

  /**
   * Runs the given callback when the map gets initialized with a place and
   * zoom, or immediately if it happened already, optionally passing a
   * function context.
   */
  void whenReady(Function callback, [Object context=null]) {
    if (_loaded) {
      callback.call(context || this, this);
    } else {
      on(EventType.LOAD, callback, context);
    }
    return;
  }

  void _layerAdd(Layer layer) {
    layer.onAdd(this);
    fire(EventType.LAYERADD, {'layer': layer});
  }


  /* Private methods for getting map state */

  geom.Point _getMapPanePos() {
    return DomUtil.getPosition(_mapPane);
  }

  bool _moved() {
    final pos = _getMapPanePos();
    return pos != null && !pos.equals([0, 0]);
  }

  geom.Point _getTopLeftPoint() {
    return getPixelOrigin().subtract(_getMapPanePos());
  }

  geom.Point _getNewTopLeftPoint(LatLng center, [num zoom = null]) {
    var viewHalf = getSize()._divideBy(2);
    // TODO round on display, not calculation to increase precision?
    return project(center, zoom)._subtract(viewHalf)._round();
  }

  //internal use only
  geom.Point latLngToNewLayerPoint(LatLng latlng, num newZoom, LatLng newCenter) {
    var topLeft = _getNewTopLeftPoint(newCenter, newZoom).add(_getMapPanePos());
    return project(latlng, newZoom)._subtract(topLeft);
  }

  /**
   * Layer point of the current center.
   */
  geom.Point _getCenterLayerPoint() {
    return containerPointToLayerPoint(getSize()._divideBy(2));
  }

  /**
   * Offset of the specified place to the current center in pixels.
   */
  geom.Point _getCenterOffset(LatLng latlng) {
    return latLngToLayerPoint(latlng).subtract(_getCenterLayerPoint());
  }

  /**
   * Adjust center for view to get inside bounds.
   */
  LatLng _limitCenter(LatLng center, num zoom, [LatLngBounds bounds=null]) {

    if (bounds == null) { return center; }

    final centerPoint = project(center, zoom),
        viewHalf = getSize().divideBy(2),
        viewBounds = new Bounds(centerPoint.subtract(viewHalf), centerPoint.add(viewHalf)),
        offset = _getBoundsOffset(viewBounds, bounds, zoom);

    return unproject(centerPoint.add(offset), zoom);
  }

  /**
   * Adjust offset for view to get inside bounds.
   */
  geom.Point _limitOffset(geom.Point offset, LatLngBounds bounds) {
    if (bounds == null) { return offset; }

    var viewBounds = getPixelBounds(),
        newBounds = new Bounds(viewBounds.min.add(offset), viewBounds.max.add(offset));

    return offset.add(_getBoundsOffset(newBounds, bounds));
  }

  /**
   * Returns offset needed for pxBounds to get inside maxBounds at a specified
   * zoom.
   */
  geom.Point _getBoundsOffset(Bounds pxBounds, LatLngBounds maxBounds, [num zoom=null]) {
    final nwOffset = project(maxBounds.getNorthWest(), zoom).subtract(pxBounds.min),
        seOffset = project(maxBounds.getSouthEast(), zoom).subtract(pxBounds.max),

        dx = _rebound(nwOffset.x, -seOffset.x),
        dy = _rebound(nwOffset.y, -seOffset.y);

    return new geom.Point(dx, dy);
  }

  num _rebound(num left, num right) {
    return left + right > 0 ?
      (left - right).round() / 2 :
      math.max(0, left.ceil()) - math.max(0, right.floor());
  }

  num _limitZoom(num zoom) {
    var min = getMinZoom(),
        max = getMaxZoom();

    return math.max(min, math.min(max, zoom));
  }

  /* Control extensions */

  Map _controlCorners;

  Map get controlCorners => _controlCorners;

  addControl(Control control) {
    control.addTo(this);
    return this;
  }

  removeControl(control) {
    control.removeFrom(this);
    return this;
  }

  _initControlPos() {
    final corners = this._controlCorners = {};
    String l = 'leaflet-';
    final container = this._controlContainer =
                DomUtil.create('div', l + 'control-container', this._container);

    createCorner(String vSide, String hSide) {
      var className = l + vSide + ' ' + l + hSide;

      corners[vSide + hSide] = DomUtil.create('div', className, container);
    }

    createCorner('top', 'left');
    createCorner('top', 'right');
    createCorner('bottom', 'left');
    createCorner('bottom', 'right');
  }

  _clearControlPos() {
    this._container.removeChild(this._controlContainer);
  }
}