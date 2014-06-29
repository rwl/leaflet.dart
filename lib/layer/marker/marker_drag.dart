part of leaflet.layer.marker;

/**
 * MarkerDrag is used internally by Marker to make the markers draggable.
 */
class MarkerDrag extends Handler {

  Marker _marker;
  dom.Draggable _draggable;

  MarkerDrag(this._marker) : super(null);

  void addHooks() {
    final icon = _marker._icon;
    if (_draggable == null) {
      _draggable = new dom.Draggable(icon, icon);
    }

    _draggable.on(EventType.DRAGSTART, _onDragStart);
    _draggable.on(EventType.DRAG, _onDrag);
    _draggable.on(EventType.DRAGEND, _onDragEnd);
    _draggable.enable();
    _marker._icon.classes.add('leaflet-marker-draggable');
  }

  void removeHooks() {
    _draggable.off(EventType.DRAGSTART, _onDragStart);
    _draggable.off(EventType.DRAG, _onDrag);
    _draggable.off(EventType.DRAGEND, _onDragEnd);

    _draggable.disable();
    _marker._icon.classes.remove('leaflet-marker-draggable');
  }

  bool moved() {
    return _draggable != null && _draggable.moved;
  }

  void _onDragStart() {
    _marker.closePopup();
    _marker.fire(EventType.MOVESTART);
    _marker.fire(EventType.DRAGSTART);
  }

  void _onDrag() {
    final marker = _marker,
        shadow = marker._shadow,
        iconPos = dom.getPosition(marker._icon),
        latlng = marker._map.layerPointToLatLng(iconPos);

    // Update shadow position.
    if (shadow != null) {
      dom.setPosition(shadow, iconPos);
    }

    marker._latlng = latlng;

    marker.fireEvent(new MouseEvent(EventType.MOVE, latlng, null, null, null));
    marker.fire(EventType.DRAG);
  }

  void _onDragEnd(Event e) {
    _marker.fire(EventType.MOVEEND);
    _marker.fire(EventType.DRAGEND, e);
  }
}