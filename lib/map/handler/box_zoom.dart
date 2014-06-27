part of leaflet.map.handler;

/**
 * BoxZoom is used to add shift-drag zoom interaction to the map
 * (zoom to a selected bounding box), enabled by default.
 */
class BoxZoom extends Handler {

  Element _container, _pane, _box;
  bool _moved;
  Point2D _startLayerPoint;

  BoxZoom(LeafletMap map) : super(map) {
    _container = map.getContainer();
    _pane = map.panes['overlayPane'];
    _moved = false;
  }

  void addHooks() {
    dom.on(_container, 'mousedown', _onMouseDown, this);
  }

  void removeHooks() {
    dom.off(_container, 'mousedown', _onMouseDown);
    _moved = false;
  }

  bool moved() {
    return _moved;
  }

  _onMouseDown(html.MouseEvent e) {
    _moved = false;

    if (!e.shiftKey || ((e.which != 1) && (e.button != 1))) {
      return false;
    }

    dom.disableTextSelection();
    dom.disableImageDrag();

    _startLayerPoint = map.mouseEventToLayerPoint(e);

    dom.on(document, 'mousemove', _onMouseMove, this);
    dom.on(document, 'mouseup', _onMouseUp, this);
    dom.on(document, 'keydown', _onKeyDown, this);
  }

  void _onMouseMove(html.MouseEvent e) {
    if (!_moved) {
      _box = dom.create('div', 'leaflet-zoom-box', _pane);
      dom.setPosition(_box, _startLayerPoint);

      //TODO refactor: move cursor to styles
      _container.style.cursor = 'crosshair';
      map.fire(EventType.BOXZOOMSTART);
    }

    final startPoint = _startLayerPoint,
        box = _box,

        layerPoint = map.mouseEventToLayerPoint(e),
        offset = layerPoint.subtract(startPoint),

        newPos = new Point2D(math.min(layerPoint.x, startPoint.x), math.min(layerPoint.y, startPoint.y));

    dom.setPosition(box, newPos);

    _moved = true;

    // TODO refactor: remove hardcoded 4 pixels
    box.style.width = '${math.max(0, (offset.x).abs() - 4)}px';
    box.style.height = '${math.max(0, (offset.y).abs() - 4)}px';
  }

  void _finish() {
    if (_moved) {
      //_pane.removeChild(_box);
      _box.remove();
      _container.style.cursor = '';
    }

    dom.enableTextSelection();
    dom.enableImageDrag();

    dom.off(document, 'mousemove', _onMouseMove);
    dom.off(document, 'mouseup', _onMouseUp);
    dom.off(document, 'keydown', _onKeyDown);
  }

  void _onMouseUp(html.MouseEvent e) {

    _finish();

    final layerPoint = map.mouseEventToLayerPoint(e);

    if (_startLayerPoint == layerPoint) {
      return;
    }

    final bounds = new LatLngBounds.between(map.layerPointToLatLng(_startLayerPoint), map.layerPointToLatLng(layerPoint));

    map.fitBounds(bounds);

    map.fire(EventType.BOXZOOMEND, {
      'boxZoomBounds': bounds
    });
  }

  _onKeyDown(html.KeyboardEvent e) {
    if (e.keyCode == 27) {
      _finish();
    }
  }
}
