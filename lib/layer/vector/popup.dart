part of leaflet.layer.vector;

// Popup extension to Path (polylines, polygons, circles), adding popup-related methods.
class Popup {

  Popup _popup;
  bool _popupHandlersAdded;
  LatLng _latlng;

  bindPopup(var content, [Map<String, Object> options=null]) {

    if (content is Popup) {
      this._popup = content;
    } else {
      if (this._popup == null || options != null) {
        this._popup = new Popup(options, this);
      }
      this._popup.setContent(content);
    }

    if (!this._popupHandlersAdded) {
      this
          .on('click', this._openPopup, this)
          .on('remove', this.closePopup, this);

      this._popupHandlersAdded = true;
    }

    return this;
  }

  unbindPopup() {
    if (this._popup != null) {
      this._popup = null;
      this
          .off('click', this._openPopup)
          .off('remove', this.closePopup);

      this._popupHandlersAdded = false;
    }
    return this;
  }

  openPopup([LatLng latlng=null]) {

    if (this._popup != null) {
      // open the popup from one of the path's points if not specified
      if (latlng == null) {
        if (this._latlng != null) {
          latlng = this._latlng;
        } else {
          latlng = this._latlngs[(this._latlngs.length / 2).floor()];
        }
      }

      this._openPopup({'latlng': latlng});
    }

    return this;
  }

  closePopup() {
    if (this._popup != null) {
      this._popup._close();
    }
    return this;
  }

  _openPopup(e) {
    this._popup.setLatLng(e.latlng);
    this._map.openPopup(this._popup);
  }
}
