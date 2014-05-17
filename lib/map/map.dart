library leaflet.map;

import 'dart:html';
import 'dart:math' as math;

import '../core/core.dart';
import '../dom/dom.dart';

class MapStateOptions {
  // Initial geographical center of the map.
  LatLng center = null;

  // Initial map zoom.
  num zoom = null;

  // Layers that will be added to the map initially.
  List<Layer> layers = null;

  // Minimum zoom level of the map. Overrides any minZoom set on map layers.
  num minZoom = null;

  // Maximum zoom level of the map. This overrides any maxZoom set on map layers.
  num maxZoom = null;

  // When this option is set, the map restricts the view to the given
  // geographical bounds, bouncing the user back when he tries to pan outside
  //the view. To set the restriction dynamically, use setMaxBounds method.
  LatLngBounds maxBounds = null;

  // Coordinate Reference System to use. Don't change this if you're not sure
  // what it means.
  CRS crs = crs.EPSG3857;
}

class InteractionOptions {
  // Whether the map be draggable with mouse/touch or not.
  bool dragging  = true;

  // Whether the map can be zoomed by touch-dragging with two fingers.
  bool touchZoom   = true;

  // Whether the map can be zoomed by using the mouse wheel. If passed
  // 'center', it will zoom to the center of the view regardless of where
  // the mouse was.
  bool scrollWheelZoom   = true;

  // Whether the map can be zoomed in by double clicking on it and zoomed out
  // by double clicking while holding shift. If passed 'center', double-click
  // zoom will zoom to the center of the view regardless of where the mouse
  // was.
  bool doubleClickZoom   = true;

  // Whether the map can be zoomed to a rectangular area specified by dragging
  // the mouse while pressing shift.
  bool boxZoom   = true;

  // Enables mobile hacks for supporting instant taps (fixing 200ms click delay
  // on iOS/Android) and touch holds (fired as contextmenu events).
  bool tap   = true;

  // The max number of pixels a user can shift his finger during touch for it
  // to be considered a valid tap.
  num tapTolerance  = 15;

  // Whether the map automatically handles browser window resize to update
  // itself.
  bool trackResize   = true;

  // With this option enabled, the map tracks when you pan to another "copy"
  // of the world and seamlessly jumps to the original one so that all overlays
  // like markers and vector layers are still visible.
  bool worldCopyJump   = false;

  // Set it to false if you don't want popups to close when user clicks the map.
  bool closePopupOnClick   = true;

  // Set it to false if you don't want the map to zoom beyond min/max zoom and
  // then bounce back when pinch-zooming.
  bool bounceAtZoomLimits  = true;
}

class KeyboardNavigationOptions {
  // Makes the map focusable and allows users to navigate the map with keyboard
  // arrows and +/- keys.
  bool keyboard  = true;

  // Amount of pixels to pan when pressing an arrow key.
  num keyboardPanOffset   = 80;

  // Number of zoom levels to change when pressing + or - key.
  num keyboardZoomOffset  = 1;
}

class PanningInertiaOptions {
  // If enabled, panning of the map will have an inertia effect where the map
  // builds momentum while dragging and continues moving in the same direction
  // for some time. Feels especially nice on touch devices.
  bool inertia   = true;

  // The rate with which the inertial movement slows down, in pixels/second2.
  num inertiaDeceleration   = 3000;

  // Max speed of the inertial movement, in pixels/second.
  num inertiaMaxSpeed   = 1500;

  // Number of milliseconds that should pass between stopping the movement and
  // releasing the mouse or touch to prevent inertial movement. 32 for touch
  // devices and 14 for the rest by default.
  num inertiaThreshold;
}

class ControlOptions {
  // Whether the zoom control is added to the map by default.
  bool zoomControl   = true;

  // Whether the attribution control is added to the map by default.
  bool attributionControl  = true;
}

class AnimationOptions {
  // Whether the tile fade animation is enabled. By default it's enabled in
  // all browsers that support CSS3 Transitions except Android.
  bool fadeAnimation;

  // Whether the tile zoom animation is enabled. By default it's enabled in
  // all browsers that support CSS3 Transitions except Android.
  bool zoomAnimation;

