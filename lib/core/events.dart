part of leaflet.core;

//const eventsKey = '_leaflet_events';

typedef bool Action(Object obj, Event event);

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

// Events is used to add custom events functionality to Leaflet classes.
class Events {
  //Map _leaflet_events;
  Map<String, List<Event>> _events;
  Map<String, Map<int, List<Event>>> _contextEvents;
  Map<String, int> _numContextEvents;

  addEventListener(String types, Action fn, [Map context=null]) { // (String, Function[, Object]) or (Object[, Object])

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

  fire(String type, Map data) {
    return fireEvent(type, data);
  }

  fireEvent(String type, Map data) { // (String[, Object])
    if (!this.hasEventListeners(type)) {
      return this;
    }

    //var event = Util.extend({}, data, { 'type': type, 'target': this });
    final event = {};
    event.addAll(data);
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

  /*addOneTimeEventListener(types, fn, context) {

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