part of leaflet.map.handler;

/**
 * Keyboard is handling keyboard interaction with the map, enabled by default.
 */
class Keyboard extends Handler {

  var keyCodes = {
    'left':    [37],
    'right':   [39],
    'down':    [40],
    'up':      [38],
    'zoomIn':  [187, 107, 61, 171],
    'zoomOut': [189, 109, 173]
  };

  bool _focused;
  Map _panKeys;
  Map _zoomKeys;

  Keyboard(LeafletMap map) : super(map);

  initialize(map) {
    _setPanOffset(map.options.keyboardPanOffset);
    _setZoomOffset(map.options.keyboardZoomOffset);
  }

  StreamSubscription<html.Event> _focusSubscription, _blurSubscription, _mouseDownSubscription;

  addHooks() {
    final container = map.getContainer();

    // make the container focusable by tabbing
    if (container.tabIndex == -1) {
      container.tabIndex = '0';
    }

    //dom.on(container, 'focus', _onFocus, this);
    //dom.on(container, 'blur', _onBlur, this);
    //dom.on(container, 'mousedown', _onMouseDown, this);
    _focusSubscription = container.onFocus.listen(_onFocus);
    _blurSubscription = container.onBlur.listen(_onBlur);
    _mouseDownSubscription = container.onMouseDown.listen(_onMouseDown);

    map.on(EventType.FOCUS, _addHooks);
    map.on(EventType.BLUR, _removeHooks);
  }

  removeHooks() {
    _removeHooks();

    final container = map.getContainer();

    //dom.off(container, 'focus', _onFocus);
    //dom.off(container, 'blur', _onBlur);
    //dom.off(container, 'mousedown', _onMouseDown);
    if (_focusSubscription != null) {
      _focusSubscription.cancel();
    }
    if (_blurSubscription != null) {
      _blurSubscription.cancel();
    }
    if (_mouseDownSubscription != null) {
      _mouseDownSubscription.cancel();
    }

    map.off(EventType.FOCUS, _addHooks);
    map.off(EventType.BLUR, _removeHooks);
  }

  _onMouseDown([html.MouseEvent e]) {
    if (_focused) { return; }

    final  body = document.body,
        docEl = document.documentElement,
        top = body.scrollTop /*|*/| docEl.scrollTop,
        left = body.scrollLeft /*|*/| docEl.scrollLeft;

    map.getContainer().focus();

    window.scrollTo(left, top);
  }

  _onFocus([html.Event e]) {
    _focused = true;
    map.fire(EventType.FOCUS);
  }

  _onBlur([html.Event e]) {
    _focused = false;
    map.fire(EventType.BLUR);
  }

  _setPanOffset(pan) {
    final keys = _panKeys = {},
        codes = keyCodes;

    for (int i = 0; i < codes.left.length; i++) {
      keys[codes.left[i]] = [-1 * pan, 0];
    }
    for (int i = 0; i < codes.right.length; i++) {
      keys[codes.right[i]] = [pan, 0];
    }
    for (int i = 0; i < codes.down.length; i++) {
      keys[codes.down[i]] = [0, pan];
    }
    for (int i = 0; i < codes.up.length; i++) {
      keys[codes.up[i]] = [0, -1 * pan];
    }
  }

  _setZoomOffset(zoom) {
    var keys = _zoomKeys = {},
        codes = keyCodes,
        i, len;

    len = codes.zoomIn.length;
    for (i = 0; i < len; i++) {
      keys[codes.zoomIn[i]] = zoom;
    }
    len = codes.zoomOut.length;
    for (i = 0; i < len; i++) {
      keys[codes.zoomOut[i]] = -zoom;
    }
  }

  StreamSubscription<html.KeyboardEvent> _keyDownSubscription;

  _addHooks([Object obj=null, Event e=null]) {
    //dom.on(document, 'keydown', _onKeyDown, this);
    _keyDownSubscription = document.onKeyDown.listen(_onKeyDown);
  }

  _removeHooks([Object obj=null, Event e=null]) {
    //dom.off(document, 'keydown', _onKeyDown);
    if (_keyDownSubscription != null) {
      _keyDownSubscription.cancel();
    }
  }

  _onKeyDown(html.KeyboardEvent e) {
    final key = e.keyCode;

    if (_panKeys.containsKey(key)) {

      if (map.panAnim != null && map.panAnim.inProgress) { return; }

      map.panBy(_panKeys[key]);

      if (map.stateOptions.maxBounds != null) {
        map.panInsideBounds(map.stateOptions.maxBounds);
      }

    } else if (_zoomKeys.containsKey(key)) {
      map.setZoom(map.getZoom() + _zoomKeys[key]);

    } else {
      return;
    }

    dom.stop(e);
  }
}