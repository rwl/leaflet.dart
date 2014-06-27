library leaflet.map;

import 'dart:html' show Element, window, document, MouseEvent, CanvasRenderingContext2D;
import 'dart:math' as math;
import 'dart:async' show Timer;

import '../core/core.dart' show Handler, Events, stamp;
import '../core/core.dart' show Event, EventType, Util, Browser;
import '../geo/geo.dart' show LatLng, LatLngBounds;
import '../geo/crs/crs.dart' show CRS, EPSG3857;
import '../geometry/geometry.dart' show Bounds, Point2D;
import '../control/control.dart' show Control, Zoom, Attribution;
import '../dom/dom.dart' as dom;
import '../layer/layer.dart' show Layer, Popup, PopupOptions;
import '../layer/tile/tile.dart' show TileLayer;
import './handler/handler.dart';

part 'options.dart';

final containerProp = new Expando<Element>('_leaflet');

typedef LayerFunc(Layer layer);

class LeafletMap extends Object with Events {

  MapStateOptions stateOptions;
  InteractionOptions interactionOptions;
  KeyboardNavigationOptions keyboardNavigationOptions;
  PanningInertiaOptions panningInertiaOptions;
  ControlOptions controlOptions;
  AnimationOptions animationOptions;
  LocateOptions locateOptions;
  ZoomPanOptions zoomPanOptions;

  List<Handler> _handlers;

  Map<String, Layer> _layers;

  Map _zoomBoundLayers;
  int _tileLayersNum, _tileLayersToLoad;

  num _zoom;
  bool _loaded;

  bool _sizeChanged;
  LatLng _initialCenter;

  Element _container;

  /**
   * Map dragging handler (by both mouse and touch).
   */
  Drag dragging;

  /**
   * Touch zoom handler.
   */
  TouchZoom touchZoom;

  /**
   * Double click zoom handler.
   */
  DoubleClickZoom doubleClickZoom;

  /**
   * Scroll wheel zoom handler.
   */
  ScrollWheelZoom scrollWheelZoom;

  /**
   * Box (shift-drag with mouse) zoom handler.
   */
  BoxZoom boxZoom;

  /**
   * Keyboard navigation handler.
   */
  Keyboard keyboard;

  /**
   * Mobile touch hacks (quick tap and touch hold) handler.
   */
  Tap tap;

  /**
   * Zoom control.
   */
  Zoom zoomControl;

  /**
   * Attribution control.
   */
  Attribution attributionControl;

