library leaflet.map;

import 'dart:html' show Element, querySelector, window, document,
    CanvasRenderingContext2D, Geoposition, PositionError, CanvasElement, Event;
import 'dart:html' as html;
import 'dart:svg' show SvgSvgElement;
import 'dart:math' as math;
import 'dart:async' show Timer, StreamSubscription, Stream, StreamController;

import 'package:leaflet/src/core/browser.dart' as browser;
import 'package:quiver/core.dart' show firstNonNull;

import '../core/core.dart' show Handler, Events, stamp, ZoomAnimEvent;
import '../core/core.dart' show MapEvent, EventType, Util, Browser, LayerEvent, ResizeEvent, ViewEvent, MouseEvent, ZoomEvent, ErrorEvent, LocationEvent, TileEvent, LayersControlEvent, DragEndEvent, PopupEvent;
import '../geo/geo.dart' show LatLng, LatLngBounds;
import '../geo/crs/crs.dart' show CRS, EPSG3857;
import '../geometry/geometry.dart' show Bounds, Point2D;
import '../control/control.dart' show Control, Zoom, Attribution, ControlPosition;
import '../dom/dom.dart' as dom;
import '../layer/layer.dart' show Layer, Popup, PopupOptions;
import '../layer/vector/vector.dart' show Path;
import '../layer/tile/tile.dart' show TileLayer;
import './handler/handler.dart';

part 'options.dart';

final containerProp = new Expando<bool>('_leaflet');

typedef LayerFunc(Layer layer);

class LeafletMap extends Object {

  /*MapStateOptions options;
  InteractionOptions options;
  KeyboardNavigationOptions options;
  PanningInertiaOptions options;
  ControlOptions options;
  AnimationOptions options;
  LocateOptions options;
  ZoomPanOptions options;*/
  MapOptions options;

  List<Handler> _handlers;

  Map<String, Layer> _layers;

  Map _zoomBoundLayers;
  int _tileLayersNum = 0;
  int _tileLayersToLoad = 0;

  num _zoom;
  bool _loaded = false;

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

  LeafletMap(Element container, [this.options=null]/*{MapStateOptions options: null, InteractionOptions options: null,
      KeyboardNavigationOptions options: null, PanningInertiaOptions options: null,
      ControlOptions options: null, AnimationOptions options: null, LocateOptions options: null,
      ZoomPanOptions options: null}*/) {
    /*if (options == null) {
      options = new MapStateOptions();
    }
    this.options = options;
    if (options == null) {
      options = new InteractionOptions();
    }
    this.options = options;
    if (options == null) {
      options = new KeyboardNavigationOptions();
    }
    this.options = options;
    if (options == null) {
      options = new PanningInertiaOptions();
    }
    this.options = options;
    if (options == null) {
      options = new ControlOptions();
    }
    this.options = options;
    if (options == null) {
      options = new AnimationOptions();
    }
    this.options = options;
    if (options == null) {
      options = new LocateOptions();
    }
    this.options = options;
    if (options == null) {
      options = new ZoomPanOptions();
    }
    this.options = options;*/
    if (options == null) {
      options = new MapOptions();
    }


    _initContainer(container);
    _initLayout();

    // Hack for https://github.com/Leaflet/Leaflet/issues/1980
    //_onResize = L.bind(_onResize, this);

    _initEvents();

    if (options.maxBounds != null) {
      setMaxBounds(options.maxBounds);
    }

    if (options.center != null && options.zoom != null) {
      setView(new LatLng.latLng(options.center), options.zoom, new ZoomPanOptions()..reset = true);
    }

    _handlers = [];

    _layers = {};
    _zoomBoundLayers = {};
    _tileLayersNum = 0;

    //callInitHooks();

    _addLayers(options.layers);
  }

  factory LeafletMap.query(String selectors, [MapOptions options=null]) {
    final container = document.querySelector(selectors);
    return new LeafletMap(container, options);
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
      _zoom = limitZoom(zoom);
      return;
    }
    setView(getCenter(), zoom, new ZoomPanOptions()..zoomOptions = options);
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

    setView(newCenter, zoom, new ZoomPanOptions()..zoomOptions = options);
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
    setView(center, _zoom, new ZoomPanOptions()..panOptions = options);
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

  StreamSubscription<MapEvent> _panInsideMaxBoundsSubscription;

