part of leaflet.layer.marker;

// MarkerDrag is used internally by Marker to make the markers draggable.
class MarkerDrag extends Handler {
  MarkerDrag(marker) {
    this._marker = marker;
  }

  addHooks() {
    var icon = this._marker._icon;
    if (!this._draggable) {
      this._draggable = new L.Draggable(icon, icon);
    }

    this._draggable
      .on('dragstart', this._onDragStart, this)
      .on('drag', this._onDrag, this)
      .on('dragend', this._onDragEnd, this);
    this._draggable.enable();
    L.DomUtil.addClass(this._marker._icon, 'leaflet-marker-draggable');
  }

  removeHooks() {
    this._draggable
      .off('dragstart', this._onDragStart, this)
      .off('drag', this._onDrag, this)
      .off('dragend', this._onDragEnd, this);

    this._draggable.disable();
    L.DomUtil.removeClass(this._marker._icon, 'leaflet-marker-draggable');
  }

  moved() {
    return this._draggable && this._draggable._moved;
  }

  _onDragStart() {
    this._marker
        .closePopup()
        .fire('movestart')
        .fire('dragstart');
  }

  _onDrag() {
    var marker = this._marker,
        shadow = marker._shadow,
        iconPos = L.DomUtil.getPosition(marker._icon),
        latlng = marker._map.layerPointToLatLng(iconPos);

    // update shadow position
    if (shadow) {
      L.DomUtil.setPosition(shadow, iconPos);
    }

    marker._latlng = latlng;

    marker
        .fire('move', {latlng: latlng})
        .fire('drag');
  }

  _onDragEnd(e) {
    this._marker
        .fire('moveend')
        .fire('dragend', e);
  }
}