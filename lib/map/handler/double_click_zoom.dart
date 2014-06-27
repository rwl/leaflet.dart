part of leaflet.map.handler;

/**
 * DoubleClickZoom is used to handle double-click zoom on the map, enabled
 * by default.
 */
class DoubleClickZoom extends Handler {

  DoubleClickZoom(LeafletMap map) : super(map);

  void addHooks() {
    map.on(EventType.DBLCLICK, _onDoubleClick, this);
  }

  void removeHooks() {
    map.off(EventType.DBLCLICK, _onDoubleClick, this);
  }

  void _onDoubleClick(Object obj, MouseEvent e) {
    final zoom = map.getZoom() + (e.originalEvent.shiftKey ? -1 : 1);

    if (map.interactionOptions.doubleClickZoom == 'center') {
      map.setZoom(zoom);
    } else {
      map.setZoomAround(e.containerPoint, zoom);
    }
  }
}
