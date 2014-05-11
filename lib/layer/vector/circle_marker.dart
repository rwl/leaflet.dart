part of leaflet.layer.vector;

// CircleMarker is a circle overlay with a permanent pixel radius.
class CircleMarker extends Circle {
  var options = {
    'radius': 10,
    'weight': 2
  };

  CircleMarker(latlng, options) {
    L.Circle.prototype.initialize.call(this, latlng, null, options);
    this._radius = this.options.radius;
  }

  projectLatlngs() {
    this._point = this._map.latLngToLayerPoint(this._latlng);
  }

  _updateStyle() {
    L.Circle.prototype._updateStyle.call(this);
    this.setRadius(this.options.radius);
  }

  setLatLng(latlng) {
    L.Circle.prototype.setLatLng.call(this, latlng);
    if (this._popup && this._popup._isOpen) {
      this._popup.setLatLng(latlng);
    }
    return this;
  }

  setRadius(radius) {
    this.options.radius = this._radius = radius;
    return this.redraw();
  }

  getRadius() {
    return this._radius;
  }
}