  LeafletMap(Element container, {MapStateOptions stateOptions: null, InteractionOptions interactionOptions: null,
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

    // Hack for https://github.com/Leaflet/Leaflet/issues/1980
    //_onResize = L.bind(_onResize, this);

    _initEvents();

    if (stateOptions.maxBounds != null) {
      setMaxBounds(stateOptions.maxBounds);
    }

    if (stateOptions.center != null && zoomPanOptions.zoom != null) {
      setView(new LatLng.latLng(stateOptions.center), stateOptions.zoom, new ZoomPanOptions(reset: true));
    }

    _handlers = [];

    _layers = {};
    _zoomBoundLayers = {};
    _tileLayersNum = 0;

    //callInitHooks();

    _addLayers(stateOptions.layers);
  }


  /* Public methods that modify map state */

  /**
   * Sets the view of the map (geographical center and zoom) with the given
   * animation options.
   *
   * Replaced by animation-powered implementation in Map.PanAnimation
   */
  /*void setView(LatLng center, [num zoom = null, ZoomPanOptions options = null]) {
    zoom = zoom == null ? getZoom() : zoom;
    _resetView(new LatLng.latLng(center), _limitZoom(zoom));
  }*/

  /**
   * Sets the zoom of the map.
   */
  void setZoom(num zoom, [ZoomOptions options=null]) {
    if (!_loaded) {
      _zoom = _limitZoom(zoom);
      return;
    }
    setView(getCenter(), zoom, new ZoomPanOptions(zoom: options));
  }

  /**
   * Increases the zoom of the map by delta (1 by default).
   */
  void zoomIn([num delta = 1, ZoomOptions options = null]) {
    return setZoom(_zoom + delta, options);
  }

  /**
   * Decreases the zoom of the map by delta (1 by default).
   */
  void zoomOut([num delta = 1, ZoomOptions options = null]) {
    return setZoom(_zoom - delta, options);
  }

  /**
   * Zooms the map while keeping a specified point on the map stationary
   * (e.g. used internally for scroll zoom and double-click zoom).
   */
  void setZoomAroundLatLng(LatLng latlng, num zoom, [ZoomOptions options = null]) {
    setZoomAround(latLngToContainerPoint(latlng), zoom, options);
  }

  /**
   * Zooms the map while keeping a specified point on the map stationary
   * (e.g. used internally for scroll zoom and double-click zoom).
   */
  void setZoomAround(Point2D containerPoint, num zoom, [ZoomOptions options = null]) {
    final scale = getZoomScale(zoom),
        viewHalf = getSize() / 2,

        centerOffset = (containerPoint - viewHalf) * (1 - 1 / scale),
        newCenter = containerPointToLatLng(viewHalf + centerOffset);

    setView(newCenter, zoom, new ZoomPanOptions(zoom: options));
  }

  /**
   * Sets a map view that contains the given geographical bounds with the
   * maximum zoom level possible.
   */
  void fitBounds(LatLngBounds bounds, [ZoomPanOptions options = null]) {
    if (options == null) {
      options = new ZoomPanOptions();
    }
    //bounds = bounds.getBounds ? bounds.getBounds() : new LatLngBounds.latLngBounds(bounds);

    Point2D paddingTL;
    if (options.paddingTopLeft != null) {
      paddingTL = new Point2D.point(options.paddingTopLeft);
    } else if (options.padding != null) {
      paddingTL = new Point2D.point(options.padding);
    } else {
      paddingTL = new Point2D(0, 0);
    }
    Point2D paddingBR;
    if (options.paddingTopLeft != null) {
      paddingBR = new Point2D.point(options.paddingBottomRight);
    } else if (options.padding != null) {
      paddingBR = new Point2D.point(options.padding);
    } else {
      paddingBR = new Point2D(0, 0);
    }

    var zoom = getBoundsZoom(bounds, false, paddingTL + paddingBR);
    final paddingOffset = (paddingBR - paddingTL) / 2,

        swPoint = project(bounds.getSouthWest(), zoom),
        nePoint = project(bounds.getNorthEast(), zoom),
        center = unproject(((swPoint + nePoint) / 2) + paddingOffset, zoom);

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
    fitBounds(new LatLngBounds.between(new LatLng(-90, -180), new LatLng(90, 180)), options);
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
  /*void panBy(Point2D offset) {
    // replaced with animated panBy in Map.PanAnimation.js
    fire(EventType.MOVESTART);

    _rawPanBy(new Point2D.point(offset));

    fire(EventType.MOVE);
    fire(EventType.MOVEEND);
  }*/

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

    if (center == newCenter) { return; }

    panTo(newCenter, options);
  }

  /**
   * Adds the given layer to the map. If optional insertAtTheBottom is set to
   * true, the layer is inserted under all others (useful when switching base
   * tile layers).
   */
  void addLayer(Layer layer) {
    // TODO method is too big, refactor

    final id = stamp(layer);

    if (_layers.containsKey(id)) { return; }

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
    final id = stamp(layer);

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
      layer.off(EventType.LOAD, _onTileLayerLoad, this);
    }

    return;
  }

  /**
   * Returns true if the given layer is currently added to the map.
   */
  bool hasLayer(Layer layer) {
    if (layer == null) { return false; }

    return _layers.containsKey(stamp(layer));
  }

  void eachLayer(LayerFunc fn) {
    _layers.forEach((k, layer) {
      fn(layer);
    });
  }

  Timer _sizeTimer;

