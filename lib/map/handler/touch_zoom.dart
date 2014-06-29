part of leaflet.map.handler;

/**
 * TouchZoom is used by Map to add pinch zoom on supported mobile browsers.
 */
class TouchZoom extends Handler {

  Point2D _startCenter, _centerOffset, _delta;
  bool _moved, _zooming;
  num _scale, _startDist;

  /**
   * For internal use.
   */
  bool get zooming => _zooming;

  StreamSubscription<html.Event> _touchStartSubscription, _touchMoveSubscription, _touchEndSubscription;

  TouchZoom(LeafletMap map) : super(map);

  addHooks() {
    //dom.on(this.map.getContainer(), 'touchstart', this._onTouchStart, this);
    _touchStartSubscription = this.map.getContainer().onTouchStart.listen(_onTouchStart);
  }

  removeHooks() {
    //dom.off(this.map.getContainer(), 'touchstart', this._onTouchStart);
    if (_touchStartSubscription != null) {
      _touchStartSubscription.cancel();
    }
  }

  _onTouchStart(html.TouchEvent e) {
    if (e.touches == null || e.touches.length != 2 || map.animatingZoom || this._zooming) { return; }

    final p1 = map.mouseEventToLayerPoint(e.touches.first),
        p2 = map.mouseEventToLayerPoint(e.touches.last/*[1]*/),
        viewCenter = map._getCenterLayerPoint();

    this._startCenter = (p1 + p2) / 2;
    this._startDist = p1.distanceTo(p2);

    this._moved = false;
    this._zooming = true;

    this._centerOffset = viewCenter.subtract(this._startCenter);

    if (map.panAnim != null) {
      map.panAnim.stop();
    }

    //dom.on(document, 'touchmove', this._onTouchMove, this);
    //dom.on(document, 'touchend', this._onTouchEnd, this);
    document.onTouchMove.listen(_onTouchMove);
    document.onTouchEnd.listen(_onTouchEnd);

    //dom.preventDefault(e);
    e.preventDefault();
  }

  int _animRequestId;

  _onTouchMove(html.TouchEvent e) {
    if (e.touches == null || e.touches.length != 2 || !this._zooming) {
      return;
    }

    final p1 = map.mouseEventToLayerPoint(e.touches.first),
        p2 = map.mouseEventToLayerPoint(e.touches.last/*[1]*/);

    this._scale = p1.distanceTo(p2) / this._startDist;
    this._delta = ((p1 + p2) / 2) - this._startCenter;

    if (this._scale == 1) { return; }

    if (map.options.bounceAtZoomLimits = null) {
      if ((map.getZoom() == map.getMinZoom() && this._scale < 1) ||
          (map.getZoom() == map.getMaxZoom() && this._scale > 1)) { return; }
    }

    if (!this._moved) {
      map.mapPane.classes.add('leaflet-touching');

      map.fire(EventType.MOVESTART);
      map.fire(EventType.ZOOMSTART);

      this._moved = true;
    }

    //cancelAnimFrame(this._animRequest);
    //this._animRequest = requestAnimFrame(
    //        this._updateOnMove, this, true, this.map.getContainer());
    window.cancelAnimationFrame(_animRequestId);
    _animRequestId = window.requestAnimationFrame(_updateOnMove);

    //dom.preventDefault(e);
    e.preventDefault();
  }

  void _updateOnMove(num highResTime) {
    final origin = this._getScaleOrigin(),
        center = map.layerPointToLatLng(origin),
        zoom = map.getScaleZoom(this._scale);

    map.animateZoom(center, zoom, this._startCenter, this._scale, this._delta);
  }

  _onTouchEnd([html.Event e]) {
    if (!this._moved || !this._zooming) {
      this._zooming = false;
      return;
    }

    this._zooming = false;
    map.mapPane.classes.remove('leaflet-touching');
    //cancelAnimFrame(this._animRequest);
    window.cancelAnimationFrame(_animRequestId);

    //dom.off(document, 'touchmove', this._onTouchMove);
    //dom.off(document, 'touchend', this._onTouchEnd);
    if (_touchMoveSubscription != null) {
      _touchMoveSubscription.cancel();
    }
    if (_touchEndSubscription != null) {
      _touchEndSubscription.cancel();
    }

    final origin = this._getScaleOrigin(),
        center = map.layerPointToLatLng(origin),

        oldZoom = map.getZoom(),
        floatZoomDelta = map.getScaleZoom(this._scale) - oldZoom,
        roundZoomDelta = (floatZoomDelta > 0 ?
                floatZoomDelta.ceil() : floatZoomDelta.floor()),

        zoom = map.limitZoom(oldZoom + roundZoomDelta),
        scale = map.getZoomScale(zoom) / this._scale;

    map.animateZoom(center, zoom, origin, scale);
  }

  Point2D _getScaleOrigin() {
    final centerOffset = (this._centerOffset - this._delta) / this._scale;
    return this._startCenter + centerOffset;
  }
}