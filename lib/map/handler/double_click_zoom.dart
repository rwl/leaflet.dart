part of leaflet.map.handler;

// DoubleClickZoom is used to handle double-click zoom on the map, enabled by default.
class DoubleClickZoom extends Handler {
  addHooks() {
    this._map.on('dblclick', this._onDoubleClick, this);
  }

  removeHooks() {
    this._map.off('dblclick', this._onDoubleClick, this);
  }

  _onDoubleClick(e) {
    var map = this._map,
        zoom = map.getZoom() + (e.originalEvent.shiftKey ? -1 : 1);

    if (map.options.doubleClickZoom == 'center') {
      map.setZoom(zoom);
    } else {
      map.setZoomAround(e.containerPoint, zoom);
    }
  }
}