  // Won't animate zoom if the zoom difference exceeds this value.
  num zoomAnimationThreshold  = 4;

  // Whether markers animate their zoom with the zoom animation, if disabled
  // they will disappear for the length of the animation. By default it's
  // enabled in all browsers that support CSS3 Transitions except Android.
  bool markerZoomAnimation;
}

class EventType {
  final _value;
  const EventType._internal(this._value);
  toString() => '$_value';

  // Fired when the user clicks (or taps) the map.
  static const CLICK  = const EventType._internal('click');
  // Fired when the user double-clicks (or double-taps) the map.
  static const DBLCLICK  = const EventType._internal('dblclick');
  // Fired when the user pushes the mouse button on the map.
  static const MOUSEDOWN  = const EventType._internal('mousedown');
  // Fired when the user pushes the mouse button on the map.
  static const MOUSEUP  = const EventType._internal('mouseup');
  // Fired when the mouse enters the map.
  static const MOUSEOVER  = const EventType._internal('mouseover');
  // Fired when the mouse leaves the map.
  static const MOUSEOUT  = const EventType._internal('mouseout');
  // Fired while the mouse moves over the map.
  static const MOUSEMOVE  = const EventType._internal('mousemove');
  // Fired when the user pushes the right mouse button on the map, prevents
  // default browser context menu from showing if there are listeners on this
  // event. Also fired on mobile when the user holds a single touch for a
  // second (also called long press).
  static const CONTEXTMENU  = const EventType._internal('contextmenu');
  // Fired when the user focuses the map either by tabbing to it or
  // clicking/panning.
  static const FOCUS  = const EventType._internal('focus');
  // Fired when the map looses focus.
  static const BLUR  = const EventType._internal('blur');
  // Fired before mouse click on the map (sometimes useful when you want
  // something to happen on click before any existing click handlers start
  // running).
  static const PRECLICK  = const EventType._internal('preclick');
  // Fired when the map is initialized (when its center and zoom are set for
  // the first time).
  static const LOAD  = const EventType._internal('load');
  // Fired when the map is destroyed with remove method.
  static const UNLOAD  = const EventType._internal('unload');
  // Fired when the map needs to redraw its content (this usually happens on
  // map zoom or load). Very useful for creating custom overlays.
  static const VIEWRESET  = const EventType._internal('viewreset');
  // Fired when the view of the map starts changing (e.g. user starts dragging
  // the map).
  static const MOVESTART  = const EventType._internal('movestart');
  // Fired on any movement of the map view.
  static const MOVE  = const EventType._internal('move');
  // Fired when the view of the map ends changed (e.g. user stopped dragging
  // the map).
  static const MOVEEND  = const EventType._internal('moveend');
  // Fired when the user starts dragging the map.
  static const DRAGSTART  = const EventType._internal('dragstart');
  // Fired repeatedly while the user drags the map.
  static const DRAG  = const EventType._internal('drag');
  // Fired when the user stops dragging the map.
  static const DRAGEND  = const EventType._internal('dragend');
  // Fired when the map zoom is about to change (e.g. before zoom animation).
  static const ZOOMSTART  = const EventType._internal('zoomstart');
  // Fired when the map zoom changes.
  static const ZOOMEND  = const EventType._internal('zoomend');
  // Fired when the number of zoomlevels on the map is changed due to adding
  // or removing a layer.
  static const ZOOMLEVELSCHANGE  = const EventType._internal('zoomlevelschange');
  // Fired when the map is resized.
  static const RESIZE  = const EventType._internal('resize');
  // Fired when the map starts autopanning when opening a popup.
  static const AUTOPANSTART  = const EventType._internal('autopanstart');
  // Fired when a new layer is added to the map.
  static const LAYERADD  = const EventType._internal('layeradd');
  // Fired when some layer is removed from the map.
  static const LAYERREMOVE  = const EventType._internal('layerremove');
  // Fired when the base layer is changed through the layer control.
  static const BASELAYERCHANGE  = const EventType._internal('baselayerchange');
  // Fired when an overlay is selected through the layer control.
  static const OVERLAYADD  = const EventType._internal('overlayadd');
  // Fired when an overlay is deselected through the layer control.
  static const OVERLAYREMOVE  = const EventType._internal('overlayremove');
  // Fired when geolocation (using the locate method) went successfully.
  static const LOCATIONFOUND  = const EventType._internal('locationfound');
  // Fired when geolocation (using the locate method) failed.
  static const LOCATIONERROR  = const EventType._internal('locationerror');
  // Fired when a popup is opened (using openPopup method).
  static const POPUPOPEN  = const EventType._internal('popupopen');
  // Fired when a popup is closed (using closePopup method).
  static const POPUPCLOSE  = const EventType._internal('popupclose');
}