  /**
   * Restricts the map view to the given bounds (see map maxBounds option).
   */
  void setMaxBounds(LatLngBounds bounds) {
    bounds = new LatLngBounds.latLngBounds(bounds);

    options.maxBounds = bounds;

    if (bounds == null) {
      //off(EventType.MOVEEND, _panInsideMaxBounds);
      _panInsideMaxBoundsSubscription.cancel();
      return;
    }

    if (_loaded) {
      _panInsideMaxBounds();
    }

    //on(EventType.MOVEEND, _panInsideMaxBounds);
    _panInsideMaxBoundsSubscription = onMoveEnd.listen(_panInsideMaxBounds);
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

  StreamSubscription<TileEvent> _onTileLayerLoadSubscription;

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
    if (options.zoomAnimation == true && layer is TileLayer) {
      _tileLayersNum++;
      _tileLayersToLoad++;
      //layer.on(EventType.LOAD, _onTileLayerLoad);
      _onTileLayerLoadSubscription = layer.onLoad.listen(_onTileLayerLoad);
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
      fireEvent(new LayerEvent(EventType.LAYERREMOVE, layer));
    }

    if (_zoomBoundLayers.containsKey(id)) {
      _zoomBoundLayers.remove(id);
      _updateZoomLevels();
    }

    // TODO looks ugly, refactor
    if (options.zoomAnimation && layer is TileLayer) {
      _tileLayersNum--;
      _tileLayersToLoad--;
      //layer.off(EventType.LOAD, _onTileLayerLoad);
      _onTileLayerLoadSubscription.cancel();
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

    if (offset.x == 0 && offset.y == 0) { return; }

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

    fireEvent(new ResizeEvent(oldSize, newSize));
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

    if (_initialCenter != null && !_moved()) {
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

  num get zoom => _zoom;

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
    return options.minZoom == null ?
      (_layersMinZoom == null ? 0 : _layersMinZoom) :
      options.minZoom;
  }

  /**
   * Returns the maximum zoom level of the map.
   */
  num getMaxZoom() {
    return options.maxZoom == null ?
      (_layersMaxZoom == null ? double.INFINITY : _layersMaxZoom) :
      options.maxZoom;
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
    final crs = options.crs;
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
    return options.crs.latLngToPoint(new LatLng.latLng(latlng), zoom);
  }

  /**
   * Projects the given absolute pixel coordinates to geographical coordinates
   * for the given zoom level (current zoom level by default).
   */
  LatLng unproject(Point2D point, [num zoom = null]) {
    zoom = zoom == null ? _zoom : zoom;
    return options.crs.pointToLatLng(new Point2D.point(point), zoom);
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
  Point2D mouseEventToContainerPoint(html.MouseEvent e) {
    return dom.getMousePosition(e, _container);
  }

  /**
   * Returns the pixel coordinates of a mouse click relative to the map layer
   * given its event object.
   */
  Point2D mouseEventToLayerPoint(html.MouseEvent e) {
    return containerPointToLayerPoint(mouseEventToContainerPoint(e));
  }

  /**
   * Returns the geographical coordinates of the point the mouse clicked on
   * given the click's event object.
   */
  LatLng mouseEventToLatLng(html.MouseEvent e) {
    return layerPointToLatLng(mouseEventToLayerPoint(e));
  }


  /* Map initialization methods */

  void _initContainerID(String id) {
    final container = querySelector('#id');
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

  void _initLayout() {
    _container.classes.add('leaflet-container');
    // TODO: make sure the following fields are non-null and remove the `== true`
    if (browser.touch == true) _container.classes.add('leaflet-touch');
    if (browser.retina  == true) _container.classes.add('leaflet-retina');
    if (options.fadeAnimation  == true) _container.classes.add('leaflet-fade-anim');

    final position = _container.style.getPropertyValue('position');

    if (position != 'absolute' && position != 'relative' && position != 'fixed') {
      _container.style.position = 'relative';
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
    _panes = new Map<String, Element>();

    _mapPane = _panes['mapPane'] = _createPane('leaflet-map-pane', _container);

    _tilePane = _panes['tilePane'] = _createPane('leaflet-tile-pane', _mapPane);
    _panes['objectsPane'] = _createPane('leaflet-objects-pane', _mapPane);
    _panes['shadowPane'] = _createPane('leaflet-shadow-pane');
    _panes['overlayPane'] = _createPane('leaflet-overlay-pane');
    _panes['markerPane'] = _createPane('leaflet-marker-pane');
    _panes['popupPane'] = _createPane('leaflet-popup-pane');

    var zoomHide = ' leaflet-zoom-hide';

    if (!options.markerZoomAnimation) {
      _panes['markerPane'].classes.add(zoomHide);
      _panes['shadowPane'].classes.add(zoomHide);
      _panes['popupPane'].classes.add(zoomHide);
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
    if (layers == null) return;
    for (var i = 0, len = layers.length; i < len; i++) {
      addLayer(layers[i]);
    }
  }


  // private methods that modify map state

  void _resetView(LatLng center, num zoom, [bool preserveMapOffset=false, bool afterZoomAnim=false]) {
    print("_resetView");
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

    fireEvent(new ViewEvent(EventType.VIEWRESET, !preserveMapOffset));

    fire(EventType.MOVE);

    if (zoomChanged || afterZoomAnim) {
      fire(EventType.ZOOMEND);
    }

    fireEvent(new ViewEvent(EventType.MOVEEND, !preserveMapOffset));
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

    for (i in _zoomBoundLayers.keys) {
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

  void _panInsideMaxBounds([_]) {
    panInsideBounds(options.maxBounds);
  }

  void _checkIfLoaded() {
    if (!_loaded) {
      throw new Exception('Set map center and zoom first.');
    }
  }

  // map events

  StreamSubscription<Event> onResizeSubscription;
  StreamSubscription<html.MouseEvent> onClickSubscription;
  List<StreamSubscription> eventSubscriptions;

  void _initEvents([bool on = true]) {
    //if (DomEvent == null) { return; }

    if (on) {
      //dom.on(_container, 'click', _onMouseClick, this);
      onClickSubscription = _container.onClick.listen(_onMouseClick);
    } else {
      //dom.off(_container, 'click', _onMouseClick);//, this);
      if (onClickSubscription != null) {
        onClickSubscription.cancel();
      }
    }

    /*final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEUP,
                    EventType.MOUSEENTER, EventType.MOUSELEAVE, EventType.MOUSEMOVE,
                    EventType.CONTEXTMENU];

    for (int i = 0; i < events.length; i++) {
      if (on) {
        dom.on(_container, events[i], _fireMouseEvent, this);
      } else {
        dom.off(_container, events[i], _fireMouseEvent);//, this);
      }
    }*/
    if (on) {
      eventSubscriptions = [
        _container.onDoubleClick.listen(_fireMouseEvent),
        _container.onMouseDown.listen(_fireMouseEvent),
        _container.onMouseUp.listen(_fireMouseEvent),
        _container.onMouseEnter.listen(_fireMouseEvent),
        _container.onMouseLeave.listen(_fireMouseEvent),
        _container.onMouseMove.listen(_fireMouseEvent),
        _container.onContextMenu.listen(_fireMouseEvent)
      ];
    } else {
      if (eventSubscriptions != null) {
        eventSubscriptions.forEach((StreamSubscription subscription) {
          subscription.cancel();
        });
      }
    }

    if (options.trackResize) {
      if (on) {
        //dom.on(window, 'resize', _onResize, this);
        onResizeSubscription = window.onResize.listen(_onResize);
      } else {
        //dom.off(window, 'resize', _onResize);//, this);
        if (onResizeSubscription != null) {
          onResizeSubscription.cancel();
        }
      }
    }
  }

  int _resizeRequest;

  void _onResize(Event event) {
    if (_resizeRequest != null) window.cancelAnimationFrame(_resizeRequest);
    _resizeRequest = window.requestAnimationFrame((num highResTime) {
      invalidateSize(debounceMoveend: true);
    });
  }

  void _onMouseClick(html.MouseEvent e) {
    if (_loaded != true || (dom.simulated(e) != true && (
        (dragging != null && dragging.moved() == true) ||
        (boxZoom != null && boxZoom.moved() == true))) || dom.skipped(e) == true) {
      return;
    }

    fire(EventType.PRECLICK);
    _fireMouseEvent(e);
  }

  void _fireMouseEvent(Event e) {
    if (_loaded != true || dom.skipped(e) == true) {
      return;
    }

    final type = (e.type == 'mouseenter' ? EventType.MOUSEOVER : (e.type == 'mouseleave' ? EventType.MOUSEOUT : new EventType.from(e.type)));

    if (!hasEventListeners(type)) { return; }

    if (type == EventType.CONTEXTMENU) {
      e.preventDefault();
    }

    final containerPoint = mouseEventToContainerPoint(e),
        layerPoint = containerPointToLayerPoint(containerPoint),
        latlng = layerPointToLatLng(layerPoint);

    fireEvent(new MouseEvent(type, latlng, layerPoint, containerPoint, e));
  }

  void _onTileLayerLoad(_) {
    _tileLayersToLoad--;
    if (_tileLayersNum != 0 && _tileLayersToLoad == 0) {
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
  void whenReady(callback(MapEvent e)/*, [Object context=null]*/) {
    if (_loaded) {
      callback.call();//context == null ? this : context, this);
    } else {
      //on(EventType.LOAD, callback);//, context);
      onLoad.listen(callback);
    }
    return;
  }

  void _layerAdd(Layer layer) {
    layer.onAdd(this);
    fireEvent(new LayerEvent(EventType.LAYERADD, layer));
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
    final topLeft = _getNewTopLeftPoint(newCenter, newZoom) + _getMapPanePos();
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

  Map<ControlPosition, Element> _controlCorners;

  Map<ControlPosition, Element> get controlCorners => _controlCorners;

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

      final pos = new ControlPosition.fromString(vSide + hSide);
      corners[pos] = dom.create('div', className, container);
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

  bool _animatingZoom = false;
  bool _zoomAnimated = false;
  LatLng _animateToCenter;
  num _animateToZoom;

  bool get zoomAnimated => _zoomAnimated;

  /**
   * For internal use.
   */
  bool get animatingZoom => _animatingZoom;

  _catchTransitionEnd(e) {
    if (_animatingZoom && e.propertyName.indexOf('transform') >= 0) {
      _onZoomTransitionEnd();
    }
  }

  bool _nothingToAnimate() {
    return _container.querySelectorAll('.leaflet-zoom-animated').length == 0;
  }

  bool _tryAnimatedZoom(LatLng center, num zoom, [options=null]) {

    if (_animatingZoom) { return true; }

    options = options == null ? {} : options;

    // don't animate if disabled, not supported or zoom difference is too large
    if (!_zoomAnimated || options.animate == false || _nothingToAnimate() ||
            (zoom - _zoom).abs() > options.zoomAnimationThreshold) { return false; }

    // offset is the pixel coords of the zoom origin relative to the current center
    final scale = getZoomScale(zoom),
        offset = _getCenterOffset(center) / (1 - 1 / scale),
      origin = _getCenterLayerPoint() + offset;

    // don't animate if the zoom origin isn't within one screen from the current center, unless forced
    if (options.animate != true && !getSize().contains(offset)) { return false; }

    fire(EventType.MOVESTART);
    fire(EventType.ZOOMSTART);

    animateZoom(center, zoom, origin, scale, null, true);

    return true;
  }

  /**
   * For internal use.
   */
  void animateZoom(LatLng center, num zoom, Point2D origin, num scale, [Point2D delta=null, bool backwards=false]) {

    _animatingZoom = true;

    // Put transform transition on all layers with leaflet-zoom-animated class.
    _mapPane.classes.add('leaflet-zoom-anim');

    // Remember what center/zoom to set after animation.
    _animateToCenter = center;
    _animateToZoom = zoom;

    // Disable any dragging during animation.
    //if (L.Draggable) {
    dom.Draggable.disabled = true;
    //}

    fireEvent(new ZoomEvent(center, zoom, origin, scale, delta, backwards));
  }

  void _onZoomTransitionEnd() {

    _animatingZoom = false;

    _mapPane.classes.remove('leaflet-zoom-anim');

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
  void setView(LatLng center, num zoom, [ZoomPanOptions options=null, LatLngBounds maxBounds=null]) {
    print("setView");
    zoom = zoom == null ? _zoom : limitZoom(zoom);
    center = _limitCenter(new LatLng.latLng(center), zoom, /*options.*/maxBounds);
    //options = options || {};
    if (options != null) {
      options = new ZoomPanOptions();
    }

    if (_panAnim != null) {
      _panAnim.stop();
    }

    if (_loaded && !options.reset && options != true) {

      if (options.animate != null) {
        options.zoomOptions.animate = options.animate;// = L.extend({animate: options.animate}, options.zoom);
        options.panOptions.animate = options.animate;// = L.extend({animate: options.animate}, options.pan);
      }

      // try animating pan or zoom
      var animated = (_zoom != zoom) ?
        /*_tryAnimatedZoom &&*/ _tryAnimatedZoom(center, zoom, options.zoomOptions) :
        _tryAnimatedPan(center, options.panOptions);

      if (animated) {
        // prevent resize handler call, the view will refresh after animation anyway
        //clearTimeout(_sizeTimer);
        _sizeTimer.cancel();
        return;
      }
    }

    // animation didn't start, just reset the map view
    _resetView(center, zoom);
  }

  /**
   * Pans the map by a given number of pixels (animated).
   */
  void panBy(Point2D offset, [PanOptions options=null]) {
    offset = new Point2D.point(offset).rounded();
    //options = options == null ? {} : options;
    if (options == null) {
      options = new PanOptions();
    }

    if (offset.x == 0 && offset.y == 0) {
      return;
    }

    if (_panAnim == null) {
      _panAnim = new dom.PosAnimation();

      //_panAnim.on(EventType.STEP, _onPanTransitionStep);
      //_panAnim.on(EventType.END, _onPanTransitionEnd);
      _panAnim.onStep.listen(_onPanTransitionStep);
      _panAnim.onEnd.listen(_onPanTransitionEnd);
    }

    // don't fire movestart if animating inertia
    if (options.noMoveStart != true) {
      fire(EventType.MOVESTART);
    }

    // animate pan unless animate: false specified
    if (options.animate != false) {
      _mapPane.classes.add('leaflet-pan-anim');

      final newPos = _getMapPanePos() - offset;
      _panAnim.run(_mapPane, newPos, firstNonNull(options.duration, 0.25), options.easeLinearity);
    } else {
      _rawPanBy(offset);
      fire(EventType.MOVE);
      fire(EventType.MOVEEND);
    }
  }

  void _onPanTransitionStep(_) {
    fire(EventType.MOVE);
  }

  void _onPanTransitionEnd(_) {
    _mapPane.classes.remove('leaflet-pan-anim');
    fire(EventType.MOVEEND);
  }

  bool _tryAnimatedPan(LatLng center, options) {
    // Difference between the new and current centers in pixels.
    final offset = _getCenterOffset(center).floored();

    // Don't animate too far unless animate=true specified in options.
    if ((options != null && options.animate) != true && !getSize().contains(offset)) {
      return false;
    }

    panBy(offset, options);

    return true;
  }



  /* Convenient shortcuts for using browser geolocation features */

  /*var _defaultLocateOptions = {
    'watch': false,
    'setView': false,
    'maxZoom': double.INFINITY,
    'timeout': 10000,
    'maximumAge': 0,
    'enableHighAccuracy': false
  };*/

  LocateOptions _options;

  StreamSubscription<Geoposition> _locationWatchSubscription;

  /**
   * Tries to locate the user using the Geolocation API, firing a locationfound
   * event with location data on success or a locationerror event on failure,
   * and optionally sets the map view to the user's location with respect to
   * detection accuracy (or to the world view if geolocation failed).
   */
  void locate([LocateOptions options=null]) {
    if (options == null) {
      options = new LocateOptions();
    }

    //options = _options = L.extend(_defaultLocateOptions, options);

    if (window.navigator.geolocation == null) {
      _handleGeolocationError(0, 'Geolocation not supported.');
      return;
    }

//    var onResponse = L.bind(_handleGeolocationResponse, this),
//      onError = L.bind(_handleGeolocationError, this);

    if (options.watch) {
      _locationWatchSubscription =
              window.navigator.geolocation.watchPosition(enableHighAccuracy: options.enableHighAccuracy,
                  maximumAge: new Duration(milliseconds: options.maximumAge),
                  timeout: new Duration(milliseconds: options.timeout)).listen(_handleGeolocationResponse,
                      onError: _handlePositionError);
    } else {
      window.navigator.geolocation.getCurrentPosition(enableHighAccuracy: options.enableHighAccuracy,
          maximumAge: new Duration(milliseconds: options.maximumAge),
          timeout: new Duration(milliseconds: options.timeout)).then(_handleGeolocationResponse,
              onError: _handlePositionError);
    }
  }

  /**
   * Stops watching location previously initiated by map.locate(watch: true)
   * and aborts resetting the map view if map.locate was called with
   * (setView: true).
   */
  void stopLocate() {
    if (window.navigator.geolocation != null) {
      //window.navigator.geolocation.clearWatch(_locationWatchId);
      _locationWatchSubscription.cancel();
    }
    if (_options != null) {
      _options.setView = false;
    }
  }

  void _handlePositionError(PositionError error) {
    _handleGeolocationError(error.code, error.message);
  }

  void _handleGeolocationError(int c, String message) {
    if (message == null) {
      message = (c == 1 ? 'permission denied' :
                (c == 2 ? 'position unavailable' : 'timeout'));
    }

    if (_options.setView && !_loaded) {
      fitWorld();
    }

    fireEvent(new ErrorEvent(EventType.LOCATIONERROR, c, 'Geolocation error: $message.'));
  }

  void _handleGeolocationResponse(Geoposition pos) {
    final lat = pos.coords.latitude,
        lng = pos.coords.longitude,
        latlng = new LatLng(lat, lng),

        latAccuracy = 180 * pos.coords.accuracy / 40075017,
        lngAccuracy = latAccuracy / math.cos(LatLng.DEG_TO_RAD * lat),

        bounds = new LatLngBounds.between(
                new LatLng(lat - latAccuracy, lng - lngAccuracy),
                new LatLng(lat + latAccuracy, lng + lngAccuracy)),

        options = _options;

    if (options.setView) {
      final zoom = math.min(getBoundsZoom(bounds), options.maxZoom);
      setView(latlng, zoom);
    }

    fireEvent(new LocationEvent(latlng, bounds, pos.coords.accuracy,
        pos.coords.altitude, pos.coords.altitudeAccuracy, pos.coords.heading,
        pos.coords.speed, pos.timestamp));

    /*for (var i in pos.coords) {
      if (pos.coords[i] is num) {
        data[i] = pos.coords[i];
      }
    }*/

    //fire(event);
  }


  /* Path extensions */

  Bounds _pathViewport;

  Bounds get pathViewport => _pathViewport;

  void _updatePathViewport() {
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
    CanvasElement root = _pathRoot;

    if (root == null) {
      root = _pathRoot = new CanvasElement();//document.createElement('canvas');
      root.style.position = 'absolute';
      final ctx = _canvasCtx = root.context2D;//getContext('2d');

      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';

      _panes['overlayPane'].append(root);

      if (options.zoomAnimation) {
        _pathRoot.className = 'leaflet-zoom-animated';
        //on(EventType.ZOOMANIM, _animatePathZoom);
        //on(EventType.ZOOMEND, _endPathZoom);
        onZoomStart.listen(_animatePathZoom);
        onZoomEnd.listen(_endPathZoom);
      }
      //on(EventType.MOVEEND, _updateCanvasViewport);
      onMoveEnd.listen(_updateCanvasViewport);
      _updateCanvasViewport();
    }
  }

  void _updateCanvasViewport([_]) {
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
      _pathRoot = new SvgSvgElement();//Path.prototype._createElement('svg');
      _panes['overlayPane'].append(_pathRoot);

        _pathRoot.classes.add('leaflet-zoom-animated');

      //on(EventType.ZOOMANIM, _animatePathZoom);
      //on(EventType.ZOOMEND, _endPathZoom);
      onZoomStart.listen(_animatePathZoom);
      onZoomEnd.listen(_endPathZoom);

      //on(EventType.MOVEEND, _updateSvgViewport);
      onMoveEnd.listen(_updateSvgViewport);
      _updateSvgViewport();
    }
  }

  void _animatePathZoom(ZoomEvent e) {
    final scale = getZoomScale(e.zoom),
        offset = _getCenterOffset(e.center) * (-scale) + _pathViewport.min;

    _pathRoot.style.transform = //[dom.TRANSFORM] =
            '${dom.getTranslateString(offset)} scale($scale) ';

    _pathZooming = true;
  }

  void _endPathZoom(_) {
    _pathZooming = false;
  }

  void _updateSvgViewport([_]) {

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
    if (browser.mobileWebkit) {
      //pane.removeChild(root);
      root.remove();
    }

    dom.setPosition(root, min);
    root.setAttribute('width', width.toString());
    root.setAttribute('height', height.toString());
    root.setAttribute('viewBox', [min.x, min.y, width, height].join(' '));

    if (browser.mobileWebkit) {
      pane.append(root);
    }
  }

  /* Events */

  void fire(EventType eventType) {
    final event = new MapEvent(eventType);
    fireEvent(event);
  }

  void fireEvent(MapEvent event) {
      switch (event.type) {
      case EventType.CLICK:
        _clickController.add(event);
        break;
      case EventType.DBLCLICK:
        _dblClickController.add(event);
        break;
      case EventType.MOUSEDOWN:
        _mouseDownController.add(event);
        break;
      case EventType.MOUSEUP:
        _mouseUpController.add(event);
        break;
      case EventType.MOUSEOVER:
        _mouseOverController.add(event);
        break;
      case EventType.MOUSEOUT:
        _mouseOutController.add(event);
        break;
      case EventType.MOUSEMOVE:
        _mouseMoveController.add(event);
        break;
      case EventType.PRECLICK:
        _preClickController.add(event);
        break;
      case EventType.DRAGEND:
        _dragEndController.add(event);
        break;
      case EventType.RESIZE:
        _resizeController.add(event);
        break;
      case EventType.LAYERADD:
        _layerAddController.add(event);
        break;
      case EventType.LAYERREMOVE:
        _layerRemoveController.add(event);
        break;
      case EventType.BASELAYERCHANGE:
        _baseLayerChangeController.add(event);
        break;
      case EventType.OVERLAYADD:
        _overlayAddController.add(event);
        break;
      case EventType.OVERLAYREMOVE:
        _overlayRemoveController.add(event);
        break;
      case EventType.LOCATIONFOUND:
        _locationFoundController.add(event);
        break;
      case EventType.LOCATIONERROR:
        _locationErrorController.add(event);
        break;
      case EventType.POPUPOPEN:
        _popupOpenController.add(event);
        break;
      case EventType.POPUPCLOSE:
        _popupCloseController.add(event);
        break;
      case EventType.FOCUS:
        _focusController.add(event);
        break;
      case EventType.BLUR:
        _blurController.add(event);
        break;
      case EventType.LOAD:
        _loadController.add(event);
        break;
      case EventType.UNLOAD:
        _unloadController.add(event);
        break;
      case EventType.VIEWRESET:
        _viewResetController.add(event);
        break;
      case EventType.MOVESTART:
        _moveStartController.add(event);
        break;
      case EventType.MOVE:
        _moveController.add(event);
        break;
      case EventType.MOVEEND:
        _moveEndController.add(event);
        break;
      case EventType.DRAGSTART:
        _dragStartController.add(event);
        break;
      case EventType.DRAG:
        _dragController.add(event);
        break;
      case EventType.ZOOMSTART:
        _zoomStartController.add(event);
        break;
      case EventType.ZOOMEND:
        _zoomEndController.add(event);
        break;
      case EventType.ZOOMLEVELSCHANGE:
        _zoomLevelsChangeController.add(event);
        break;
      case EventType.AUTOPANSTART:
        _autoPanStartController.add(event);
        break;
    }
    /*if (event is MouseEvent) {
      switch (event.type) {
        case EventType.CLICK:
          _clickController.add(event);
          break;
        case EventType.DBLCLICK:
          _dblClickController.add(event);
          break;
        case EventType.MOUSEDOWN:
          _mouseDownController.add(event);
          break;
        case EventType.MOUSEUP:
          _mouseUpController.add(event);
          break;
        case EventType.MOUSEOVER:
          _mouseOverController.add(event);
          break;
        case EventType.MOUSEOUT:
          _mouseOutController.add(event);
          break;
        case EventType.MOUSEMOVE:
          _mouseMoveController.add(event);
          break;
        case EventType.PRECLICK:
          _preClickController.add(event);
          break;
      }
    } else if (event is DragEndEvent) {
      switch (event.type) {
        case EventType.DRAGEND:
          _dragEndController.add(event);
          break;
      }
    } else if (event is ResizeEvent) {
      switch (event.type) {
        case EventType.RESIZE:
          _resizeController.add(event);
          break;
      }
    } else if (event is LayerEvent) {
      switch (event.type) {
        case EventType.LAYERADD:
          _layerAddController.add(event);
          break;
        case EventType.LAYERREMOVE:
          _layerRemoveController.add(event);
          break;
      }
    } else if (event is LayersControlEvent) {
      switch (event.type) {
        case EventType.BASELAYERCHANGE:
          _baseLayerChangeController.add(event);
          break;
        case EventType.OVERLAYADD:
          _overlayAddController.add(event);
          break;
        case EventType.OVERLAYREMOVE:
          _overlayRemoveController.add(event);
          break;
      }
    } else if (event is LocationEvent) {
      switch (event.type) {
        case EventType.LOCATIONFOUND:
          _locationFoundController.add(event);
          break;
      }
    } else if (event is ErrorEvent) {
      switch (event.type) {
        case EventType.LOCATIONERROR:
          _locationErrorController.add(event);
          break;
      }
    } else if (event is PopupEvent) {
      switch (event.type) {
        case EventType.POPUPOPEN:
          _popupOpenController.add(event);
          break;
        case EventType.POPUPCLOSE:
          _popupCloseController.add(event);
          break;
      }
    } else {
      switch (event.type) {
        case EventType.FOCUS:
          _focusController.add(event);
          break;
        case EventType.BLUR:
          _blurController.add(event);
          break;
        case EventType.LOAD:
          _loadController.add(event);
          break;
        case EventType.UNLOAD:
          _unloadController.add(event);
          break;
        case EventType.VIEWRESET:
          _viewResetController.add(event);
          break;
        case EventType.MOVESTART:
          _moveStartController.add(event);
          break;
        case EventType.MOVE:
          _moveController.add(event);
          break;
        case EventType.MOVEEND:
          _moveEndController.add(event);
          break;
        case EventType.DRAGSTART:
          _dragStartController.add(event);
          break;
        case EventType.DRAG:
          _dragController.add(event);
          break;
        case EventType.ZOOMSTART:
          _zoomStartController.add(event);
          break;
        case EventType.ZOOMEND:
          _zoomEndController.add(event);
          break;
        case EventType.ZOOMLEVELSCHANGE:
          _zoomLevelsChangeController.add(event);
          break;
        case EventType.AUTOPANSTART:
          _autoPanStartController.add(event);
          break;
      }
    }*/
  }

  StreamController<MouseEvent> _clickController = new StreamController.broadcast();
  StreamController<MouseEvent> _dblClickController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseDownController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseUpController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOverController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOutController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseMoveController = new StreamController.broadcast();
  StreamController<MouseEvent> _contextMenuController = new StreamController.broadcast();
  StreamController<MapEvent> _focusController = new StreamController.broadcast();
  StreamController<MapEvent> _blurController = new StreamController.broadcast();
  StreamController<MouseEvent> _preClickController = new StreamController.broadcast();
  StreamController<MapEvent> _loadController = new StreamController.broadcast();
  StreamController<MapEvent> _unloadController = new StreamController.broadcast();
  StreamController<MapEvent> _viewResetController = new StreamController.broadcast();
  StreamController<MapEvent> _moveStartController = new StreamController.broadcast();
  StreamController<MapEvent> _moveController = new StreamController.broadcast();
  StreamController<MapEvent> _moveEndController = new StreamController.broadcast();
  StreamController<MapEvent> _dragStartController = new StreamController.broadcast();
  StreamController<MapEvent> _dragController = new StreamController.broadcast();
  StreamController<DragEndEvent> _dragEndController = new StreamController.broadcast();
  StreamController<MapEvent> _zoomStartController = new StreamController.broadcast();
  StreamController<MapEvent> _zoomEndController = new StreamController.broadcast();
  StreamController<MapEvent> _zoomLevelsChangeController = new StreamController.broadcast();
  StreamController<ResizeEvent> _resizeController = new StreamController.broadcast();
  StreamController<MapEvent> _autoPanStartController = new StreamController.broadcast();
  StreamController<LayerEvent> _layerAddController = new StreamController.broadcast();//(sync: true);
  StreamController<LayerEvent> _layerRemoveController = new StreamController.broadcast();//(sync: true);
  StreamController<LayersControlEvent> _baseLayerChangeController = new StreamController.broadcast();
  StreamController<LayersControlEvent> _overlayAddController = new StreamController.broadcast();
  StreamController<LayersControlEvent> _overlayRemoveController = new StreamController.broadcast();
  StreamController<LocationEvent> _locationFoundController = new StreamController.broadcast();
  StreamController<ErrorEvent> _locationErrorController = new StreamController.broadcast();
  StreamController<PopupEvent> _popupOpenController = new StreamController.broadcast();
  StreamController<PopupEvent> _popupCloseController = new StreamController.broadcast();

  Stream<MouseEvent> get onClick => _clickController.stream;
  Stream<MouseEvent> get onDblClick => _dblClickController.stream;
  Stream<MouseEvent> get onMouseDown => _mouseDownController.stream;
  Stream<MouseEvent> get onMouseUp => _mouseUpController.stream;
  Stream<MouseEvent> get onMouseOver => _mouseOverController.stream;
  Stream<MouseEvent> get onMouseOut => _mouseOutController.stream;
  Stream<MouseEvent> get onMouseMove => _mouseMoveController.stream;
  Stream<MouseEvent> get onContextMenu => _contextMenuController.stream;
  Stream<MapEvent> get onFocus => _focusController.stream;
  Stream<MapEvent> get onBlur => _blurController.stream;
  Stream<MouseEvent> get onPreClick => _preClickController.stream;
  Stream<MapEvent> get onLoad => _loadController.stream;
  Stream<MapEvent> get onUnload => _unloadController.stream;
  Stream<MapEvent> get onViewReset => _viewResetController.stream;
  Stream<MapEvent> get onMoveStart => _moveStartController.stream;
  Stream<MapEvent> get onMove => _moveController.stream;
  Stream<MapEvent> get onMoveEnd => _moveEndController.stream;
  Stream<MapEvent> get onDragStart => _dragStartController.stream;
  Stream<MapEvent> get onDrag => _dragController.stream;
  Stream<DragEndEvent> get onDragEnd => _dragEndController.stream;
  Stream<MapEvent> get onZoomStart => _zoomStartController.stream;
  Stream<MapEvent> get onZoomEnd => _zoomEndController.stream;
  Stream<MapEvent> get onZoomLevelsChange => _zoomLevelsChangeController.stream;
  Stream<ResizeEvent> get onResize => _resizeController.stream;
  Stream<MapEvent> get onAutoPanStart => _autoPanStartController.stream;
  Stream<LayerEvent> get onLayerAdd => _layerAddController.stream;
  Stream<LayerEvent> get onLayerRemove => _layerRemoveController.stream;
  Stream<LayersControlEvent> get onBaseLayerChange => _baseLayerChangeController.stream;
  Stream<LayersControlEvent> get onOverlayAdd => _overlayAddController.stream;
  Stream<LayersControlEvent> get onOverlayRemove => _overlayRemoveController.stream;
  Stream<LocationEvent> get onLocationFound => _locationFoundController.stream;
  Stream<ErrorEvent> get onLocationError => _locationErrorController.stream;
  Stream<PopupEvent> get onPopupOpen => _popupOpenController.stream;
  Stream<PopupEvent> get onPopupClose => _popupCloseController.stream;

}