  /**
   * Checks if the map container size changed and updates the map if so — call
   * it after you've changed the map size dynamically, also animating pan by
   * default. If options.pan is false, panning will not occur. If
   * options.debounceMoveend is true, it will delay moveend event so that it
   * doesn't happen often even if the method is called many times in a row.
   */
  void invalidateSize({bool animate: true, bool pan: true, bool debounceMoveend: false}) {
    if (!_loaded) { return; }

    final oldSize = getSize();
    _sizeChanged = true;
    _initialCenter = null;

    final newSize = getSize(),
        oldCenter = (oldSize / 2).rounded(),
        newCenter = (newSize / 2).rounded(),
        offset = oldCenter - newCenter;

    if (!offset.x && !offset.y) { return; }

    if (animate && pan) {
      panBy(offset);

    } else {
      if (pan) {
        _rawPanBy(offset);
      }

      fire(EventType.MOVE);

      if (debounceMoveend) {
        _sizeTimer.cancel();
        _sizeTimer = new Timer(const Duration(milliseconds: 200), () {
          fire(EventType.MOVEEND);
        });
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
    //if (_clearControlPos) {
    _clearControlPos();
    //}

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

    return new LatLngBounds.between(sw, ne);
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
  num getBoundsZoom(LatLngBounds bounds, [bool inside = false, Point2D padding = null]) {
    if (padding == null) {
      padding = new Point2D(0, 0);
    }
    bounds = new LatLngBounds.latLngBounds(bounds);

    num zoom = getMinZoom() - (inside ? 1 : 0);
    final maxZoom = getMaxZoom(),
        size = getSize(),

        nw = bounds.getNorthWest(),
        se = bounds.getSouthEast();

    bool zoomNotFound = true;
    var boundsSize;

    padding = new Point2D.point(padding);

    do {
      zoom++;
      boundsSize = project(se, zoom) - project(nw, zoom) + padding;
      zoomNotFound = !inside ? size.contains(boundsSize) : boundsSize.x < size.x || boundsSize.y < size.y;

    } while (zoomNotFound && zoom <= maxZoom);

    if (zoomNotFound && inside) {
      return null;
    }

    return inside ? zoom : zoom - 1;
  }

  Point2D _size;

  /**
   * Returns the current size of the map container.
   */
  Point2D getSize() {
    if (_size == null || _sizeChanged) {
      _size = new Point2D(
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
    final topLeftPoint = _getTopLeftPoint();
    return new Bounds.between(topLeftPoint, topLeftPoint + getSize());
  }

  Point2D _initialTopLeftPoint;

  /**
   * Returns the projected pixel coordinates of the top left point of the map
   * layer (useful in custom layer and overlay implementations).
   */
  Point2D getPixelOrigin() {
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
  Point2D project(LatLng latlng, [num zoom = null]) {
    zoom = zoom == null ? _zoom : zoom;
    return stateOptions.crs.latLngToPoint(new LatLng.latLng(latlng), zoom);
  }

  /**
   * Projects the given absolute pixel coordinates to geographical coordinates
   * for the given zoom level (current zoom level by default).
   */
  LatLng unproject(Point2D point, [num zoom = null]) {
    zoom = zoom == null ? _zoom : zoom;
    return stateOptions.crs.pointToLatLng(new Point2D.point(point), zoom);
  }

  /**
   * Returns the geographical coordinates of a given map layer point.
   */
  LatLng layerPointToLatLng(Point2D point) {
    final projectedPoint = new Point2D.point(point) + getPixelOrigin();
    return unproject(projectedPoint);
  }

  /**
   * Returns the map layer point that corresponds to the given geographical
   * coordinates (useful for placing overlays on the map).
   */
  Point2D latLngToLayerPoint(LatLng latlng) {
    var projectedPoint = project(new LatLng.latLng(latlng))..round();
    return projectedPoint - getPixelOrigin();
  }

  /**
   * Converts the point relative to the map container to a point relative
   * to the map layer.
   */
  Point2D containerPointToLayerPoint(Point2D point) {
    return new Point2D.point(point) - _getMapPanePos();
  }

  /**
   * Converts the point relative to the map layer to a point relative to the
   * map container.
   */
  Point2D layerPointToContainerPoint(Point2D point) {
    return new Point2D.point(point) + _getMapPanePos();
  }

  /**
   * Returns the geographical coordinates of a given map container point.
   */
  LatLng containerPointToLatLng(Point2D point) {
    final layerPoint = containerPointToLayerPoint(new Point2D.point(point));
    return layerPointToLatLng(layerPoint);
  }

  /**
   * Returns the map container point that corresponds to the given
   * geographical coordinates.
   */
  Point2D latLngToContainerPoint(LatLng latlng) {
    return layerPointToContainerPoint(latLngToLayerPoint(new LatLng.latLng(latlng)));
  }

  /**
   * Returns the pixel coordinates of a mouse click (relative to the top left
   * corner of the map) given its event object.
   */
  Point2D mouseEventToContainerPoint(MouseEvent e) {
    return dom.getMousePosition(e, _container);
  }

  /**
   * Returns the pixel coordinates of a mouse click relative to the map layer
   * given its event object.
   */
  Point2D mouseEventToLayerPoint(MouseEvent e) {
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

  void _initContainerID(String id) {
    final container = dom.get(id);
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

    dom.addClass(container, 'leaflet-container' +
      (Browser.touch ? ' leaflet-touch' : '') +
      (Browser.retina ? ' leaflet-retina' : '') +
      (Browser.ielt9 ? ' leaflet-oldie' : '') +
      (animationOptions.fadeAnimation ? ' leaflet-fade-anim' : ''));

    final position = dom.getStyle(container, 'position');

    if (position != 'absolute' && position != 'relative' && position != 'fixed') {
      container.style.position = 'relative';
    }

    _initPanes();

    //if (_initControlPos) {
    _initControlPos();
    //}
  }

  Map<String, Element> _panes;
  Element _mapPane, _tilePane;

  Element get mapPane => _mapPane;

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
      dom.addClass(panes['markerPane'], zoomHide);
      dom.addClass(panes['shadowPane'], zoomHide);
      dom.addClass(panes['popupPane'], zoomHide);
    }
  }

  Element _createPane(String className, [Element container=null]) {
    return dom.create('div', className, container != null ? container : _panes['objectsPane']);
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
      dom.setPosition(_mapPane, new Point2D(0, 0));
    } else {
      _initialTopLeftPoint.add(_getMapPanePos());
    }

    _tileLayersToLoad = _tileLayersNum;

    var loading = !_loaded;
    _loaded = true;

    if (loading) {
      fire(EventType.LOAD);
      eachLayer(_layerAdd);
    }

    fire(EventType.VIEWRESET, {'hard': !preserveMapOffset});

    fire(EventType.MOVE);

    if (zoomChanged || afterZoomAnim) {
      fire(EventType.ZOOMEND);
    }

    fire(EventType.MOVEEND, {'hard': !preserveMapOffset});
  }

  void _rawPanBy(Point2D offset) {
    dom.setPosition(_mapPane, _getMapPanePos() - offset);
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

  void _panInsideMaxBounds([Object obj=null, Event event=null]) {
    panInsideBounds(stateOptions.maxBounds);
  }

  void _checkIfLoaded() {
    if (!_loaded) {
      throw new Exception('Set map center and zoom first.');
    }
  }

  // map events

  void _initEvents([bool on = true]) {
    //if (DomEvent == null) { return; }

    if (on) {
      dom.on(_container, 'click', _onMouseClick, this);
    } else {
      dom.off(_container, 'click', _onMouseClick);//, this);
    }

    final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEUP,
                    EventType.MOUSEENTER, EventType.MOUSELEAVE, EventType.MOUSEMOVE,
                    EventType.CONTEXTMENU];

    for (int i = 0; i < events.length; i++) {
      if (on) {
        dom.on(_container, events[i], _fireMouseEvent, this);
      } else {
        dom.off(_container, events[i], _fireMouseEvent);//, this);
      }
    }

    if (interactionOptions.trackResize) {
      if (on) {
        dom.on(window, 'resize', _onResize, this);
      } else {
        dom.off(window, 'resize', _onResize);//, this);
      }
    }
  }

  String _resizeRequest;

  void _onResize() {
    cancelAnimFrame(_resizeRequest);
    _resizeRequest = requestAnimFrame(() {
      invalidateSize(debounceMoveend: true);
    }, this, false, _container);
  }

  void _onMouseClick(Event e) {
    if (!_loaded || (/*!e._simulated && */((dragging != null && dragging.moved()) || (boxZoom != null && boxZoom.moved()))) || dom._skipped(e)) {
      return;
    }

    fire(EventType.PRECLICK);
    _fireMouseEvent(e);
  }

  void _fireMouseEvent(Event e) {
    if (!_loaded || dom._skipped(e)) {
      return;
    }

    EventType type = e.type;

    type = (type == EventType.MOUSEENTER ? EventType.MOUSEOVER : (type == EventType.MOUSELEAVE ? EventType.MOUSEOUT : type));

    if (!hasEventListeners(type)) { return; }

    if (type == EventType.CONTEXTMENU) {
      dom.preventDefault(e);
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

  void _onTileLayerLoad(Object obj, Event event) {
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

  Point2D _getMapPanePos() {
    return dom.getPosition(_mapPane);
  }

  bool _moved() {
    final pos = _getMapPanePos();
    return pos != null && pos != new Point2D(0, 0);
  }

  Point2D _getTopLeftPoint() {
    return getPixelOrigin() - _getMapPanePos();
  }

  Point2D _getNewTopLeftPoint(LatLng center, [num zoom = null]) {
    var viewHalf = getSize() / 2;
    // TODO round on display, not calculation to increase precision?
    return (project(center, zoom) - viewHalf).rounded();
  }

  //internal use only
  Point2D latLngToNewLayerPoint(LatLng latlng, num newZoom, LatLng newCenter) {
    var topLeft = _getNewTopLeftPoint(newCenter, newZoom) + _getMapPanePos();
    return project(latlng, newZoom) - topLeft;
  }

  /**
   * Layer point of the current center.
   */
  Point2D _getCenterLayerPoint() {
    return containerPointToLayerPoint(getSize() / 2);
  }

  /**
   * Offset of the specified place to the current center in pixels.
   */
  Point2D _getCenterOffset(LatLng latlng) {
    return latLngToLayerPoint(latlng) - _getCenterLayerPoint();
  }

  /**
   * Adjust center for view to get inside bounds.
   */
  LatLng _limitCenter(LatLng center, num zoom, [LatLngBounds bounds=null]) {

    if (bounds == null) { return center; }

    final centerPoint = project(center, zoom),
        viewHalf = getSize() / 2,
        viewBounds = new Bounds.between(centerPoint - viewHalf, centerPoint + viewHalf),
        offset = _getBoundsOffset(viewBounds, bounds, zoom);

    return unproject(centerPoint + offset, zoom);
  }

  /**
   * Adjust offset for view to get inside bounds.
   */
  Point2D /*_*/limitOffset(Point2D offset, LatLngBounds bounds) {
    if (bounds == null) { return offset; }

    var viewBounds = getPixelBounds(),
        newBounds = new Bounds.between(viewBounds.min + offset, viewBounds.max + offset);

    return offset + _getBoundsOffset(newBounds, bounds);
  }

  /**
   * Returns offset needed for pxBounds to get inside maxBounds at a specified
   * zoom.
   */
  Point2D _getBoundsOffset(Bounds pxBounds, LatLngBounds maxBounds, [num zoom=null]) {
    final nwOffset = project(maxBounds.getNorthWest(), zoom) - pxBounds.min,
        seOffset = project(maxBounds.getSouthEast(), zoom) - pxBounds.max,

        dx = _rebound(nwOffset.x, -seOffset.x),
        dy = _rebound(nwOffset.y, -seOffset.y);

    return new Point2D(dx, dy);
  }

  num _rebound(num left, num right) {
    return left + right > 0 ?
      (left - right).round() / 2 :
      math.max(0, left.ceil()) - math.max(0, right.floor());
  }

  /**
   * For internal use.
   */
  num limitZoom(num zoom) {
    var min = getMinZoom(),
        max = getMaxZoom();

    return math.max(min, math.min(max, zoom));
  }

  /* Control extensions */

  Map _controlCorners;

  Map get controlCorners => _controlCorners;

  Element _controlContainer;

  /**
   * Adds the given control to the map.
   */
  addControl(Control control) {
    control.addTo(this);
    return this;
  }

  /**
   * Removes the given control from the map.
   */
  removeControl(control) {
    control.removeFrom(this);
    return this;
  }

  _initControlPos() {
    final corners = _controlCorners = {};
    String l = 'leaflet-';
    final container = _controlContainer =
                dom.create('div', l + 'control-container', _container);

    createCorner(String vSide, String hSide) {
      var className = l + vSide + ' ' + l + hSide;

      corners[vSide + hSide] = dom.create('div', className, container);
    }

    createCorner('top', 'left');
    createCorner('top', 'right');
    createCorner('bottom', 'left');
    createCorner('bottom', 'right');
  }

  _clearControlPos() {
    //_container.removeChild(_controlContainer);
    _controlContainer.remove();
  }


  /* Popup extensions */

  Popup _popup;

  /**
   * Creates a popup with the specified options and opens it in the given point on a map.
   */
  openPopupString(String content, LatLng latlng, PopupOptions options) {
    final popup = new Popup(options)
              ..setLatLng(latlng)
              ..setContent(content);
    openPopup(popup);
  }
  openPopupElement(Element content, LatLng latlng, PopupOptions options) {
    final popup = new Popup(options)
              ..setLatLng(latlng)
              ..setContent(content);
    openPopup(popup);
  }

  /**
   * Opens the specified popup while closing the previously opened (to make sure only one is opened at one time for usability).
   */
  openPopup(Popup popup) { // (Popup) or (String || HTMLElement, LatLng[, Object])
    closePopup();

    popup.open = true;

    _popup = popup;
    addLayer(popup);
  }

  /**
   * Closes the popup previously opened with openPopup (or the given one).
   */
  closePopup([Popup popup=null]) {
    if (popup == null || popup == _popup) {
      popup = _popup;
      _popup = null;
    }
    if (popup != null) {
      removeLayer(popup);
      popup.open = false;
    }
  }


  /* Extends Map to handle zoom animations */

  bool _animatingZoom;
  var _zoomAnimated;
  var _animateToCenter;
  var _animateToZoom;

  bool get zoomAnimated => _zoomAnimated;

  _catchTransitionEnd(e) {
    if (_animatingZoom && e.propertyName.indexOf('transform') >= 0) {
      _onZoomTransitionEnd();
    }
  }

  bool _nothingToAnimate() {
    return _container.querySelectorAll('.leaflet-zoom-animated').length == 0;
  }

  bool _tryAnimatedZoom(center, zoom, options) {

    if (_animatingZoom) { return true; }

    options = options || {};

    // don't animate if disabled, not supported or zoom difference is too large
    if (!_zoomAnimated || options.animate == false || _nothingToAnimate() ||
            (zoom - _zoom).abs() > animationOptions.zoomAnimationThreshold) { return false; }

    // offset is the pixel coords of the zoom origin relative to the current center
    final scale = getZoomScale(zoom),
        offset = _getCenterOffset(center) / (1 - 1 / scale),
      origin = _getCenterLayerPoint() + offset;

    // don't animate if the zoom origin isn't within one screen from the current center, unless forced
    if (options.animate != true && !getSize().contains(offset)) { return false; }

    fire(EventType.MOVESTART);
    fire(EventType.ZOOMSTART);

    _animateZoom(center, zoom, origin, scale, null, true);

    return true;
  }

  /**
   * For internal use.
   */
  void animateZoom(LatLng center, num zoom, Point2D origin, num scale, [Point2D delta=null, bool backwards=false]) {

    _animatingZoom = true;

    // put transform transition on all layers with leaflet-zoom-animated class
    dom.addClass(_mapPane, 'leaflet-zoom-anim');

    // remember what center/zoom to set after animation
    _animateToCenter = center;
    _animateToZoom = zoom;

    // disable any dragging during animation
    //if (L.Draggable) {
    dom.Draggable.disabled = true;
    //}

    fire(EventType.ZOOMANIM, {
      center: center,
      zoom: zoom,
      origin: origin,
      scale: scale,
      delta: delta,
      backwards: backwards
    });
  }

  void _onZoomTransitionEnd() {

    _animatingZoom = false;

    dom.removeClass(_mapPane, 'leaflet-zoom-anim');

    _resetView(_animateToCenter, _animateToZoom, true, true);

    //if (L.Draggable) {
    dom.Draggable.disabled = false;
    //}
  }



  /* Panning animation extensions */

  dom.PosAnimation _panAnim;

  dom.PosAnimation get panAnim => _panAnim;

  /**
   * Sets the view of the map (geographical center and zoom) with the given animation options.
   */
  void setView(LatLng center, num zoom, [ZoomPanOptions options=null]) {

    zoom = zoom == null ? _zoom : _limitZoom(zoom);
    center = _limitCenter(L.latLng(center), zoom, options.maxBounds);
    options = options || {};

    if (_panAnim) {
      _panAnim.stop();
    }

    if (_loaded && !options.reset && options != true) {

      if (options.animate != null) {
        options.zoom = L.extend({animate: options.animate}, options.zoom);
        options.pan = L.extend({animate: options.animate}, options.pan);
      }

      // try animating pan or zoom
      var animated = (_zoom != zoom) ?
        _tryAnimatedZoom && _tryAnimatedZoom(center, zoom, options.zoom) :
        _tryAnimatedPan(center, options.pan);

      if (animated) {
        // prevent resize handler call, the view will refresh after animation anyway
        clearTimeout(_sizeTimer);
        return this;
      }
    }

    // animation didn't start, just reset the map view
    _resetView(center, zoom);
  }

  /**
   * Pans the map by a given number of pixels (animated).
   */
  void panBy(offset, [options=null]) {
    offset = new Point2D.point(offset).rounded();
    options = options || {};

    if (!offset.x && !offset.y) {
      return;
    }

    if (_panAnim == null) {
      _panAnim = new dom.PosAnimation();

      _panAnim.on(EventType.STEP, _onPanTransitionStep, this);
      _panAnim.on(EventType.END, _onPanTransitionEnd, this);
    }

    // don't fire movestart if animating inertia
    if (!options.noMoveStart) {
      fire(EventType.MOVESTART);
    }

    // animate pan unless animate: false specified
    if (options.animate != false) {
      dom.addClass(_mapPane, 'leaflet-pan-anim');

      final newPos = _getMapPanePos() - offset;
      _panAnim.run(_mapPane, newPos, options.duration != null ? options.duration : 0.25, options.easeLinearity);
    } else {
      _rawPanBy(offset);
      fire(EventType.MOVE);
      fire(EventType.MOVEEND);
    }
  }

  void _onPanTransitionStep(Object obj, Event e) {
    fire(EventType.MOVE);
  }

  void _onPanTransitionEnd(Object obj, Event e) {
    dom.removeClass(_mapPane, 'leaflet-pan-anim');
    fire(EventType.MOVEEND);
  }

  bool _tryAnimatedPan(center, options) {
    // difference between the new and current centers in pixels
    final offset = _getCenterOffset(center).floored();

    // don't animate too far unless animate: true specified in options
    if ((options && options.animate) != true && !getSize().contains(offset)) { return false; }

    panBy(offset, options);

    return true;
  }



  /* Convenient shortcuts for using browser geolocation features */

  var _defaultLocateOptions = {
    'watch': false,
    'setView': false,
    'maxZoom': double.INFINITY,
    'timeout': 10000,
    'maximumAge': 0,
    'enableHighAccuracy': false
  };

  LocateOptions _locateOptions;

  /**
   * Tries to locate the user using the Geolocation API, firing a locationfound event with location data on success or a locationerror event on failure, and optionally sets the map view to the user's location with respect to detection accuracy (or to the world view if geolocation failed).
   */
  void locate(Map options) {

    options = _locateOptions = L.extend(_defaultLocateOptions, options);

    if (!navigator.geolocation) {
      _handleGeolocationError({
        'code': 0,
        'message': 'Geolocation not supported.'
      });
      return this;
    }

    var onResponse = L.bind(_handleGeolocationResponse, this),
      onError = L.bind(_handleGeolocationError, this);

    if (options.watch) {
      _locationWatchId =
              navigator.geolocation.watchPosition(onResponse, onError, options);
    } else {
      navigator.geolocation.getCurrentPosition(onResponse, onError, options);
    }
  }

  /**
   * Stops watching location previously initiated by map.locate(watch: true) and aborts resetting the map view if map.locate was called with (setView: true).
   */
  void stopLocate() {
    if (navigator.geolocation) {
      navigator.geolocation.clearWatch(_locationWatchId);
    }
    if (_locateOptions) {
      _locateOptions.setView = false;
    }
  }

  void _handleGeolocationError(error) {
    var c = error.code,
        message = error.message ||
                (c == 1 ? 'permission denied' :
                (c == 2 ? 'position unavailable' : 'timeout'));

    if (_locateOptions.setView && !_loaded) {
      fitWorld();
    }

    fire(EventType.LOCATIONERROR, {
      'code': c,
      'message': 'Geolocation error: $message.'
    });
  }

  void _handleGeolocationResponse(pos) {
    final lat = pos.coords.latitude,
        lng = pos.coords.longitude,
        latlng = new LatLng(lat, lng),

        latAccuracy = 180 * pos.coords.accuracy / 40075017,
        lngAccuracy = latAccuracy / math.cos(LatLng.DEG_TO_RAD * lat),

        bounds = new LatLngBounds.between(
                new LatLng(lat - latAccuracy, lng - lngAccuracy),
                new LatLng(lat + latAccuracy, lng + lngAccuracy)),

        options = _locateOptions;

    if (options.setView) {
      final zoom = math.min(getBoundsZoom(bounds), options.maxZoom);
      setView(latlng, zoom);
    }

    final data = {
      'latlng': latlng,
      'bounds': bounds,
      'timestamp': pos.timestamp
    };

    for (var i in pos.coords) {
      if (pos.coords[i] is num) {
        data[i] = pos.coords[i];
      }
    }

    fire(EventType.LOCATIONFOUND, data);
  }


  /* Path extensions */

  Bounds _pathViewport;

  Bounds get pathViewport => _pathViewport;

  void _updatePathViewport([Object obj, Event e]) {
    final p = Path.CLIP_PADDING,
        size = getSize(),
        panePos = dom.getPosition(_mapPane),
        min = (panePos * -1) - (size * p).rounded(),
        max = min + ((size * (1 + p * 2)).rounded());

    _pathViewport = new Bounds.between(min, max);
  }


  /* Canvas path extensions */

  Element _pathRoot;
  CanvasRenderingContext2D _canvasCtx;

  Element get pathRoot => _pathRoot;

  void _initCanvasPathRoot() {
    Element root = _pathRoot;

    if (root == null) {
      root = _pathRoot = document.createElement('canvas');
      root.style.position = 'absolute';
      final ctx = _canvasCtx = root.getContext('2d');

      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';

      _panes['overlayPane'].append(root);

      if (animationOptions.zoomAnimation) {
        _pathRoot.className = 'leaflet-zoom-animated';
        on(EventType.ZOOMANIM, _animatePathZoom);
        on(EventType.ZOOMEND, _endPathZoom);
      }
      on(EventType.MOVEEND, _updateCanvasViewport);
      _updateCanvasViewport();
    }
  }

  void _updateCanvasViewport([Object obj, Event e]) {
    // don't redraw while zooming. See _updateSvgViewport for more details
    if (_pathZooming) { return; }
    _updatePathViewport();

    var vp = _pathViewport,
        min = vp.min,
        size = vp.max.subtract(min),
        root = _pathRoot;

    //TODO check if this works properly on mobile webkit
    dom.setPosition(root, min);
    root.width = size.x;
    root.height = size.y;
    root.getContext('2d').translate(-min.x, -min.y);
  }


  /* SVG path extensions */

  bool _pathZooming;

  void _initSvgPathRoot() {
    if (_pathRoot == null) {
      _pathRoot = Path.prototype._createElement('svg');
      _panes['overlayPane'].append(_pathRoot);

      if (animationOptions.zoomAnimation && Browser.any3d) {
        dom.addClass(_pathRoot, 'leaflet-zoom-animated');

        on(EventType.ZOOMANIM, _animatePathZoom);
        on(EventType.ZOOMEND, _endPathZoom);
      } else {
        L.DomUtil.addClass(_pathRoot, 'leaflet-zoom-hide');
      }

      on(EventType.MOVEEND, _updateSvgViewport);
      _updateSvgViewport();
    }
  }

  void _animatePathZoom(Object obj, Event e) {
    var scale = getZoomScale(e.zoom),
        offset = _getCenterOffset(e.center) * (-scale) + _pathViewport.min;

    _pathRoot.style[dom.TRANSFORM] =
            '${dom.getTranslateString(offset)} scale($scale) ';

    _pathZooming = true;
  }

  void _endPathZoom(Object obj, Event e) {
    _pathZooming = false;
  }

  void _updateSvgViewport([Object obj, Event e]) {

    if (_pathZooming) {
      // Do not update SVGs while a zoom animation is going on otherwise the animation will break.
      // When the zoom animation ends we will be updated again anyway
      // This fixes the case where you do a momentum move and zoom while the move is still ongoing.
      return;
    }

    _updatePathViewport();

    final vp = _pathViewport,
        min = vp.min,
        max = vp.max,
        width = max.x - min.x,
        height = max.y - min.y,
        root = _pathRoot,
        pane = _panes['overlayPane'];

    // Hack to make flicker on drag end on mobile webkit less irritating
    if (Browser.mobileWebkit) {
      //pane.removeChild(root);
      root.remove();
    }

    dom.setPosition(root, min);
    root.setAttribute('width', width.toString());
    root.setAttribute('height', height.toString());
    root.setAttribute('viewBox', [min.x, min.y, width, height].join(' '));

    if (Browser.mobileWebkit) {
      pane.append(root);
    }
  }

}
