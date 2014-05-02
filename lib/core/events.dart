library leaflet.core.mixin;

// Events is used to add custom events functionality to Leaflet classes.
class Events {
  addEventListener(types, fn, context) { // (String, Function[, Object]) or (Object[, Object])

    // types can be a map of types/handlers
    if (L.Util.invokeEach(types, this.addEventListener, this, fn, context)) { return this; }

    var events = this[eventsKey] = this[eventsKey] || {},
        contextId = context && context != this && L.stamp(context),
        i, len, event, type, indexKey, indexLenKey, typeIndex;

    // types can be a string of space-separated words
    types = L.Util.splitWords(types);

    len = types.length;
    for (i = 0; i < len; i++) {
      event = {
        'action': fn,
        'context': context || this
      };
      type = types[i];

      if (contextId) {
        // store listeners of a particular context in a separate hash (if it has an id)
        // gives a major performance boost when removing thousands of map layers

        indexKey = type + '_idx';
        indexLenKey = indexKey + '_len';

        typeIndex = events[indexKey] = events[indexKey] || {};

        if (!typeIndex[contextId]) {
          typeIndex[contextId] = [];

          // keep track of the number of keys in the index to quickly check if it's empty
          events[indexLenKey] = (events[indexLenKey] || 0) + 1;
        }

        typeIndex[contextId].push(event);


      } else {
        events[type] = events[type] || [];
        events[type].push(event);
      }
    }

    return this;
  }

  bool hasEventListeners(String type) { // (String) -> Boolean
    var events = this[eventsKey];
    return !!events && ((events.contains(type) && events[type].length > 0) ||
                        (events.contains(type + '_idx') && events[type + '_idx_len'] > 0));
  }

  removeEventListener(String types, Function fn, Map context) { // ([String, Function, Object]) or (Object[, Object])

    if (!this[eventsKey]) {
      return this;
    }

    if (!types) {
      return this.clearAllEventListeners();
    }

    if (L.Util.invokeEach(types, this.removeEventListener, this, fn, context)) { return this; }

    var events = this[eventsKey],
        contextId = context && context != this && L.stamp(context),
        i, len, type, listeners, j, indexKey, indexLenKey, typeIndex, removed;

    types = L.Util.splitWords(types);

    len = types.length;
    for (i = 0; i < len; i++) {
      type = types[i];
      indexKey = type + '_idx';
      indexLenKey = indexKey + '_len';

      typeIndex = events[indexKey];

      if (!fn) {
        // clear all listeners for a type if function isn't specified
        delete(events[type]);
        delete(events[indexKey]);
        delete(events[indexLenKey]);

      } else {
        listeners = contextId && typeIndex ? typeIndex[contextId] : events[type];

        if (listeners) {
          for (j = listeners.length - 1; j >= 0; j--) {
            if ((listeners[j].action == fn) && (!context || (listeners[j].context == context))) {
              removed = listeners.splice(j, 1);
              // set the old action to a no-op, because it is possible
              // that the listener is being iterated over as part of a dispatch
              removed[0].action = L.Util.falseFn;
            }
          }

          if (context && typeIndex && (listeners.length == 0)) {
            delete(typeIndex[contextId]);
            events[indexLenKey]--;
          }
        }
      }
    }

    return this;
  }

  clearAllEventListeners() {
    delete(this[eventsKey]);
    return this;
  }

  fireEvent(String type, Map data) { // (String[, Object])
    if (!this.hasEventListeners(type)) {
      return this;
    }

    var event = L.Util.extend({}, data, { 'type': type, 'target': this });

    var events = this[eventsKey],
        listeners, i, len, typeIndex, contextId;

    if (events[type]) {
      // make sure adding/removing listeners inside other listeners won't cause infinite loop
      listeners = events[type].slice();

      len = listeners.length;
      for (i = 0; i < len; i++) {
        listeners[i].action.call(listeners[i].context, event);
      }
    }

    // fire event for the context-indexed listeners as well
    typeIndex = events[type + '_idx'];

    for (contextId in typeIndex) {
      listeners = typeIndex[contextId].slice();

      if (listeners) {
        len = listeners.length;
        for (i = 0; i < len; i++) {
          listeners[i].action.call(listeners[i].context, event);
        }
      }
    }

    return this;
  }

  addOneTimeEventListener(types, fn, context) {

    if (L.Util.invokeEach(types, this.addOneTimeEventListener, this, fn, context)) { return this; }

    var handler = L.bind(() {
      this
          .removeEventListener(types, fn, context)
          .removeEventListener(types, handler, context);
    }, this);

    return this
        .addEventListener(types, fn, context)
        .addEventListener(types, handler, context);
  }
}