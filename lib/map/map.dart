library map;

import 'dart:html';
import 'dart:math' as math;

class BaseMap {
  Map<String, Object> options = {
    'crs': crs.EPSG3857,
    'fadeAnimation': DomUtil.TRANSITION && !Browser.android23,
    'trackResize': true,
    'markerZoomAnimation': DomUtil.TRANSITION && Browser.any3d
  };

  List _handlers;

  Map _layers;
  Map _zoomBoundLayers;
  int _tileLayersNum;

  factory BaseMap.elem(Element id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }

  factory BaseMap.id(String id, Map<String, Object> options) {
    return new BaseMap(id, options);
  }

  BaseMap(var id, Map<String, Object> options) {
    this.options.addAll(options);


    this._initContainer(id);
    this._initLayout();

    // hack for https://github.com/Leaflet/Leaflet/issues/1980
//    this._onResize = L.bind(this._onResize, this);

    this._initEvents();

    if (options.containsKey('maxBounds')) {
      this.setMaxBounds(options['maxBounds']);
    }

    if (options.containsKey('center') && options['zoom'] != null) {
      this.setView(geo.latLng(options['center']), options['zoom'], {'reset': true});
    }

    this._handlers = [];

    this._layers = {};
    this._zoomBoundLayers = {};
    this._tileLayersNum = 0;

    this.callInitHooks();

    this._addLayers(options['layers']);
  }


  // public methods that modify map state

  // replaced by animation-powered implementation in Map.PanAnimation.js
  setView(center, zoom, Map options) {
    zoom = zoom == null ? this.getZoom() : zoom;
    this._resetView(geo.latLng(center), this._limitZoom(zoom));
    return this;
  }

  var _zoom;

  setZoom(zoom, options) {
    if (!this._loaded) {
      this._zoom = this._limitZoom(zoom);
      return this;
    }
    return this.setView(this.getCenter(), zoom, {zoom: options});
  }

  zoomIn(delta, options) {
    return this.setZoom(this._zoom + (delta || 1), options);
  }

  zoomOut(delta, options) {
    return this.setZoom(this._zoom - (delta || 1), options);
  }

  setZoomAround(latlng, zoom, options) {
    var scale = this.getZoomScale(zoom),
        viewHalf = this.getSize().divideBy(2),
        containerPoint = latlng is Point ? latlng : this.latLngToContainerPoint(latlng),

        centerOffset = containerPoint.subtract(viewHalf).multiplyBy(1 - 1 / scale),
        newCenter = this.containerPointToLatLng(viewHalf.add(centerOffset));

    return this.setView(newCenter, zoom, {zoom: options});
  }

  fitBounds(bounds, options) {

    options = options || {};
    bounds = bounds.getBounds ? bounds.getBounds() : L.latLngBounds(bounds);

    var paddingTL = L.point(options.paddingTopLeft || options.padding || [0, 0]),
        paddingBR = L.point(options.paddingBottomRight || options.padding || [0, 0]),

        zoom = this.getBoundsZoom(bounds, false, paddingTL.add(paddingBR)),
        paddingOffset = paddingBR.subtract(paddingTL).divideBy(2),

        swPoint = this.project(bounds.getSouthWest(), zoom),
        nePoint = this.project(bounds.getNorthEast(), zoom),
        center = this.unproject(swPoint.add(nePoint).divideBy(2).add(paddingOffset), zoom);

    zoom = options && options.maxZoom ? Math.min(options.maxZoom, zoom) : zoom;

    return this.setView(center, zoom, options);
  }

  fitWorld(options) {
    return this.fitBounds([[-90, -180], [90, 180]], options);
  }

  panTo(center, options) { // (LatLng)
    return this.setView(center, this._zoom, {pan: options});
  }

  panBy(offset) { // (Point)
    // replaced with animated panBy in Map.PanAnimation.js
    this.fire('movestart');

    this._rawPanBy(L.point(offset));

    this.fire('move');
    return this.fire('moveend');
  }

  setMaxBounds(bounds) {
    bounds = L.latLngBounds(bounds);

    this.options.maxBounds = bounds;

    if (!bounds) {
      return this.off('moveend', this._panInsideMaxBounds, this);
    }

    if (this._loaded) {
      this._panInsideMaxBounds();
    }

    return this.on('moveend', this._panInsideMaxBounds, this);
  }

