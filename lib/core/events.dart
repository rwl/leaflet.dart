part of leaflet.core;

//const eventsKey = '_leaflet_events';

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

/**
 * Events is used to add custom events functionality to Leaflet classes.
 */
class Events {

  //Map _leaflet_events;
  Map<EventType, List<Event>> _events;
  //Map<EventType, Map<int, List<Event>>> _contextEvents;
  //Map<EventType, int> _numContextEvents;

  /**
   * Alias to addEventListener.
   */
  void on(EventType types, Function fn/*, [Object context=null]*/) {
    addEventListener(types, fn/*, context*/);
  }

  /**
   * Adds a listener function (fn) to a particular event type of the object.
   * You can optionally specify the context of the listener (object the this
   * keyword will point to).
   */
  void addEventListener(EventType types, Function fn/*, [Object context=null]*/) { // (String, Function[, Object]) or (Object[, Object])

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
    /*if (_contextEvents == null) {
      _contextEvents = {};
    }
    if (_numContextEvents == null) {
      _numContextEvents = {};
    }*/
    //var contextId = context && context != this && L.stamp(context);
    /*var contextId = null;
    if (context != null && context != this) {
      contextId = stamp(context);
    }*/

//    int i, len;
//    Map event;
//    String indexKey, indexLenKey;
//    Map typeIndex;

    // types can be a string of space-separated words
    //List<String> typesList = Util.splitWords(types);
    List<EventType> typesList = [types];

    for (int i = 0; i < typesList.length; i++) {
      final type = typesList[i];
      //final event = new Event(type, context != null ? context : this, fn);
      final event = new Event._on(type, fn);

      /*if (contextId != null) {
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


      } else {*/
        if (!_events.containsKey(type)) {
          _events[type] = [];
        }
        _events[type].add(event);
      //}
    }
  }

  bool hasEventListeners(EventType type) {
    //var events = this[eventsKey];
//    final events = _leaflet_events;
    if (_events != null) {
      return _events.containsKey(type) && _events[type].length > 0;
    }
    /*if (_contextEvents != null && _numContextEvents != null) {
      return _contextEvents.containsKey(type) && _numContextEvents[type] > 0;
    }*/
    return false;
//    return (events.containsKey(type) && events[type].length > 0) || (events.containsKey(type + '_idx') && events[type + '_idx_len'] > 0);
  }

  /**
   * Alias to removeEventListener.
   */
  void off([EventType types = null, Function fn = null/*, Object context = null*/]) {
    removeEventListener(types, fn/*, context*/);
  }

  /**
   * Removes a previously added listener function. If no function is
   * specified, it will remove all the listeners of that particular event
   * from the object.
   *
   * An alias to clearAllEventListeners when you use it without arguments.
   */
  void removeEventListener([EventType types = null, Function fn = null/*, Object context = null*/]) { // ([String, Function, Object]) or (Object[, Object])
    //if (!this[eventsKey]) {
    if (_events == null/* && _contextEvents == null*/) {
      return;
    }

    if (types == null) {
      this.clearAllEventListeners();
      return;
    }

//    if (L.Util.invokeEach(types, this.removeEventListener, this, fn, context)) { return this; }

//    final events = _leaflet_events;
    //var contextId = context && context != this && L.stamp(context);
    /*int contextId = null;
    if (context != null && context != this) {
      contextId = stamp(context);
    }*/

//    Map typeIndex = null;
//    int i, len, j;
//    String indexKey, indexLenKey, type;
//    List listeners, removed;

    //List<String> typesList = Util.splitWords(types);
    List<EventType> typesList = [types];

//    len = types.length;
    for (int i = 0; i < typesList.length; i++) {
      final type = typesList[i];
//      indexKey = type + '_idx';
//      indexLenKey = indexKey + '_len';

      //Map<int, List<Event>> typeIndex = _contextEvents[type];

      if (fn == null) {
        // clear all listeners for a type if function isn't specified
        _events.remove(type);
//        _contextEvents.remove(type);
//        _numContextEvents.remove(type);

      } else {
        final List<Event> listeners = /*(contextId != null && typeIndex != null) ? typeIndex[contextId] : */_events[type];

        if (listeners != null) {
          for (int j = listeners.length - 1; j >= 0; j--) {
            if ((listeners[j].action == fn)/* && (context == null || (listeners[j].context == context))*/) {
              final removed = listeners.removeAt(j);
              // set the old action to a no-op, because it is possible
              // that the listener is being iterated over as part of a dispatch
//              removed.action = Util.falseFn;
              removed.action = () { return false; };
            }
          }

          /*if (context != null && typeIndex != null && (listeners.length == 0)) {
            typeIndex.remove(contextId);
            _numContextEvents[type]--;
          }*/
        }
      }
    }

    return;
  }

  /**
   * Removes all listeners to all events on the object.
   */
  void clearAllEventListeners() {
    //this.remove(eventsKey);
//    _leaflet_events = null;
    _events = null;
    //_contextEvents = null;
    //_numContextEvents = null;
  }

  /**
   * Alias to fireEvent.
   */
  /*fire(EventType type, [Map<String, Object> data = null]) {
    return fireEvent(type, data);
  }*/
  void fire(EventType type, [Event event]) {
    _fireEvent(type, event);
  }

  /**
   * Fires an event of the specified type. You can optionally provide an data object — the first argument of the listener function will contain its properties.
   */
  /*fireEvent(EventType type, [Map<String, Object> data = null]) { // (String[, Object])
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
  }*/
  void fireEvent(Event event) {
    _fireEvent(event.type, event);
  }

  void _fireEvent(EventType type, [Event event = null]) {
    if (!hasEventListeners(type)) {
      return;
    }

    //var event = Util.extend({}, data, { 'type': type, 'target': this });
    /*final event = {};
    if (data != null) {
      event.addAll(data);
    }
    event['type'] = type;
    event['target'] = this;*/
    if (event == null) {
      event = new Event(type);//type, this, null);
    } else {
      event.type = type;
      //event.target = this;
    }

    //var events = this[eventsKey],
//    final events = _leaflet_events;
//    var listeners, i, len, typeIndex, contextId;

    if (_events.containsKey(type)) {
      // make sure adding/removing listeners inside other listeners won't cause infinite loop
//      final listeners = new List.from(_events[type]);
      final listeners = _events[type];

      final len = listeners.length;
      for (int i = 0; i < len; i++) {
        var action = listeners[i].action;
        /*if (action is Action) {
          action(listeners[i].context, event);
        } else*/ if (action is EventAction) {
          action(event);
        } else {
          action();
        }
      }
    }

    // fire event for the context-indexed listeners as well
    //Map<int, List<Event>> typeIndex = _contextEvents[type];

    /*for (int contextId in typeIndex.keys) {
      final listeners = typeIndex[contextId];//.slice();

      if (listeners != null) {
        for (int i = 0; i < listeners.length; i++) {
          //listeners[i].action(listeners[i].context, event);
          var action = listeners[i].action;
          if (action is EventAction) {
            action(event);
          } else {
            action();
          }
        }
      }
    }*/
  }

  /**
   * Alias to addOneTimeEventListener.
   */
  /*once(types, fn, context) {
    return addOneTimeEventListener(types, fn, context);
  }*/

  /**
   * The same as above except the listener will only get fired once and then removed.
   */
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