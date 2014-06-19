part of leaflet.layer.marker;

/**
 * MarkerDrag is used internally by Marker to make the markers draggable.
 */
class MarkerDrag extends Handler {

  Marker _marker;
  dom.Draggable _draggable;

  MarkerDrag(this._marker) : super(null);

  addHooks() {
    final icon = _marker._icon;
    if (_draggable == null) {
      _draggable = new dom.Draggable(icon, icon);
    }

    _draggable.on(EventType.DRAGSTART, _onDragStart, this);
    _draggable.on(EventType.DRAG, _onDrag, this);
    _draggable.on(EventType.DRAGEND, _onDragEnd, this);
    _draggable.enable();
    dom.addClass(_marker._icon, 'leaflet-marker-draggable');
  }

  removeHooks() {
    _draggable.off(EventType.DRAGSTART, _onDragStart, this);
    _draggable.off(EventType.DRAG, _onDrag, this);
    _draggable.off(EventType.DRAGEND, _onDragEnd, this);

    _draggable.disable();
    dom.removeClass(_marker._icon, 'leaflet-marker-draggable');
  }

  moved() {
    return _draggable && _draggable.moved;
  }

  _onDragStart(Object obj, Event e) {
    _marker.closePopup();
    _marker.fire(EventType.MOVESTART);
    _marker.fire(EventType.DRAGSTART);
  }

  _onDrag(Object obj, Event e) {
    final marker = _marker,
        shadow = marker._shadow,
        iconPos = dom.getPosition(marker._icon),
        latlng = marker._map.layerPointToLatLng(iconPos);

    // update shadow position
    if (shadow) {
      dom.setPosition(shadow, iconPos);
    }

    marker._latlng = latlng;

    marker.fire(EventType.MOVE, {'latlng': latlng});
    marker.fire(EventType.DRAG);
  }

  _onDragEnd(Object obj, Event e) {
    _marker.fire(EventType.MOVEEND);
    _marker.fire(EventType.DRAGEND, e);
  }
}