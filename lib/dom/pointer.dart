part of leaflet.dom;

// Extends DomEvent to provide touch support for Internet Explorer and Windows-based devices.
class Pointer extends DomEvent {

  static var POINTER_DOWN = L.Browser.msPointer ? 'MSPointerDown' : 'pointerdown';
  static var POINTER_MOVE = L.Browser.msPointer ? 'MSPointerMove' : 'pointermove';
  static var POINTER_UP = L.Browser.msPointer ? 'MSPointerUp' : 'pointerup';
  static var POINTER_CANCEL = L.Browser.msPointer ? 'MSPointerCancel' : 'pointercancel';

  var _pointers = [];
  var _pointerDocumentListener = false;

  // Provides a touch events wrapper for (ms)pointer events.
  // Based on changes by veproza https://github.com/CloudMade/Leaflet/pull/1019
  //ref http://www.w3.org/TR/pointerevents/ https://www.w3.org/Bugs/Public/show_bug.cgi?id=22890

  addPointerListener(obj, type, handler, id) {

    switch (type) {
    case 'touchstart':
      return this.addPointerListenerStart(obj, type, handler, id);
    case 'touchend':
      return this.addPointerListenerEnd(obj, type, handler, id);
    case 'touchmove':
      return this.addPointerListenerMove(obj, type, handler, id);
    default:
      throw 'Unknown touch event type';
    }
  }

  addPointerListenerStart(obj, type, handler, id) {
    var pre = '_leaflet_',
        pointers = this._pointers;

    var cb = (e) {

      L.DomEvent.preventDefault(e);

      var alreadyInArray = false;
      for (var i = 0; i < pointers.length; i++) {
        if (pointers[i].pointerId == e.pointerId) {
          alreadyInArray = true;
          break;
        }
      }
      if (!alreadyInArray) {
        pointers.push(e);
      }

      e.touches = pointers.slice();
      e.changedTouches = [e];

      handler(e);
    };

    obj[pre + 'touchstart' + id] = cb;
    obj.addEventListener(this.POINTER_DOWN, cb, false);

    // need to also listen for end events to keep the _pointers list accurate
    // this needs to be on the body and never go away
    if (!this._pointerDocumentListener) {
      var internalCb = function (e) {
        for (var i = 0; i < pointers.length; i++) {
          if (pointers[i].pointerId === e.pointerId) {
            pointers.splice(i, 1);
            break;
          }
        }
      };
      //We listen on the documentElement as any drags that end by moving the touch off the screen get fired there
      document.documentElement.addEventListener(this.POINTER_UP, internalCb, false);
      document.documentElement.addEventListener(this.POINTER_CANCEL, internalCb, false);

      this._pointerDocumentListener = true;
    }

    return this;
  }

  addPointerListenerMove(obj, type, handler, id) {
    var pre = '_leaflet_',
        touches = this._pointers;

    cb(e) {

      // don't fire touch moves when mouse isn't down
      if ((e.pointerType == e.MSPOINTER_TYPE_MOUSE || e.pointerType == 'mouse') && e.buttons == 0) { return; }

      for (var i = 0; i < touches.length; i++) {
        if (touches[i].pointerId == e.pointerId) {
          touches[i] = e;
          break;
        }
      }

      e.touches = touches.slice();
      e.changedTouches = [e];

      handler(e);
    }

    obj[pre + 'touchmove' + id] = cb;
    obj.addEventListener(this.POINTER_MOVE, cb, false);

    return this;
  }

  addPointerListenerEnd(obj, type, handler, id) {
    var pre = '_leaflet_',
        touches = this._pointers;

    var cb = (e) {
      for (var i = 0; i < touches.length; i++) {
        if (touches[i].pointerId == e.pointerId) {
          touches.splice(i, 1);
          break;
        }
      }

      e.touches = touches.slice();
      e.changedTouches = [e];

      handler(e);
    };

    obj[pre + 'touchend' + id] = cb;
    obj.addEventListener(this.POINTER_UP, cb, false);
    obj.addEventListener(this.POINTER_CANCEL, cb, false);

    return this;
  }

  removePointerListener(obj, type, id) {
    var pre = '_leaflet_',
        cb = obj[pre + type + id];

    switch (type) {
    case 'touchstart':
      obj.removeEventListener(this.POINTER_DOWN, cb, false);
      break;
    case 'touchmove':
      obj.removeEventListener(this.POINTER_MOVE, cb, false);
      break;
    case 'touchend':
      obj.removeEventListener(this.POINTER_UP, cb, false);
      obj.removeEventListener(this.POINTER_CANCEL, cb, false);
      break;
    }

    return this;
  }
}