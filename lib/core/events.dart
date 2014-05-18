part of leaflet.core;

//const eventsKey = '_leaflet_events';

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

typedef bool Action(Object obj, Event event);
/*
class Event {
  Action action;
  Object context;
  Map<String, Object> data;
  String type;
  Events target;

  var layer;

  Event();

  factory Event.event(action, context) {
    final e = new Event();
    e.action = action;
    e.context = context;
    return e;
  }

  Event copy() {
    final e = new Event();
    e.action = action;
    e.context = context;
    e.data = data;
    e.type = type;
    e.target = target;
  }
}
*/
// Events is used to add custom events functionality to Leaflet classes.
class Events {
  //Map _leaflet_events;
  Map<String, List<Event>> _events;
  Map<String, Map<int, List<Event>>> _contextEvents;
  Map<String, int> _numContextEvents;

  on(EventType types, Action fn, [BaseMap context=null]) {
    return addEventListener(types, fn);
  }

  addEventListener(EventType types, Action fn, [Map context=null]) { // (String, Function[, Object]) or (Object[, Object])

    // types can be a map of types/handlers
//    if (L.Util.invokeEach(types, this.addEventListener, this, fn, context)) { return this; }

    //var events = this[eventsKey] = this[eventsKey] || {},
//    if (_leaflet_events == null) {
//      _leaflet_events = {};
//    }
//    final events = _leaflet_events;
    if (_events == null) {
      _events = {};
    }
    if (_contextEvents == null) {
      _contextEvents = {};
    }
    if (_numContextEvents == null) {
      _numContextEvents = {};
    }
    //var contextId = context && context != this && L.stamp(context);
    var contextId = null;
    if (context != null && context != this) {
      contextId = Util.stamp(context);
    }
//    int i, len;
//    Map event;
//    String indexKey, indexLenKey;
//    Map typeIndex;

    // types can be a string of space-separated words
    List<String> typesList = Util.splitWords(types);

    for (int i = 0; i < typesList.length; i++) {
      final event = new Event.event(fn, context != null ? context : this);
      final type = typesList[i];

      if (contextId != null) {
        // store listeners of a particular context in a separate hash (if it has an id)
        // gives a major performance boost when removing thousands of map layers

//        indexKey = type + '_idx';
//        indexLenKey = indexKey + '_len';

        if (!_contextEvents.containsKey(type)) {
          _contextEvents[type] = {};
        }
        Map<int, List<Event>> typeIndex = _contextEvents[type];

        if (!typeIndex.containsKey(contextId)) {
          typeIndex[contextId] = [];

          // keep track of the number of keys in the index to quickly check if it's empty
//          events[indexLenKey] = (events.containsKey(indexLenKey) ? events[indexLenKey] : 0) + 1;
          if (!_numContextEvents.containsKey(type)) {
            _numContextEvents[type] = 0;
          }
          _numContextEvents[type]++;
        }

        typeIndex[contextId].add(event);


      } else {
        if (!_events.containsKey(type)) {
          _events[type] = [];
        }
        _events[type].add(event);
      }
    }

    return this;
  }

  bool hasEventListeners(String type) { // (String) -> Boolean
    //var events = this[eventsKey];
//    final events = _leaflet_events;
    if (_events != null) {
      return _events.containsKey(type) && _events[type].length > 0;
    }
    if (_contextEvents != null && _numContextEvents != null) {
      return _contextEvents.containsKey(type) && _numContextEvents[type] > 0;
    }
    return false;
//    return (events.containsKey(type) && events[type].length > 0) || (events.containsKey(type + '_idx') && events[type + '_idx_len'] > 0);
  }

  off([String types = null, Action fn = null, BaseMap context = null]) {
    return removeEventListener(types, fn, context);
  }

  removeEventListener([String types = null, Action fn = null, Map context = null]) { // ([String, Function, Object]) or (Object[, Object])
    //if (!this[eventsKey]) {
    if (_events == null && _contextEvents == null) {
      return this;
    }

    if (types == null) {
      return this.clearAllEventListeners();
    }

//    if (L.Util.invokeEach(types, this.removeEventListener, this, fn, context)) { return this; }

//    final events = _leaflet_events;
    //var contextId = context && context != this && L.stamp(context);
    int contextId = null;
    if (context != null && context != this) {
      contextId = Util.stamp(context);
    }
//    Map typeIndex = null;
//    int i, len, j;
//    String indexKey, indexLenKey, type;
//    List listeners, removed;

    List<String> typesList = Util.splitWords(types);

//    len = types.length;
    for (int i = 0; i < typesList.length; i++) {
      final type = typesList[i];
//      indexKey = type + '_idx';
//      indexLenKey = indexKey + '_len';

      Map<int, List<Event>> typeIndex = _contextEvents[type];

      if (fn = null) {
        // clear all listeners for a type if function isn't specified
        _events.remove(type);
        _contextEvents.remove(type);
        _numContextEvents.remove(type);

      } else {
        final List<Event> listeners = (contextId != null && typeIndex != null) ? typeIndex[contextId] : _events[type];

        if (listeners != null) {
          for (int j = listeners.length - 1; j >= 0; j--) {
            if ((listeners[j].action == fn) && (context == null || (listeners[j].context == context))) {
              final removed = listeners.removeAt(j);
              // set the old action to a no-op, because it is possible
              // that the listener is being iterated over as part of a dispatch
//              removed.action = Util.falseFn;
              removed.action = (Object context, Event event) { return false; };
            }
          }

          if (context && typeIndex && (listeners.length == 0)) {
            typeIndex.remove(contextId);
            _numContextEvents[type]--;
          }
        }
      }
    }

    return this;
  }

  clearAllEventListeners() {
    //this.remove(eventsKey);
//    _leaflet_events = null;
    _events = null;
    _contextEvents = null;
    _numContextEvents = null;
    return this;
  }

  fire(String type, [Map data = null]) {
    return fireEvent(type, data);
  }

  fireEvent(String type, [Map data = null]) { // (String[, Object])
    if (!this.hasEventListeners(type)) {
      return this;
    }

    //var event = Util.extend({}, data, { 'type': type, 'target': this });
    final event = {};
    if (data != null) {
      event.addAll(data);
    }
    event['type'] = type;
    event['target'] = this;

    //var events = this[eventsKey],
//    final events = _leaflet_events;
//    var listeners, i, len, typeIndex, contextId;

    if (_events.containsKey(type)) {
      // make sure adding/removing listeners inside other listeners won't cause infinite loop
//      final listeners = new List.from(_events[type]);
      final listeners = _events[type];

      final len = listeners.length;
      for (int i = 0; i < len; i++) {
        listeners[i].action(listeners[i].context, event);
      }
    }

    // fire event for the context-indexed listeners as well
    Map<int, List<Event>> typeIndex = _contextEvents[type];

    for (int contextId in typeIndex.keys) {
      final listeners = typeIndex[contextId];//.slice();

      if (listeners != null) {
        for (int i = 0; i < listeners.length; i++) {
          listeners[i].action(listeners[i].context, event);
        }
      }
    }

    return this;
  }

  /*once(types, fn, context) {
    return addOneTimeEventListener(types, fn, context);
  }

  addOneTimeEventListener(types, fn, context) {

    if (Util.invokeEach(types, this.addOneTimeEventListener, this, fn, context)) { return this; }

    var handler = L.bind(() {
      this
          .removeEventListener(types, fn, context)
          .removeEventListener(types, handler, context);
    }, this);

    return this
        .addEventListener(types, fn, context)
        .addEventListener(types, handler, context);
  }*/
}