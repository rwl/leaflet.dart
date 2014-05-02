library leaflet.layer.tile;

// Popup extension to Marker, adding popup-related methods.
class Popup /*extends Marker*/ {
  openPopup() {
    if (this._popup && this._map && !this._map.hasLayer(this._popup)) {
      this._popup.setLatLng(this._latlng);
      this._map.openPopup(this._popup);
    }

    return this;
  }

  closePopup() {
    if (this._popup) {
      this._popup._close();
    }
    return this;
  }

  togglePopup() {
    if (this._popup) {
      if (this._popup._isOpen) {
        this.closePopup();
      } else {
        this.openPopup();
      }
    }
    return this;
  }

  bindPopup(content, options) {
    var anchor = L.point(this.options.icon.options.popupAnchor || [0, 0]);

    anchor = anchor.add(L.Popup.prototype.options.offset);

    if (options && options.offset) {
      anchor = anchor.add(options.offset);
    }

    options = L.extend({offset: anchor}, options);

    if (!this._popupHandlersAdded) {
      this
          .on('click', this.togglePopup, this)
          .on('remove', this.closePopup, this)
          .on('move', this._movePopup, this);
      this._popupHandlersAdded = true;
    }

    if (content is Popup) {
      L.setOptions(content, options);
      this._popup = content;
    } else {
      this._popup = new L.Popup(options, this)
        .setContent(content);
    }

    return this;
  }

  setPopupContent(content) {
    if (this._popup) {
      this._popup.setContent(content);
    }
    return this;
  }

  unbindPopup() {
    if (this._popup) {
      this._popup = null;
      this
          .off('click', this.togglePopup, this)
          .off('remove', this.closePopup, this)
          .off('move', this._movePopup, this);
      this._popupHandlersAdded = false;
    }
    return this;
  }

  getPopup() {
    return this._popup;
  }

  _movePopup(e) {
    this._popup.setLatLng(e.latlng);
  }
}