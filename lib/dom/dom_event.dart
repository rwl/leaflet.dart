part of leaflet.dom;

//final DomEvent = new _DomEvent();

/**
 * DomEvent contains functions for working with DOM events.
 */
//class _DomEvent {}

/**
 * Alias for addListener.
 */
void on(Element obj, String type, Function fn, [Object context=null]) {
  addListener(obj, type, fn, context);
}

/**
 * Adds a listener fn to the element's DOM event of the specified type. this keyword inside the listener will point to context, or to the element if not specified.
 *
 * Inspired by John Resig, Dean Edwards and YUI addEvent implementations.
 */
void addListener(Element obj, String type, Function fn, Object context) { // (HTMLElement, String, Function[, Object])

  final id = stamp(fn),
      key = '_leaflet_' + type + id;

  if (obj[key]) { return; }

  var handler = (e) {
    return fn.call(context || obj, e || _getEvent());
  };

  if (Browser.pointer && type.indexOf('touch') == 0) {
    addPointerListener(obj, type, handler, id);
    return;
  }
  if (Browser.touch && (type == 'dblclick') && addDoubleTapListener) {
    addDoubleTapListener(obj, handler, id);
  }

  if (obj.contains('addEventListener')) {

    if (type == 'mousewheel') {
      obj.addEventListener('DOMMouseScroll', handler, false);
      obj.addEventListener(type, handler, false);

    } else if ((type == 'mouseenter') || (type == 'mouseleave')) {

      originalHandler = handler;
      newType = (type == 'mouseenter' ? 'mouseover' : 'mouseout');

      handler = (e) {
        if (!L.DomEvent._checkMouse(obj, e)) { return; }
        return originalHandler(e);
      };

      obj.addEventListener(newType, handler, false);

    } else if (type == 'click' && L.Browser.android) {
      originalHandler = handler;
      handler = (e) {
        return L.DomEvent._filterClick(e, originalHandler);
      };

      obj.addEventListener(type, handler, false);
    } else {
      obj.addEventListener(type, handler, false);
    }

  } else if (obj.contains('attachEvent')) {
    obj.attachEvent('on' + type, handler);
  }

  obj[key] = handler;

  return;
}

/**
 * Alias for removeListener.
 */
void off(Element obj, String type, Function fn) {
  removeListener(obj, type, fn);
}

/**
 * Removes an event listener from the element.
 */
void removeListener(Element obj, String type, Function fn) {  // (HTMLElement, String, Function)

  var id = stamp(fn),
      key = '_leaflet_' + type + id,
      handler = obj[key];

  if (handler == null) { return; }

  if (Browser.pointer && type.indexOf('touch') == 0) {
    removePointerListener(obj, type, id);
  } else if (L.Browser.touch && (type == 'dblclick') && removeDoubleTapListener) {
    removeDoubleTapListener(obj, id);

  } else if (obj.contains('removeEventListener')) {

    if (type == 'mousewheel') {
      obj.removeEventListener('DOMMouseScroll', handler, false);
      obj.removeEventListener(type, handler, false);

    } else if ((type == 'mouseenter') || (type == 'mouseleave')) {
      obj.removeEventListener((type == 'mouseenter' ? 'mouseover' : 'mouseout'), handler, false);
    } else {
      obj.removeEventListener(type, handler, false);
    }
  } else if (obj.contains('detachEvent')) {
    obj.detachEvent('on' + type, handler);
  }

  obj[key] = null;

  return;
}

/**
 * Stop the given event from propagation to parent elements.
 */
void stopPropagation(e) {

  if (e.stopPropagation) {
    e.stopPropagation();
  } else {
    e.cancelBubble = true;
  }
  L.DomEvent._skipped(e);
}

void disableScrollPropagation(el) {
  var stop = L.DomEvent.stopPropagation;

  on(el, 'mousewheel', stop);
  on(el, 'MozMousePixelScroll', stop);
}

/**
 * Adds stopPropagation to the element's 'click', 'doubleclick', 'mousedown' and 'touchstart' events.
 */
void disableClickPropagation(Element el) {
  var stop = L.DomEvent.stopPropagation;

  for (var i = L.Draggable.START.length - 1; i >= 0; i--) {
    L.DomEvent.on(el, L.Draggable.START[i], stop);
  }

  return L.DomEvent
    .on(el, 'click', L.DomEvent._fakeStop)
    .on(el, 'dblclick', stop);
}

/**
 * Prevents the default action of the event from happening (such as following a link in the href of the a element, or doing a POST request with page reload when form is submitted).
 */
void preventDefault(e) {

  if (e.preventDefault) {
    e.preventDefault();
  } else {
    e.returnValue = false;
  }
}

/**
 * Does stopPropagation and preventDefault at the same time.
 */
void stop(e) {
  return L.DomEvent
    .preventDefault(e)
    .stopPropagation(e);
}

/**
 * Gets normalized mouse position from a DOM event relative to the container or to the whole page if not specified.
 */
geom.Point getMousePosition(e, Element container) {
  if (!container) {
    return new geom.Point(e.clientX, e.clientY);
  }

  var rect = container.getBoundingClientRect();

  return new geom.Point(
    e.clientX - rect.left - container.clientLeft,
    e.clientY - rect.top - container.clientTop);
}

/**
 * Gets normalized wheel delta from a mousewheel DOM event.
 */
num getWheelDelta(e) {

  var delta = 0;

  if (e.wheelDelta) {
    delta = e.wheelDelta / 120;
  }
  if (e.detail) {
    delta = -e.detail / 3;
  }
  return delta;
}

var _skipEvents = {};

void _fakeStop(e) {
  // fakes stopPropagation by setting a special event flag, checked/reset with L.DomEvent._skipped(e)
  _skipEvents[e.type] = true;
}

_skipped(e) {
  var skipped = _skipEvents[e.type];
  // reset when checking, as it's only used in map container and propagates outside of the map
  _skipEvents[e.type] = false;
  return skipped;
}

// check if element really left/entered the event target (for mouseenter/mouseleave)
bool _checkMouse(Element el, e) {

  var related = e.relatedTarget;

  if (!related) { return true; }

  try {
    while (related && (related != el)) {
      related = related.parentNode;
    }
  } catch (err) {
    return false;
  }
  return (related != el);
}

_getEvent() { // evil magic for IE
  /*jshint noarg:false */
  var e = window.event;
  if (!e) {
    var caller = arguments.callee.caller;
    while (caller) {
      e = caller['arguments'][0];
      if (e && window.Event == e.constructor) {
        break;
      }
      caller = caller.caller;
    }
  }
  return e;
}

// this is a horrible workaround for a bug in Android where a single touch triggers two click events
_filterClick(e, handler) {
  var timeStamp = (e.timeStamp || e.originalEvent.timeStamp),
    elapsed = _lastClick && (timeStamp - L.DomEvent._lastClick);

  // are they closer together than 1000ms yet more than 100ms?
  // Android typically triggers them ~300ms apart while multiple listeners
  // on the same event should be triggered far faster;
  // or check if click is simulated on the element, and if it is, reject any non-simulated events

  if ((elapsed && elapsed > 100 && elapsed < 1000) || (e.target._simulatedClick && !e._simulated)) {
    stop(e);
    return null;
  }
  _lastClick = timeStamp;

  return handler(e);
}
