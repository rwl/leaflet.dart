part of leaflet.layer.vector;

class CircleMarkerOptions extends CircleOptions {
  num radius = 10;
  num weight = 2;
}

/// CircleMarker is a circle overlay with a permanent pixel radius.
class CircleMarker extends Circle {

  CircleMarkerOptions get circleMarkerOptions => options as CircleMarkerOptions;

  CircleMarker(LatLng latlng, [CircleMarkerOptions options=null]) : super(latlng, null, options) {
    if (options == null) {
      this.options = new CircleMarkerOptions();
    }
    this._radius = options.radius;
  }

  void projectLatlngs([Object obj=null, MapEvent e=null]) {
    this._point = this._map.latLngToLayerPoint(this._latlng);
  }

  void _updateStyle() {
    super._updateStyle();
    this.setRadius(circleMarkerOptions.radius);
  }

  /// Sets the position of a circle marker to a new location.
  void setLatLng(LatLng latlng) {
    super.setLatLng(latlng);
    if (this._popup != null && this._popup.open) {
      this._popup.setLatLng(latlng);
    }
  }

  /// Sets the radius of a circle marker. Units are in pixels.
  void setRadius(num radius) {
    circleMarkerOptions.radius = this._radius = radius;
    this.redraw();
  }

  num getRadius() {
    return this._radius;
  }

  sfs.Feature toGeoJSON() {
    final ll = getLatLng();
    final point = new sfs.Point(ll.lat, ll.lng, z: ll.alt);
    return new sfs.Feature(point);
  }
}
