part of leaflet.map.handler;

/**
 * DoubleClickZoom is used to handle double-click zoom on the map, enabled
 * by default.
 */
class DoubleClickZoom extends Handler {

  StreamSubscription<MouseEvent> _doubleClickSubscription;

  DoubleClickZoom(LeafletMap map) : super(map);

  void addHooks() {
    //map.on(EventType.DBLCLICK, _onDoubleClick);
    _doubleClickSubscription = map.onDblClick.listen(_onDoubleClick);
  }

  void removeHooks() {
    //map.off(EventType.DBLCLICK, _onDoubleClick);
    _doubleClickSubscription.cancel();
  }

  void _onDoubleClick(MouseEvent e) {
    final zoom = map.getZoom() + ((e.originalEvent as html.MouseEvent).shiftKey ? -1 : 1);

    if (map.options.doubleClickZoom == 'center') {
      map.setZoom(zoom);
    } else {
      map.setZoomAround(e.containerPoint, zoom);
    }
  }
}
