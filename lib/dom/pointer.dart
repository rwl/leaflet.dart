part of leaflet.dom;
/*
// Extends DomEvent to provide touch support for Internet Explorer and Windows-based devices.
//class Pointer extends _DomEvent {

final POINTER_DOWN = Browser.msPointer ? 'MSPointerDown' : 'pointerdown';
final POINTER_MOVE = Browser.msPointer ? 'MSPointerMove' : 'pointermove';
final POINTER_UP = Browser.msPointer ? 'MSPointerUp' : 'pointerup';
final POINTER_CANCEL = Browser.msPointer ? 'MSPointerCancel' : 'pointercancel';

var _pointers = [];
var _pointerDocumentListener = false;

// Provides a touch events wrapper for (ms)pointer events.
// Based on changes by veproza https://github.com/CloudMade/Leaflet/pull/1019
//ref http://www.w3.org/TR/pointerevents/ https://www.w3.org/Bugs/Public/show_bug.cgi?id=22890

addPointerListener(obj, type, handler, id) {

  switch (type) {
  case 'touchstart':
    return addPointerListenerStart(obj, type, handler, id);
  case 'touchend':
    return addPointerListenerEnd(obj, type, handler, id);
  case 'touchmove':
    return addPointerListenerMove(obj, type, handler, id);
  default:
    throw 'Unknown touch event type';
  }
}

addPointerListenerStart(obj, type, handler, id) {
  var pre = '_leaflet_',
      pointers = _pointers;

  var cb = (e) {

    preventDefault(e);

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
  obj.addEventListener(POINTER_DOWN, cb, false);

  // need to also listen for end events to keep the _pointers list accurate
  // this needs to be on the body and never go away
  if (!_pointerDocumentListener) {
    var internalCb = (e) {
      for (var i = 0; i < pointers.length; i++) {
        if (pointers[i].pointerId == e.pointerId) {
          pointers.splice(i, 1);
          break;
        }
      }
    };
    //We listen on the documentElement as any drags that end by moving the touch off the screen get fired there
    document.documentElement.addEventListener(POINTER_UP, internalCb, false);
    document.documentElement.addEventListener(POINTER_CANCEL, internalCb, false);

    _pointerDocumentListener = true;
  }
}

addPointerListenerMove(obj, type, handler, id) {
  var pre = '_leaflet_',
      touches = _pointers;

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
  obj.addEventListener(POINTER_MOVE, cb, false);
}

addPointerListenerEnd(obj, type, handler, id) {
  var pre = '_leaflet_',
      touches = _pointers;

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
  obj.addEventListener(POINTER_UP, cb, false);
  obj.addEventListener(POINTER_CANCEL, cb, false);
}

removePointerListener(obj, type, id) {
  var pre = '_leaflet_',
      cb = obj[pre + type + id];

  switch (type) {
  case 'touchstart':
    obj.removeEventListener(POINTER_DOWN, cb, false);
    break;
  case 'touchmove':
    obj.removeEventListener(POINTER_MOVE, cb, false);
    break;
  case 'touchend':
    obj.removeEventListener(POINTER_UP, cb, false);
    obj.removeEventListener(POINTER_CANCEL, cb, false);
    break;
  }
}
*/