  panInsideBounds(bounds, options) {
    var center = this.getCenter(),
      newCenter = this._limitCenter(center, this._zoom, bounds);

    if (center.equals(newCenter)) { return this; }

    return this.panTo(newCenter, options);
  }

  addLayer(layer) {
    // TODO method is too big, refactor

    var id = L.stamp(layer);

    if (this._layers[id]) { return this; }

    this._layers[id] = layer;

    // TODO getMaxZoom, getMinZoom in ILayer (instead of options)
    if (layer.options && (!isNaN(layer.options.maxZoom) || !isNaN(layer.options.minZoom))) {
      this._zoomBoundLayers[id] = layer;
      this._updateZoomLevels();
    }

    // TODO looks ugly, refactor!!!
    if (this.options.zoomAnimation && L.TileLayer && (layer is L.TileLayer)) {
      this._tileLayersNum++;
      this._tileLayersToLoad++;
      layer.on('load', this._onTileLayerLoad, this);
    }

    if (this._loaded) {
      this._layerAdd(layer);
    }

    return this;
  }

  removeLayer(layer) {
    var id = L.stamp(layer);

    if (!this._layers[id]) { return this; }

    if (this._loaded) {
      layer.onRemove(this);
    }

    delete(this._layers[id]);

    if (this._loaded) {
      this.fire('layerremove', {layer: layer});
    }

    if (this._zoomBoundLayers[id]) {
      delete(this._zoomBoundLayers[id]);
      this._updateZoomLevels();
    }

    // TODO looks ugly, refactor
    if (this.options.zoomAnimation && L.TileLayer && (layer is L.TileLayer)) {
      this._tileLayersNum--;
      this._tileLayersToLoad--;
      layer.off('load', this._onTileLayerLoad, this);
    }

    return this;
  }

  hasLayer(layer) {
    if (!layer) { return false; }

    return this._layers.contains(L.stamp(layer));
  }

  eachLayer(method, context) {
    for (var i in this._layers) {
      method.call(context, this._layers[i]);
    }
    return this;
  }

  invalidateSize(options) {
    if (!this._loaded) { return this; }

    options = L.extend({
      animate: false,
      pan: true
    }, options == true ? {animate: true} : options);

    var oldSize = this.getSize();
    this._sizeChanged = true;
    this._initialCenter = null;

    var newSize = this.getSize(),
        oldCenter = oldSize.divideBy(2).round(),
        newCenter = newSize.divideBy(2).round(),
        offset = oldCenter.subtract(newCenter);

    if (!offset.x && !offset.y) { return this; }

    if (options.animate && options.pan) {
      this.panBy(offset);

    } else {
      if (options.pan) {
        this._rawPanBy(offset);
      }

      this.fire('move');

      if (options.debounceMoveend) {
        clearTimeout(this._sizeTimer);
        this._sizeTimer = setTimeout(L.bind(this.fire, this, 'moveend'), 200);
      } else {
        this.fire('moveend');
      }
    }

    return this.fire('resize', {
      oldSize: oldSize,
      newSize: newSize
    });
  }

  // TODO handler.addTo
  addHandler(name, HandlerClass) {
    if (!HandlerClass) { return this; }

    var handler = this[name] = new HandlerClass(this);

    this._handlers.push(handler);

    if (this.options[name]) {
      handler.enable();
    }

    return this;
  }

  remove() {
    if (this._loaded) {
      this.fire('unload');
    }

    this._initEvents('off');

    try {
      // throws error in IE6-8
      delete(this._container._leaflet);
    } catch (e) {
      this._container._leaflet = undefined;
    }

    this._clearPanes();
    if (this._clearControlPos) {
      this._clearControlPos();
    }

    this._clearHandlers();

    return this;
  }


  // public methods for getting map state

  getCenter() { // (Boolean) -> LatLng
    this._checkIfLoaded();

    if (this._initialCenter && !this._moved()) {
      return this._initialCenter;
    }
    return this.layerPointToLatLng(this._getCenterLayerPoint());
  }

  getZoom() {
    return this._zoom;
  }

