
// DomEvent contains functions for working with DOM events.
class DomEvent {
  /* inspired by John Resig, Dean Edwards and YUI addEvent implementations */
  addListener(obj, type, fn, context) { // (HTMLElement, String, Function[, Object])

    var id = L.stamp(fn),
        key = '_leaflet_' + type + id,
        handler, originalHandler, newType;

    if (obj[key]) { return this; }

    handler = (e) {
      return fn.call(context || obj, e || L.DomEvent._getEvent());
    };

    if (L.Browser.pointer && type.indexOf('touch') == 0) {
      return this.addPointerListener(obj, type, handler, id);
    }
    if (L.Browser.touch && (type == 'dblclick') && this.addDoubleTapListener) {
      this.addDoubleTapListener(obj, handler, id);
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

    return this;
  }

  removeListener(obj, type, fn) {  // (HTMLElement, String, Function)

    var id = L.stamp(fn),
        key = '_leaflet_' + type + id,
        handler = obj[key];

    if (!handler) { return this; }

    if (L.Browser.pointer && type.indexOf('touch') == 0) {
      this.removePointerListener(obj, type, id);
    } else if (L.Browser.touch && (type == 'dblclick') && this.removeDoubleTapListener) {
      this.removeDoubleTapListener(obj, id);

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

    return this;
  }

  stopPropagation(e) {

    if (e.stopPropagation) {
      e.stopPropagation();
    } else {
      e.cancelBubble = true;
    }
    L.DomEvent._skipped(e);

    return this;
  }

  disableScrollPropagation(el) {
    var stop = L.DomEvent.stopPropagation;

    return L.DomEvent
      .on(el, 'mousewheel', stop)
      .on(el, 'MozMousePixelScroll', stop);
  }

  disableClickPropagation(el) {
    var stop = L.DomEvent.stopPropagation;

    for (var i = L.Draggable.START.length - 1; i >= 0; i--) {
      L.DomEvent.on(el, L.Draggable.START[i], stop);
    }

    return L.DomEvent
      .on(el, 'click', L.DomEvent._fakeStop)
      .on(el, 'dblclick', stop);
  }

  preventDefault(e) {

    if (e.preventDefault) {
      e.preventDefault();
    } else {
      e.returnValue = false;
    }
    return this;
  }

  stop(e) {
    return L.DomEvent
      .preventDefault(e)
      .stopPropagation(e);
  }

  getMousePosition(e, container) {
    if (!container) {
      return new L.Point(e.clientX, e.clientY);
    }

    var rect = container.getBoundingClientRect();

    return new L.Point(
      e.clientX - rect.left - container.clientLeft,
      e.clientY - rect.top - container.clientTop);
  }

  getWheelDelta(e) {

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

  _fakeStop(e) {
    // fakes stopPropagation by setting a special event flag, checked/reset with L.DomEvent._skipped(e)
    L.DomEvent._skipEvents[e.type] = true;
  }

  _skipped(e) {
    var skipped = this._skipEvents[e.type];
    // reset when checking, as it's only used in map container and propagates outside of the map
    this._skipEvents[e.type] = false;
    return skipped;
  }

  // check if element really left/entered the event target (for mouseenter/mouseleave)
  _checkMouse(el, e) {

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
        if (e && window.Event === e.constructor) {
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
      elapsed = L.DomEvent._lastClick && (timeStamp - L.DomEvent._lastClick);

    // are they closer together than 1000ms yet more than 100ms?
    // Android typically triggers them ~300ms apart while multiple listeners
    // on the same event should be triggered far faster;
    // or check if click is simulated on the element, and if it is, reject any non-simulated events

    if ((elapsed && elapsed > 100 && elapsed < 1000) || (e.target._simulatedClick && !e._simulated)) {
      L.DomEvent.stop(e);
      return;
    }
    L.DomEvent._lastClick = timeStamp;

    return handler(e);
  }
}