class Event {
  // The event type (e.g. 'click').
  EventType type;
  // The object that fired the event.
  Object target;
}

class MouseEvent extends Event {
  // The geographical point where the mouse event occured.
  LatLng latlng;
  // Pixel coordinates of the point where the mouse event occured relative to the map layer.
  Point   layerPoint;
  // Pixel coordinates of the point where the mouse event occured relative to the map сontainer.
  Point   containerPoint;
  // The original DOM mouse event fired by the browser.
  DOMMouseEvent   originalEvent;
}

class LocationEvent extends Event {
  // Detected geographical location of the user.
  LatLng  latlng;
  // Geographical bounds of the area user is located in (with respect to the accuracy of location).
  LatLngBounds  bounds;
  // Accuracy of location in meters.
  num accuracy;
  // Height of the position above the WGS84 ellipsoid in meters.
  num altitude;
  // Accuracy of altitude in meters.
  num altitudeAccuracy;
  // The direction of travel in degrees counting clockwise from true North.
  num heading;
  // Current velocity in meters per second.
  num speed;
  // The time when the position was acquired.
  num timestamp;
}

class ErrorEvent extends Event {
  // Error message.
  String message;
  // Error code (if applicable).
  num code;
}

class LayerEvent extends Event {
  // The layer that was added or removed.
  Layer layer;
}

class LayersControlEvent extends Event {
  // The layer that was added or removed.
  Layer layer;
  // The name of the layer that was added or removed.
  String name;
}

class TileEvent extends Event {
  // The tile element (image).
  HTMLElement tile;
  // The source URL of the tile.
  String url;
}

class ResizeEvent extends Event {
  // The old size before resize event.
  Point   oldSize;
  // The new size after the resize event.
  Point   newSize;
}

class GeoJSONEvent extends Event {
  // The layer for the GeoJSON feature that is being added to the map.
  Layer layer;
  // GeoJSON properties of the feature.
  Object  properties;
  // GeoJSON geometry type of the feature.
  String geometryType;
  // GeoJSON ID of the feature (if present).
  String id;
}

class PopupEvent extends Event {
  // The popup that was opened or closed.
  Popup   popup;
}

class DragEndEvent extends Event {
  // The distance in pixels the draggable element was moved by.
  num distance;
}

class LocateOptions {
  // If true, starts continous watching of location changes (instead of
  // detecting it once) using W3C watchPosition method. You can later stop
  // watching using map.stopLocate() method.
  bool watch   = false;
  // If true, automatically sets the map view to the user location with
  // respect to detection accuracy, or to world view if geolocation failed.
  bool setView   = false;
  // The maximum zoom for automatic view setting when using `setView` option.
  num maxZoom = double.INFINITY;
  // Number of milliseconds to wait for a response from geolocation before
  // firing a locationerror event.
  num timeout   = 10000;
  // Maximum age of detected location. If less than this amount of milliseconds
  // passed since last geolocation response, locate will return a cached
  // location.
  num maximumAge  = 0;
  // Enables high accuracy, see description in the W3C spec.
  bool enableHighAccuracy = false;
}

class ZoomPanOptions {
  // If true, the map view will be completely reset (without any animations).
  bool reset   = false;
  // Sets the options for the panning (without the zoom change) if it occurs.
  PanOptions pan;
  // Sets the options for the zoom change if it occurs.
  ZoomOptions zoom;
  // An equivalent of passing animate to both zoom and pan options (see below).
  void set animate(bool anim) {
    pan.animate = anim;
    zoom.animate = anim;
  }
}

