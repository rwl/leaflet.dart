part of leaflet.map.handler;

/**
 * Tap is used to enable mobile hacks like quick taps and long hold.
 */
class Tap extends Handler {

  bool _fireClick;
  Timer _holdTimeout;
  Point2D _startPos, _newPos;

  StreamSubscription<Event> _touchStartSubscription, _touchMoveSubscription, _touchEndSubscription;

  Tap(LeafletMap map) : super(map);

  void addHooks() {
    //dom.on(map.getContainer(), 'touchstart', _onDown, this);
    _touchStartSubscription = map.getContainer().onTouchStart.listen(_onDown);
  }

  void removeHooks() {
    //dom.off(map.getContainer(), 'touchstart', _onDown);
    if (_touchStartSubscription != null) {
      _touchStartSubscription.cancel();
    }
  }

  void _onDown(html.TouchEvent e) {
    if (e.touches == null) { return; }

    //dom.preventDefault(e);
    e.preventDefault();

    _fireClick = true;

    // don't simulate click or track longpress if more than 1 touch
    if (e.touches.length > 1) {
      _fireClick = false;
      //clearTimeout(_holdTimeout);
      _holdTimeout.cancel();
      return;
    }

    final first = e.touches.first,
        el = first.target;

    _startPos = _newPos = new Point2D(first.client.x, first.client.y);

    // if touching a link, highlight it
    if (el.tagName && el.tagName.toLowerCase() == 'a') {
      el.classes.add('leaflet-active');
    }

    // simulate long hold but setting a timeout
    //_holdTimeout = setTimeout(L.bind(() {
    _holdTimeout = new Timer(new Duration(milliseconds: 1000), () {
      if (_isTapValid()) {
        _fireClick = false;
        _onUp();
        _simulateEvent('contextmenu', first);
      }
    });
    //}, this), 1000);

    //dom.on(document, 'touchmove', _onMove, this);
    //dom.on(document, 'touchend', _onUp, this);
    _touchMoveSubscription = document.onTouchMove.listen(_onMove);
    _touchEndSubscription = document.onTouchEnd.listen(_onUp);
  }

  void _onUp([e=null]) {
    //clearTimeout(_holdTimeout);
    _holdTimeout.cancel();

    //dom.off(document, 'touchmove', _onMove);
    //dom.off(document, 'touchend', _onUp);
    if (_touchMoveSubscription != null) {
      _touchMoveSubscription.cancel();
    }
    if (_touchEndSubscription != null) {
      _touchEndSubscription.cancel();
    }

    if (_fireClick && e && e.changedTouches) {

      var first = e.changedTouches[0],
          el = first.target;

      if (el && el.tagName && el.tagName.toLowerCase() == 'a') {
        el.classes.remove('leaflet-active');
      }

      // simulate click if the touch didn't move too much
      if (_isTapValid()) {
        _simulateEvent('click', first);
      }
    }
  }

  bool _isTapValid() {
    return _newPos.distanceTo(_startPos) <= map.options.tapTolerance;
  }

  _onMove(html.TouchEvent e) {
    final first = e.touches.first;
    _newPos = new Point2D(first.client.x, first.client.y);
  }

  _simulateEvent(type, html.TouchEvent e) {
    final simulatedEvent = document.createEvent('MouseEvents');

    simulatedEvent._simulated = true;
    e.target._simulatedClick = true;

    simulatedEvent.initMouseEvent(
            type, true, true, window, 1,
            e.screenX, e.screenY,
            e.clientX, e.clientY,
            false, false, false, false, 0, null);

    e.target.dispatchEvent(simulatedEvent);
  }
}