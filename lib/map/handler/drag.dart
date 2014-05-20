part of leaflet.map.handler;

// Drag is used to make the map draggable (with panning inertia), enabled by default.
class Drag extends Handler {
  addHooks() {
    if (!this._draggable) {
      var map = this._map;

      this._draggable = new L.Draggable(map._mapPane, map._container);

      this._draggable.on({
        'dragstart': this._onDragStart,
        'drag': this._onDrag,
        'dragend': this._onDragEnd
      }, this);

      if (map.options.worldCopyJump) {
        this._draggable.on('predrag', this._onPreDrag, this);
        map.on('viewreset', this._onViewReset, this);

        map.whenReady(this._onViewReset, this);
      }
    }
    this._draggable.enable();
  }

  removeHooks() {
    this._draggable.disable();
  }

  moved() {
    return this._draggable && this._draggable._moved;
  }

  _onDragStart() {
    var map = this._map;

    if (map._panAnim) {
      map._panAnim.stop();
    }

    map
        .fire('movestart')
        .fire('dragstart');

    if (map.options.inertia) {
      this._positions = [];
      this._times = [];
    }
  }

  _onDrag() {
    if (this._map.options.inertia) {
      var time = this._lastTime = /*+*/new Date(),
          pos = this._lastPos = this._draggable._newPos;

      this._positions.push(pos);
      this._times.push(time);

      if (time - this._times[0] > 200) {
        this._positions.shift();
        this._times.shift();
      }
    }

    this._map
        .fire('move')
        .fire('drag');
  }

  _onViewReset() {
    // TODO fix hardcoded Earth values
    var pxCenter = this._map.getSize()._divideBy(2),
        pxWorldCenter = this._map.latLngToLayerPoint([0, 0]);

    this._initialWorldOffset = pxWorldCenter.subtract(pxCenter).x;
    this._worldWidth = this._map.project([0, 180]).x;
  }

  _onPreDrag() {
    // TODO refactor to be able to adjust map pane position after zoom
    var worldWidth = this._worldWidth,
        halfWidth = Math.round(worldWidth / 2),
        dx = this._initialWorldOffset,
        x = this._draggable._newPos.x,
        newX1 = (x - halfWidth + dx) % worldWidth + halfWidth - dx,
        newX2 = (x + halfWidth + dx) % worldWidth - halfWidth - dx,
        newX = Math.abs(newX1 + dx) < Math.abs(newX2 + dx) ? newX1 : newX2;

    this._draggable._newPos.x = newX;
  }

  _onDragEnd(e) {
    var map = this._map,
        options = map.options,
        delay = /*+*/new Date() - this._lastTime,

        noInertia = !options.inertia || delay > options.inertiaThreshold || !this._positions[0];

    map.fire('dragend', e);

    if (noInertia) {
      map.fire('moveend');

    } else {

      var direction = this._lastPos.subtract(this._positions[0]),
          duration = (this._lastTime + delay - this._times[0]) / 1000,
          ease = options.easeLinearity,

          speedVector = direction.multiplyBy(ease / duration),
          speed = speedVector.distanceTo([0, 0]),

          limitedSpeed = Math.min(options.inertiaMaxSpeed, speed),
          limitedSpeedVector = speedVector.multiplyBy(limitedSpeed / speed),

          decelerationDuration = limitedSpeed / (options.inertiaDeceleration * ease),
          offset = limitedSpeedVector.multiplyBy(-decelerationDuration / 2).round();

      if (!offset.x || !offset.y) {
        map.fire('moveend');

      } else {
        offset = map._limitOffset(offset, map.options.maxBounds);

        L.Util.requestAnimFrame(() {
          map.panBy(offset, {
            duration: decelerationDuration,
            easeLinearity: ease,
            noMoveStart: true
          });
        });
      }
    }
  }
}