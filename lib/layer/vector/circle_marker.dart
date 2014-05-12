part of leaflet.layer.vector;

// CircleMarker is a circle overlay with a permanent pixel radius.
class CircleMarker extends Circle {
  Map<String, Object> options = {
    'radius': 10,
    'weight': 2
  };

  CircleMarker(LatLng latlng, Map<String, Object> options) : super(latlng, null, options) {
    this._radius = this.options['radius'];
  }

  projectLatlngs() {
    this._point = this._map.latLngToLayerPoint(this._latlng);
  }

  _updateStyle() {
    super._updateStyle();
    this.setRadius(this.options['radius']);
  }

  setLatLng(latlng) {
    super.setLatLng(latlng);
    if (this._popup != null && this._popup._isOpen) {
      this._popup.setLatLng(latlng);
    }
    return this;
  }

  setRadius(num radius) {
    this.options['radius'] = this._radius = radius;
    return this.redraw();
  }

  getRadius() {
    return this._radius;
  }
}
