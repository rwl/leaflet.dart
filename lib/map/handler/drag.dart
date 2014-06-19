part of leaflet.map.handler;

/**
 * Drag is used to make the map draggable (with panning inertia), enabled
 * by default.
 */
class Drag extends Handler {

  dom.Draggable _draggable;
  List<DateTime> _times;
  List<geom.Point> _positions;
  DateTime _lastTime;
  geom.Point _lastPos;
  num _initialWorldOffset, _worldWidth;

  Drag(BaseMap map) : super(map);

  addHooks() {
    if (_draggable == null) {

      _draggable = new dom.Draggable(map.mapPane, map.getContainer());

      _draggable.on(EventType.DRAGSTART, _onDragStart, this);
      _draggable.on(EventType.DRAG, _onDrag, this);
      _draggable.on(EventType.DRAGEND, _onDragEnd, this);

      if (map.interactionOptions.worldCopyJump) {
        _draggable.on(EventType.PREDRAG, _onPreDrag, this);
        map.on(EventType.VIEWRESET, _onViewReset, this);

        map.whenReady(_onViewReset, this);
      }
    }
    _draggable.enable();
  }

  removeHooks() {
    _draggable.disable();
  }

  moved() {
    return _draggable && _draggable.moved;
  }

  _onDragStart(Object obj, Event e) {
    if (map.panAnim != null) {
      map.panAnim.stop();
    }

    map.fire(EventType.MOVESTART);
    map.fire(EventType.DRAGSTART);

    if (map.panningInertiaOptions.inertia) {
      _positions = [];
      _times = [];
    }
  }

  _onDrag(Object obj, Event e) {
    if (map.panningInertiaOptions.inertia) {
      final time = _lastTime = /*+*/new DateTime.now(),
          pos = _lastPos = _draggable.newPos;

      _positions.add(pos);
      _times.add(time);

      if (time.difference(_times[0]) > 200) {
        _positions.removeAt(0);
        _times.removeAt(0);
      }
    }

    map.fire(EventType.MOVE);
    map.fire(EventType.DRAG);
  }

  _onViewReset(Object obj, Event e) {
    // TODO fix hardcoded Earth values
    final pxCenter = map.getSize() / 2,
        pxWorldCenter = map.latLngToLayerPoint(new LatLng(0, 0));

    _initialWorldOffset = (pxWorldCenter - pxCenter).x;
    _worldWidth = map.project(new LatLng(0, 180)).x;
  }

  _onPreDrag(Object obj, Event e) {
    // TODO refactor to be able to adjust map pane position after zoom
    final worldWidth = _worldWidth,
        halfWidth = (worldWidth / 2).round(),
        dx = _initialWorldOffset,
        x = _draggable.newPos.x,
        newX1 = (x - halfWidth + dx) % worldWidth + halfWidth - dx,
        newX2 = (x + halfWidth + dx) % worldWidth - halfWidth - dx,
        newX = (newX1 + dx).abs() < (newX2 + dx).abs() ? newX1 : newX2;

    _draggable.newPos.x = newX;
  }

  _onDragEnd(Object obj, Event e) {
    final options = map.panningInertiaOptions,
        delay = /*+*/new DateTime.now().difference(_lastTime),

        noInertia = !options.inertia || delay > options.inertiaThreshold || _positions.length == 0;

    map.fire(EventType.DRAGEND, e);

    if (noInertia) {
      map.fire(EventType.MOVEEND);

    } else {

      final direction = _lastPos - _positions[0],
          duration = (_lastTime.add(delay).difference(_times[0])),// / 1000,
          ease = map.panOptions.easeLinearity,

          speedVector = direction * (ease / duration),
          speed = speedVector.distanceTo(new geom.Point(0, 0)),

          limitedSpeed = math.min(options.inertiaMaxSpeed, speed),
          limitedSpeedVector = speedVector * (limitedSpeed / speed),

          decelerationDuration = limitedSpeed / (options.inertiaDeceleration * ease);
      geom.Point offset = (limitedSpeedVector * (-decelerationDuration / 2)).rounded();

      if (offset.x == 0 || offset.y == 0) {
        map.fire(EventType.MOVEEND);

      } else {
        offset = map.limitOffset(offset, map.stateOptions.maxBounds);

        requestAnimFrame(() {
          map.panBy(offset, {
            'duration': decelerationDuration,
            'easeLinearity': ease,
            'noMoveStart': true
          });
        });
      }
    }
  }
}
