part of leaflet.dom;

/// Draggable allows you to add dragging capabilities to any element. Supports
/// mobile devices too.
class Draggable {

  static bool disabled = false;// TODO implement global drag disable

  //static var START = browser.touch ? ['touchstart', 'mousedown'] : ['mousedown'];
//  static var END = {
//      'mousedown': 'mouseup',
//      'touchstart': 'touchend',
//      'pointerdown': 'touchend',
//      'MSPointerDown': 'touchend'
//    };
//  static var MOVE = {
//      'mousedown': 'mousemove',
//      'touchstart': 'touchmove',
//      'pointerdown': 'touchmove',
//      'MSPointerDown': 'touchmove'
//    };

  Element _element, _dragStartTarget;
  bool _enabled = false, _moved, _moving = false;
  Point2D _startPoint;
  Point2D _startPos, _newPos;
  int _animRequest;

  bool get moved =>_moved;
  Point2D get newPos => _newPos;

  /// Creates a Draggable object for moving the given element when you start
  /// dragging the dragHandle element (equals the element itself by default).
  Draggable(this._element, dragStartTarget) {
    _dragStartTarget = firstNonNull(dragStartTarget, _element);
  }

  StreamSubscription<html.MouseEvent> _mouseDownSubscription;

  /// Enables the dragging ability.
  enable() {
    if (_enabled) {
      return;
    }

//    for (var i = Draggable.START.length - 1; i >= 0; i--) {
//      _dragStartTarget.addEventListener(Draggable.START[i],_onDown);
//    }
    if (_mouseDownSubscription != null) {
      _mouseDownSubscription.cancel();
    }
    _mouseDownSubscription = _dragStartTarget.onMouseDown.listen(_onDown);

    _enabled = true;
  }

  /// Disables the dragging ability.
  disable() {
    if (!_enabled) {
      return;
    }

//    for (var i = Draggable.START.length - 1; i >= 0; i--) {
//      _dragStartTarget.removeEventListener(Draggable.START[i],_onDown);
//    }
    if (_mouseDownSubscription != null) {
      _mouseDownSubscription.cancel();
      _mouseDownSubscription = null;
    }

    _enabled = false;
    _moved = false;
  }

  StreamSubscription<html.MouseEvent> _mouseMoveSubscription;
  StreamSubscription<html.MouseEvent> _mouseUpSubscription;

  _onDown(html.MouseEvent e) {
    _moved = false;

    if (e.shiftKey || ((e.which != 1) && (e.button != 1) /*&& !e.touches*/)) {
      return;
    }

    stopPropagation(e);

    if (Draggable.disabled) {
      return;
    }

    disableImageDrag();
    disableTextSelection();

    if (_moving) {
      return;
    }

    var first = e;//.touches ? e.touches[0] : e;

    _startPoint = new Point2D(first.client.x, first.client.y);
    _startPos = _newPos = getPosition(_element);

//    document
//        ..addEventListener(Draggable.MOVE[e.type], _onMove)
//        ..addEventListener(Draggable.END[e.type], _onUp);
    if (_mouseMoveSubscription != null) {
      _mouseMoveSubscription.cancel();
    }
    _mouseMoveSubscription = document.onMouseMove.listen(_onMove);

    if (_mouseUpSubscription != null) {
      _mouseUpSubscription.cancel();
    }
    _mouseUpSubscription = document.onMouseUp.listen(_onUp);
  }

  _onMove(Event e) {
    Element target = e.target;

    if (e is TouchEvent && e.touches.length > 1) {
      _moved = true;
      return;
    }

    var first = (e is TouchEvent && e.touches.length == 1 ? e.touches.first : e);
    var newPoint = new Point2D(first.clientX, first.clientY);
    var offset = newPoint - _startPoint;

    if (offset.x == 0 && offset.y == 0) {
      return;
    }

    preventDefault(e);

    if (!_moved) {
      fire(EventType.DRAGSTART);

      _moved = true;
      _startPos = getPosition(_element) - offset;

      document.body.classes.add('leaflet-dragging');
      target.classes.add('leaflet-drag-target');
    }

    _newPos = _startPos + offset;
    _moving = true;

    if (_animRequest != null) {
      window.cancelAnimationFrame(_animRequest);
    }
    _animRequest = window.requestAnimationFrame(_updatePosition);
//    _animRequest = Util.requestAnimFrame(_updatePosition, this, true, _dragStartTarget);
  }

  _updatePosition(_) {
    fire(EventType.PREDRAG);
    setPosition(_element, _newPos);
    fire(EventType.DRAG);
  }

  _onUp(e) {
    document.body.classes.remove('leaflet-dragging');
    e.target.classes.remove('leaflet-drag-target');

//    for (var i in Draggable.MOVE.keys) {
//      document
//        ..removeEventListener(Draggable.MOVE[i], _onMove)
//        ..removeEventListener(Draggable.END[i], _onUp);
//    }
    if (_mouseMoveSubscription != null) {
      _mouseMoveSubscription.cancel();
    }
    if (_mouseUpSubscription != null) {
      _mouseUpSubscription.cancel();
    }

    enableImageDrag();
    enableTextSelection();

    if (_moved && _moving) {
      // ensure drag is not fired after dragend
      if (_animRequest != null) {
        window.cancelAnimationFrame(_animRequest);
      }

      fireEvent(new DragEndEvent(_newPos.distanceTo(_startPos)));
    }

    _moving = false;
  }

  void fire(EventType eventType) {
    final event = new MapEvent(eventType);
    fireEvent(event);
  }

  void fireEvent(MapEvent event) {
    switch (event.type) {
      case EventType.DRAGSTART:
        _dragStartController.add(event);
        break;
      case EventType.PREDRAG:
        _preDragController.add(event);
        break;
      case EventType.DRAG:
        _dragController.add(event);
        break;
      case EventType.DRAGEND:
        _dragEndController.add(event);
        break;
    }
  }

  StreamController<MapEvent> _dragStartController = new StreamController.broadcast();
  StreamController<MapEvent> _preDragController = new StreamController.broadcast();
  StreamController<MapEvent> _dragController = new StreamController.broadcast();
  StreamController<MapEvent> _dragEndController = new StreamController.broadcast();

  Stream<MapEvent> get onDragStart => _dragStartController.stream;
  Stream<MapEvent> get onPreDrag => _preDragController.stream;
  Stream<MapEvent> get onDrag => _dragController.stream;
  Stream<MapEvent> get onDragEnd => _dragEndController.stream;
}
