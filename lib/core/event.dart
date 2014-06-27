part of leaflet.core;

typedef /*bool*/void Action(Object obj, Event event);

class Event {
  /**
   * The event type (e.g. 'click').
   */
  EventType type;

  /**
   * The object that fired the event.
   */
  Object target;

  Object get context => target;

  Action action;

  Event(this.type, this.target, this.action);
}

class MouseEvent extends Event {
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
  html.MouseEvent originalEvent;

  MouseEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class LocationEvent extends Event {
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

  LocationEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class ErrorEvent extends Event {
  /**
   * Error message.
   */
  String message;

  /**
   * Error code (if applicable).
   */
  num code;

  ErrorEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class LayerEvent extends Event {
  /**
   * The layer that was added or removed.
   */
  Layer layer;

  LayerEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class LayersControlEvent extends Event {
  /**
   * The layer that was added or removed.
   */
  Layer layer;

  /**
   * The name of the layer that was added or removed.
   */
  String name;

  LayersControlEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class TileEvent extends Event {
  /**
   * The tile element (image).
   */
  Element tile;

  /**
   * The source URL of the tile.
   */
  String url;

  TileEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class ResizeEvent extends Event {
  /**
   * The old size before resize event.
   */
  Point2D oldSize;

  /**
   * The new size after the resize event.
   */
  Point2D newSize;

  ResizeEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class GeoJSONEvent extends Event {
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

  GeoJSONEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class PopupEvent extends Event {
  /**
   * The popup that was opened or closed.
   */
  Popup popup;

  PopupEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}

class DragEndEvent extends Event {
  /**
   * The distance in pixels the draggable element was moved by.
   */
  num distance;

  DragEndEvent(EventType eventType, Object target, Action action) : super(eventType, target, action);
}
