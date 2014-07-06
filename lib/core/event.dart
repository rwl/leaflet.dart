part of leaflet.core;

typedef /*bool*/void Action(MapEvent event);
typedef /*bool*/void EventAction(MapEvent event);

class MapEvent {
  /**
   * The event type (e.g. 'click').
   */
  EventType type;

  /**
   * The object that fired the event.
   */
  //Object target;

  //Object get context => target;

  Function action;

  MapEvent(this.type);

  factory MapEvent._on(type, /*this.target,*/ action) {
    return new MapEvent(type)
      ..action = action;
  }
}

class MouseEvent extends MapEvent {
  /**
   * The geographical point where the mouse event occured.
   */
  LatLng latlng;

  /**
   * Pixel coordinates of the point where the mouse event occured relative to
   * the map layer.
   */
  Point2D layerPoint;

  /**
   * Pixel coordinates of the point where the mouse event occured relative to
   * the map сontainer.
   */
  Point2D containerPoint;

  /**
   * The original DOM mouse event fired by the browser.
   */
  html./*Mouse*/Event originalEvent;

  //MouseEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  MouseEvent(EventType eventType, this.latlng, this.layerPoint, this.containerPoint, this.originalEvent) : super(eventType);
}

class LocationEvent extends MapEvent {
  /**
   * Detected geographical location of the user.
   */
  LatLng latlng;

  /**
   * Geographical bounds of the area user is located in (with respect to the
   * accuracy of location).
   */
  LatLngBounds bounds;

  /**
   * Accuracy of location in meters.
   */
  num accuracy;

  /**
   * Height of the position above the WGS84 ellipsoid in meters.
   */
  num altitude;

  /**
   * Accuracy of altitude in meters.
   */
  num altitudeAccuracy;

  /**
   * The direction of travel in degrees counting clockwise from true North.
   */
  num heading;

  /**
   * Current velocity in meters per second.
   */
  num speed;

  /**
   * The time when the position was acquired.
   */
  num timestamp;

  //LocationEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  LocationEvent(this.latlng, this.bounds, this.accuracy, this.altitude, this.altitudeAccuracy,
      this.heading, this.speed, this.timestamp) : super(EventType.LOCATIONFOUND);
}

class ErrorEvent extends MapEvent {
  /**
   * Error message.
   */
  String message;

  /**
   * Error code (if applicable).
   */
  num code;

  //ErrorEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  ErrorEvent(EventType eventType, this.code, this.message) : super(eventType);
}

class LayerEvent extends MapEvent {
  /**
   * The layer that was added or removed.
   */
  Layer layer;

  //LayerEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  LayerEvent(EventType type, this.layer) : super(type);
}

class LayersControlEvent extends MapEvent {
  /**
   * The layer that was added or removed.
   */
  Layer layer;

  /**
   * The name of the layer that was added or removed.
   */
  String name;

  bool overlay;

  //LayersControlEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  LayersControlEvent(EventType eventType, this.layer, this.name, this.overlay) : super(eventType);
}

class TileEvent extends MapEvent {
  /**
   * The tile element (image).
   */
  Element tile;

  /**
   * The source URL of the tile.
   */
  String url;

  //TileEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  TileEvent(EventType eventType, this.tile, this.url) : super(eventType);
}

class ResizeEvent extends MapEvent {
  /**
   * The old size before resize event.
   */
  Point2D oldSize;

  /**
   * The new size after the resize event.
   */
  Point2D newSize;

  //ResizeEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  ResizeEvent(this.oldSize, this.newSize) : super(EventType.RESIZE);
}

class GeoJSONEvent extends MapEvent {
  /**
   * The layer for the GeoJSON feature that is being added to the map.
   */
  Layer layer;

  /**
   * GeoJSON properties of the feature.
   */
  Object properties;

  /**
   * GeoJSON geometry type of the feature.
   */
  String geometryType;

  /**
   * GeoJSON ID of the feature (if present).
   */
  String id;

  //GeoJSONEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  GeoJSONEvent(EventType eventType, this.layer, this.properties, this.geometryType, this.id) : super(eventType);
}

class PopupEvent extends MapEvent {
  /**
   * The popup that was opened or closed.
   */
  Popup popup;

  //PopupEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  PopupEvent(EventType eventType, this.popup) : super(eventType);
}

class DragEndEvent extends MapEvent {
  /**
   * The distance in pixels the draggable element was moved by.
   */
  num distance;

  //DragEndEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  DragEndEvent(this.distance) : super(EventType.DRAGEND);
}

class ZoomEvent extends MapEvent {
  LatLng center;
  num zoom;
  Point2D origin;
  num scale;
  Point2D delta;
  bool backwards;

  //ZoomAnimEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
  ZoomEvent(this.center, this.zoom, this.origin, this.scale, this.delta, this.backwards) : super(EventType.ZOOMANIM);
}

class ViewEvent extends MapEvent {
  bool hard;
  ViewEvent(EventType type, this.hard) : super(type);
}

class BoxZoomEvent extends MapEvent {
  LatLngBounds boxZoomBounds;
  BoxZoomEvent(EventType type, this.boxZoomBounds) : super(type);
}