class PanOptions {
  // If true, panning will always be animated if possible. If false, it will
  // not animate panning, either resetting the map view if panning more than a
  // screen away, or just setting a new offset for the map pane (except for
  // `panBy` which always does the latter).
  bool animate;
  // Duration of animated panning.
  num duration  = 0.25;
  // The curvature factor of panning animation easing (third parameter of the
  // Cubic Bezier curve). 1.0 means linear animation, the less the more bowed
  // the curve.
  num easeLinearity   = 0.25;
  // If true, panning won't fire movestart event on start (used internally for
  // panning inertia).
  bool noMoveStart   = false;
}

class ZoomOptions {
  // If not specified, zoom animation will happen if the zoom origin is inside
  // the current view. If true, the map will attempt animating zoom
  // disregarding where zoom origin is. Setting false will make it always reset
  // the view completely without animation.
  bool animate;
}

class FitBoundsOptions extends ZoomPanOptions {
  // Sets the amount of padding in the top left corner of a map container that
  // shouldn't be accounted for when setting the view to fit bounds. Useful if
  // you have some control overlays on the map like a sidebar and you don't want
  // them to obscure objects you're zooming to.
  Point   paddingTopLeft  = new Point([0, 0]);
  // The same for bottom right corner of the map.
  Point   paddingBottomRight  = new Point([0, 0]);
  // Equivalent of setting both top left and bottom right padding to the same
  // value.
  Point   padding   = new Point([0, 0]);
  // The maximum possible zoom to use.
  num maxZoom;
}

abstract class Handler {
  // Enables the handler.
  enable();

  // Disables the handler.
  disable();

  // Returns true if the handler is enabled.
  bool enabled();
}

// Represents an object attached to a particular location (or a set of
// locations) on a map.
abstract class Layer {
  // Should contain code that creates DOM elements for the overlay, adds them
  // to map panes where they should belong and puts listeners on relevant map
  // events. Called on map.addLayer(layer).
  onAdd(BaseMap map);

  // Should contain all clean up code that removes the overlay's elements from
  // the DOM and removes listeners previously added in onAdd. Called on
  // map.removeLayer(layer).
  onRemove(BaseMap map);
}

// Represents a UI element in one of the corners of the map.
abstract class IControl {
  // Should contain code that creates all the neccessary DOM elements for the
  // control, adds listeners on relevant map events, and returns the element
  // containing the control. Called on map.addControl(control) or
  // control.addTo(map).
  HTMLElement onAdd(BaseMap map);

  // Optional, should contain all clean up code (e.g. removes control's event
  // listeners). Called on map.removeControl(control) or
  // control.removeFrom(map). The control's DOM container is removed
  // automatically.
  onRemove(BaseMap map);
}

// An object with methods for projecting geographical coordinates of the world
// onto a flat surface (and back).
abstract class Projection {
  // Projects geographical coordinates into a 2D point.
  Point project(LatLng latlng);

  // The inverse of project. Projects a 2D point into geographical location.
  LatLng unproject(Point point);
}

// Defines coordinate reference systems for projecting geographical points
// into pixel (screen) coordinates and back (and to coordinates in other units
// for WMS services).
abstract class CRS {
  // Projects geographical coordinates on a given zoom into pixel coordinates.
  Point latLngToPoint(LatLng latlng, num zoom);
  // The inverse of latLngToPoint. Projects pixel coordinates on a given zoom
  // into geographical coordinates.
  LatLng pointToLatLng(Point point, num zoom);
  // Projects geographical coordinates into coordinates in units accepted for
  // this CRS (e.g. meters for EPSG:3857, for passing it to WMS services).
  Point project(LatLng latlng);
  // Returns the scale used when transforming projected coordinates into pixel
  // coordinates for a particular zoom. For example, it returns 256 * 2^zoom
  // for Mercator-based CRS.
  num scale(num zoom);
  // Returns the size of the world in pixels for a particular zoom.
  Point getSize(num zoom);

  // Projection that this CRS uses.
  Projection get projection;
  // Transformation that this CRS uses to turn projected coordinates into
  // screen coordinates for a particular tile service.
  Transformation get transformation;
  // Standard code name of the CRS passed into WMS services (e.g. 'EPSG:3857').
  String get code;
}

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

  Map<String, Element> get panes => _panes;

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