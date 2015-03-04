part of leaflet.dom;
/*
// PosAnimation fallback implementation that powers Leaflet pan animations
// in browsers that don't support CSS3 Transitions.
class PosAnimationTimer {

  Element _el;
  bool _inProgress;
  num _duration, _easeOutPower;
  Point2D _startPos, _offset;
  DateTime _startTime;
  var _animId;

  run(Element el, Point2D newPos, [num duration=0.25, num easeLinearity=0.5]) { // (HTMLElement, Point[, Number, Number])
    this.stop();

    this._el = el;
    this._inProgress = true;
    this._duration = duration;
    this._easeOutPower = 1 / math.max(easeLinearity, 0.2);

    this._startPos = getPosition(el);
    this._offset = newPos - _startPos;
    this._startTime = new DateTime.now();

    this.fire('start');

    this._animate();
  }

  stop() {
    if (!this._inProgress) { return; }

    this._step();
    this._complete();
  }

  _animate() {
    // animation loop
    this._animId = Util.requestAnimFrame(this._animate, this);
    this._step();
  }

  _step() {
    var elapsed = (/*+*/new Date()) - this._startTime,
        duration = this._duration * 1000;

    if (elapsed < duration) {
      this._runFrame(this._easeOut(elapsed / duration));
    } else {
      this._runFrame(1);
      this._complete();
    }
  }

  _runFrame(progress) {
    var pos = this._startPos.add(this._offset.multiplyBy(progress));
    DomUtil.setPosition(this._el, pos);

    this.fire('step');
  }

  _complete() {
    Util.cancelAnimFrame(this._animId);

    this._inProgress = false;
    this.fire('end');
  }

  _easeOut(t) {
    return 1 - math.pow(1 - t, this._easeOutPower);
  }
}*/