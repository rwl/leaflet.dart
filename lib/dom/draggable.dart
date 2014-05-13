part of leaflet.dom;

// Draggable allows you to add dragging capabilities to any element. Supports mobile devices too.
class Draggable extends Object with Events {

  static var START = Browser.touch ? ['touchstart', 'mousedown'] : ['mousedown'];
  static var END = {
      'mousedown': 'mouseup',
      'touchstart': 'touchend',
      'pointerdown': 'touchend',
      'MSPointerDown': 'touchend'
    };
  static var MOVE = {
      'mousedown': 'mousemove',
      'touchstart': 'touchmove',
      'pointerdown': 'touchmove',
      'MSPointerDown': 'touchmove'
    };

  var _element, _dragStartTarget;
  bool _enabled, _moved, _moving;
  Point _startPoint;
  var _startPos, _newPos, _animRequest;

  Draggable(element, dragStartTarget) {
    this._element = element;
    this._dragStartTarget = dragStartTarget || element;
  }

  enable() {
    if (this._enabled) { return; }

    for (var i = Draggable.START.length - 1; i >= 0; i--) {
      DomEvent.on(this._dragStartTarget, Draggable.START[i], this._onDown, this);
    }

    this._enabled = true;
  }

  disable() {
    if (!this._enabled) { return; }

    for (var i = Draggable.START.length - 1; i >= 0; i--) {
      DomEvent.off(this._dragStartTarget, Draggable.START[i], this._onDown, this);
    }

    this._enabled = false;
    this._moved = false;
  }

  _onDown(e) {
    this._moved = false;

    if (e.shiftKey || ((e.which != 1) && (e.button != 1) && !e.touches)) { return; }

    DomEvent.stopPropagation(e);

    if (Draggable._disabled) { return; }

    DomUtil.disableImageDrag();
    DomUtil.disableTextSelection();

    if (this._moving) { return; }

    var first = e.touches ? e.touches[0] : e;

    this._startPoint = new Point(first.clientX, first.clientY);
    this._startPos = this._newPos = DomUtil.getPosition(this._element);

    DomEvent
        .on(document, Draggable.MOVE[e.type], this._onMove, this)
        .on(document, Draggable.END[e.type], this._onUp, this);
  }

  _onMove(e) {
    if (e.touches && e.touches.length > 1) {
      this._moved = true;
      return;
    }

    var first = (e.touches && e.touches.length == 1 ? e.touches[0] : e),
        newPoint = new Point(first.clientX, first.clientY),
        offset = newPoint.subtract(this._startPoint);

    if (!offset.x && !offset.y) { return; }

    DomEvent.preventDefault(e);

    if (!this._moved) {
      this.fire('dragstart');

      this._moved = true;
      this._startPos = DomUtil.getPosition(this._element).subtract(offset);

      DomUtil.addClass(document.body, 'leaflet-dragging');
      DomUtil.addClass((e.target || e.srcElement), 'leaflet-drag-target');
    }

    this._newPos = this._startPos.add(offset);
    this._moving = true;

    Util.cancelAnimFrame(this._animRequest);
    this._animRequest = Util.requestAnimFrame(this._updatePosition, this, true, this._dragStartTarget);
  }

  _updatePosition() {
    this.fire('predrag');
    DomUtil.setPosition(this._element, this._newPos);
    this.fire('drag');
  }

  _onUp(e) {
    DomUtil.removeClass(document.body, 'leaflet-dragging');
    DomUtil.removeClass((e.target || e.srcElement), 'leaflet-drag-target');

    for (var i in Draggable.MOVE) {
      DomEvent
          .off(document, Draggable.MOVE[i], this._onMove)
          .off(document, Draggable.END[i], this._onUp);
    }

    DomUtil.enableImageDrag();
    DomUtil.enableTextSelection();

    if (this._moved && this._moving) {
      // ensure drag is not fired after dragend
      Util.cancelAnimFrame(this._animRequest);

      this.fire('dragend', {
        'distance': this._newPos.distanceTo(this._startPos)
      });
    }

    this._moving = false;
  }
}