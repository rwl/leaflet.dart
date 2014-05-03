
// PosAnimation fallback implementation that powers Leaflet pan animations
// in browsers that don't support CSS3 Transitions.
class PosAnimationTimer {
  run(el, newPos, duration, easeLinearity) { // (HTMLElement, Point[, Number, Number])
    this.stop();

    this._el = el;
    this._inProgress = true;
    this._duration = duration || 0.25;
    this._easeOutPower = 1 / Math.max(easeLinearity || 0.5, 0.2);

    this._startPos = L.DomUtil.getPosition(el);
    this._offset = newPos.subtract(this._startPos);
    this._startTime = /*+*/new Date();

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
    this._animId = L.Util.requestAnimFrame(this._animate, this);
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
    L.DomUtil.setPosition(this._el, pos);

    this.fire('step');
  }

  _complete() {
    L.Util.cancelAnimFrame(this._animId);

    this._inProgress = false;
    this.fire('end');
  }

  _easeOut(t) {
    return 1 - Math.pow(1 - t, this._easeOutPower);
  }
}