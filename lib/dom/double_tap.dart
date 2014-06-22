part of leaflet.dom;

// Extends the event handling code with double tap support for mobile browsers.
//class DoubleTap extends _DomEvent {

var _touchstart = Browser.msPointer ? 'MSPointerDown' : Browser.pointer ? 'pointerdown' : 'touchstart';
var _touchend = Browser.msPointer ? 'MSPointerUp' : Browser.pointer ? 'pointerup' : 'touchend';

// inspired by Zepto touch code by Thomas Fuchs
addDoubleTapListener(obj, handler, id) {
  var last,
      touch,
      doubleTap = false;

  final delay = 250,
      pre = '_leaflet_',
      touchstart = _touchstart,
      touchend = _touchend,
      trackedTouches = [];

  onTouchStart(e) {
    var count;

    if (Browser.pointer) {
      trackedTouches.add(e.pointerId);
      count = trackedTouches.length;
    } else {
      count = e.touches.length;
    }
    if (count > 1) {
      return;
    }

    final now = Date.now(),
      delta = now - (last || now);

    touch = e.touches ? e.touches[0] : e;
    doubleTap = (delta > 0 && delta <= delay);
    last = now;
  }

  onTouchEnd(e) {
    if (Browser.pointer) {
      var idx = trackedTouches.indexOf(e.pointerId);
      if (idx == -1) {
        return;
      }
      trackedTouches.removeAt(idx);
    }

    if (doubleTap) {
      if (Browser.pointer) {
        // work around .type being readonly with MSPointer* events
        var newTouch = { },
          prop;

        // jshint forin:false
        for (var i in touch) {
          prop = touch[i];
          if (prop is Function) {
            newTouch[i] = prop.bind(touch);
          } else {
            newTouch[i] = prop;
          }
        }
        touch = newTouch;
      }
      touch.type = 'dblclick';
      handler(touch);
      last = null;
    }
  }
  obj[pre + touchstart + id] = onTouchStart;
  obj[pre + touchend + id] = onTouchEnd;

  // on pointer we need to listen on the document, otherwise a drag starting on the map and moving off screen
  // will not come through to us, so we will lose track of how many touches are ongoing
  var endElement = Browser.pointer ? document.documentElement : obj;

  obj.addEventListener(touchstart, onTouchStart, false);
  endElement.addEventListener(touchend, onTouchEnd, false);

  if (Browser.pointer) {
    endElement.addEventListener(DomEvent.POINTER_CANCEL, onTouchEnd, false);
  }
}

removeDoubleTapListener(obj, id) {
  var pre = '_leaflet_';

  obj.removeEventListener(_touchstart, obj[pre + _touchstart + id], false);
  (Browser.pointer ? document.documentElement : obj).removeEventListener(
          _touchend, obj[pre + _touchend + id], false);

  if (Browser.pointer) {
    document.documentElement.removeEventListener(DomEvent.POINTER_CANCEL, obj[pre + _touchend + id],
      false);
  }
}
