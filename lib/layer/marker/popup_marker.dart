part of leaflet.layer.marker;

// Popup extension to Marker, adding popup-related methods.
class Popup extends Marker {

  var _popup;

  Popup(LatLng latlng, Map<String, Object> options) : super(latlng, options);

  openPopup() {
    if (this._popup != null && this._map != null && !this._map.hasLayer(this._popup)) {
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

  bindPopup(var content, Map<String, Object> options) {
    var anchor = new Point(this.options['icon'].options['popupAnchor'] || [0, 0]);

    anchor = anchor.add(Popup.options['offset']);

    if (options != null && options.containsKey('offset')) {
      anchor = anchor.add(options['offset']);
    }

    options = new Map(options);
    options['offset'] = anchor;

    if (!this._popupHandlersAdded) {
      this
          .on('click', this.togglePopup, this)
          .on('remove', this.closePopup, this)
          .on('move', this._movePopup, this);
      this._popupHandlersAdded = true;
    }

    if (content is Popup) {
      content.options.addAll(options);
      this._popup = content;
    } else {
      this._popup = new Popup(options, this)
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