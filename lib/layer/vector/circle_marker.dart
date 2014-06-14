part of leaflet.layer.vector;

class CircleMarkerOptions extends CircleOptions {
  num radius = 10;
  num weight = 2;
}

/**
 * CircleMarker is a circle overlay with a permanent pixel radius.
 */
class CircleMarker extends Circle {
  /*Map<String, Object> options = {
    'radius': 10,
    'weight': 2
  };*/
  CircleMarkerOptions get circleMarkerOptions => options as CircleMarkerOptions;

  CircleMarker(LatLng latlng, CircleMarkerOptions options) : super(latlng, null, options) {
    this._radius = options.radius;
  }

  projectLatlngs() {
    this._point = this._map.latLngToLayerPoint(this._latlng);
  }

  _updateStyle() {
    super._updateStyle();
    this.setRadius(circleMarkerOptions.radius);
  }

  /**
   * Sets the position of a circle marker to a new location.
   */
  setLatLng(latlng) {
    super.setLatLng(latlng);
    if (this._popup != null && this._popup._isOpen) {
      this._popup.setLatLng(latlng);
    }
    return this;
  }

  /**
   * Sets the radius of a circle marker. Units are in pixels.
   */
  setRadius(num radius) {
    circleMarkerOptions.radius = this._radius = radius;
    return this.redraw();
  }

  getRadius() {
    return this._radius;
  }
}
