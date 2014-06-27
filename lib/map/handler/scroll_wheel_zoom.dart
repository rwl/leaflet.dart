part of leaflet.map.handler;

/**
 * ScrollWheelZoom is used by L.Map to enable mouse scroll wheel zoom on the map.
 */
class ScrollWheelZoom extends Handler {

  num _delta;
  Point2D _lastMousePos;
  DateTime _startTime;
  Timer _timer;

  ScrollWheelZoom(LeafletMap map) : super(map);

  addHooks() {
    dom.on(map.getContainer(), 'mousewheel', _onWheelScroll, this);
    dom.on(map.getContainer(), 'MozMousePixelScroll', dom.preventDefault);
    _delta = 0;
  }

  removeHooks() {
    dom.off(map.getContainer(), 'mousewheel', _onWheelScroll);
    dom.off(map.getContainer(), 'MozMousePixelScroll', dom.preventDefault);
  }

  _onWheelScroll(html.MouseEvent e) {
    final delta = dom.getWheelDelta(e);

    _delta += delta;
    _lastMousePos = map.mouseEventToContainerPoint(e);

    if (_startTime = null) {
      _startTime = /*+*/new DateTime.now();
    }

    var left = math.max(40 - (/*+*/new DateTime.now().difference(_startTime).inMilliseconds), 0);

    //clearTimeout(_timer);
    //_timer = setTimeout(L.bind(_performZoom, this), left);
    _timer.cancel();
    _timer = new Timer(new Duration(milliseconds: left), () {
      _performZoom();
    });

    dom.preventDefault(e);
    dom.stopPropagation(e);
  }

  _performZoom() {
    num delta = _delta;
    final zoom = map.getZoom();

    delta = delta > 0 ? delta.ceil() : delta.floor();
    delta = math.max(math.min(delta, 4), -4);
    delta = map.limitZoom(zoom + delta) - zoom;

    _delta = 0;
    _startTime = null;

    if (delta == 0) {
      return;
    }

    if (map.interactionOptions.scrollWheelZoom == 'center') {
      map.setZoom(zoom + delta);
    } else {
      map.setZoomAround(_lastMousePos, zoom + delta);
    }
  }
}