  getBounds() {
    var bounds = this.getPixelBounds(),
        sw = this.unproject(bounds.getBottomLeft()),
        ne = this.unproject(bounds.getTopRight());

    return new L.LatLngBounds(sw, ne);
  }

  getMinZoom() {
    return this.options.minZoom == null ?
      (this._layersMinZoom == null ? 0 : this._layersMinZoom) :
      this.options.minZoom;
  }

  getMaxZoom() {
    return this.options.maxZoom == null ?
      (this._layersMaxZoom == null ? Infinity : this._layersMaxZoom) :
      this.options.maxZoom;
  }

  getBoundsZoom(bounds, inside, padding) { // (LatLngBounds[, Boolean, Point]) -> Number
    bounds = L.latLngBounds(bounds);

    var zoom = this.getMinZoom() - (inside ? 1 : 0),
        maxZoom = this.getMaxZoom(),
        size = this.getSize(),

        nw = bounds.getNorthWest(),
        se = bounds.getSouthEast(),

        zoomNotFound = true,
        boundsSize;

    padding = L.point(padding || [0, 0]);

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

  getSize() {
    if (!this._size || this._sizeChanged) {
      this._size = new L.Point(
        this._container.clientWidth,
        this._container.clientHeight);

      this._sizeChanged = false;
    }
    return this._size.clone();
  }

  getPixelBounds() {
    var topLeftPoint = this._getTopLeftPoint();
    return new L.Bounds(topLeftPoint, topLeftPoint.add(this.getSize()));
  }

  getPixelOrigin() {
    this._checkIfLoaded();
    return this._initialTopLeftPoint;
  }

  getPanes() {
    return this._panes;
  }

  getContainer() {
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

  project(latlng, zoom) { // (LatLng[, Number]) -> Point
    zoom = zoom == null ? this._zoom : zoom;
    return this.options.crs.latLngToPoint(L.latLng(latlng), zoom);
  }

  unproject(point, zoom) { // (Point[, Number]) -> LatLng
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

  var _container;

  _initContainer(id) {
    var container = this._container = L.DomUtil.get(id);

    if (!container) {
      throw new Exception('Map container not found.');
    } else if (container._leaflet) {
      throw new Exception('Map container is already initialized.');
    }

    container._leaflet = true;
  }

  _initLayout() {
    var container = this._container;

    L.DomUtil.addClass(container, 'leaflet-container' +
      (core.Browser.touch ? ' leaflet-touch' : '') +
      (core.Browser.retina ? ' leaflet-retina' : '') +
      (core.Browser.ielt9 ? ' leaflet-oldie' : '') +
      (this.options['fadeAnimation'] ? ' leaflet-fade-anim' : ''));

    var position = dom.DomUtil.getStyle(container, 'position');

    if (position != 'absolute' && position != 'relative' && position != 'fixed') {
      container.style.position = 'relative';
    }

    this._initPanes();

    if (this._initControlPos) {
      this._initControlPos();
    }
  }

  Map _panes;
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
      L.DomUtil.setPosition(this._mapPane, new L.Point(0, 0));
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

  _panInsideMaxBounds() {
    this.panInsideBounds(this.options.maxBounds);
  }

  _checkIfLoaded() {
    if (!this._loaded) {
      throw new Error('Set map center and zoom first.');
    }
  }

  // map events

  _initEvents([String onOff='on']) {
    if (dom.DomEvent == null) { return; }

    if (onOff == 'on') {
      dom.DomEvent.on(this._container, 'click', this._onMouseClick, this);
    } else {
      dom.DomEvent.off(this._container, 'click', this._onMouseClick, this);
    }

    var events = ['dblclick', 'mousedown', 'mouseup', 'mouseenter',
                  'mouseleave', 'mousemove', 'contextmenu'],
        i, len;

    len = events.length;
    for (i = 0; i < len; i++) {
      L.DomEvent[onOff](this._container, events[i], this._fireMouseEvent, this);
    }

    if (this.options.trackResize) {
      L.DomEvent[onOff](window, 'resize', this._onResize, this);
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

  _onTileLayerLoad() {
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

  _latLngToNewLayerPoint(latlng, newZoom, newCenter) {
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

    return new L.Point(dx, dy);
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