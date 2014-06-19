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

  Keyboard(BaseMap map) : super(map);

  initialize(map) {
    this._setPanOffset(map.options.keyboardPanOffset);
    this._setZoomOffset(map.options.keyboardZoomOffset);
  }

  addHooks() {
    var container = this._map._container;

    // make the container focusable by tabbing
    if (container.tabIndex == -1) {
      container.tabIndex = '0';
    }

    L.DomEvent
        .on(container, 'focus', this._onFocus, this)
        .on(container, 'blur', this._onBlur, this)
        .on(container, 'mousedown', this._onMouseDown, this);

    this._map
        .on('focus', this._addHooks, this)
        .on('blur', this._removeHooks, this);
  }

  removeHooks() {
    this._removeHooks();

    var container = this._map._container;

    L.DomEvent
        .off(container, 'focus', this._onFocus, this)
        .off(container, 'blur', this._onBlur, this)
        .off(container, 'mousedown', this._onMouseDown, this);

    this._map
        .off('focus', this._addHooks, this)
        .off('blur', this._removeHooks, this);
  }

  _onMouseDown() {
    if (this._focused) { return; }

    var body = document.body,
        docEl = document.documentElement,
        top = body.scrollTop || docEl.scrollTop,
        left = body.scrollLeft || docEl.scrollLeft;

    this._map._container.focus();

    window.scrollTo(left, top);
  }

  _onFocus() {
    this._focused = true;
    this._map.fire('focus');
  }

  _onBlur() {
    this._focused = false;
    this._map.fire('blur');
  }

  _setPanOffset(pan) {
    var keys = this._panKeys = {},
        codes = this.keyCodes,
        i, len;

    len = codes.left.length;
    for (i = 0; i < len; i++) {
      keys[codes.left[i]] = [-1 * pan, 0];
    }
    len = codes.right.length;
    for (i = 0; i < len; i++) {
      keys[codes.right[i]] = [pan, 0];
    }
    len = codes.down.length;
    for (i = 0; i < len; i++) {
      keys[codes.down[i]] = [0, pan];
    }
    len = codes.up.length;
    for (i = 0; i < len; i++) {
      keys[codes.up[i]] = [0, -1 * pan];
    }
  }

  _setZoomOffset(zoom) {
    var keys = this._zoomKeys = {},
        codes = this.keyCodes,
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

  _addHooks() {
    L.DomEvent.on(document, 'keydown', this._onKeyDown, this);
  }

  _removeHooks() {
    L.DomEvent.off(document, 'keydown', this._onKeyDown, this);
  }

  _onKeyDown(e) {
    var key = e.keyCode,
        map = this._map;

    if (this._panKeys.contains(key)) {

      if (map._panAnim && map._panAnim._inProgress) { return; }

      map.panBy(this._panKeys[key]);

      if (map.options.maxBounds) {
        map.panInsideBounds(map.options.maxBounds);
      }

    } else if (this._zoomKeys.contains(key)) {
      map.setZoom(map.getZoom() + this._zoomKeys[key]);

    } else {
      return;
    }

    L.DomEvent.stop(e);
  }
}