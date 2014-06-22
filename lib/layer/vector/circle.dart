part of leaflet.layer.vector;

class CircleOptions extends PathOptions {
  bool fill = true;
}

// Circle is a circle overlay (with a certain radius in meters).
class Circle extends Path {

  //CircleOptions circleOptions;
  CircleOptions get circleOptions => options as CircleOptions;

  LatLng _latlng;
  var _mRadius;
  Point _point;
  num _radius;

  Circle(LatLng latlng, num radius, [CircleOptions circleOptions=null]) : super(circleOptions) {
    if (options == null) {
      options = new CircleOptions();
    }
//    L.Path.prototype.initialize.call(this, options);

    _latlng = new LatLng.latLng(latlng);
    _mRadius = radius;
  }

  /**
   * Sets the position of a circle to a new location.
   */
  void setLatLng(latlng) {
    _latlng = new LatLng.latLng(latlng);
    redraw();
  }

  /**
   * Sets the radius of a circle. Units are in meters.
   */
  void setRadius(radius) {
    _mRadius = radius;
    redraw();
  }

  void projectLatlngs([Object obj=null, Event e=null]) {
    final lngRadius = _getLngRadius(),
        latlng = _latlng,
        pointLeft = _map.latLngToLayerPoint(new LatLng(latlng.lat, latlng.lng - lngRadius));

    _point = _map.latLngToLayerPoint(latlng);
    _radius = math.max(_point.x - pointLeft.x, 1);
  }

  LatLngBounds getBounds() {
    final lngRadius = _getLngRadius(),
        latRadius = (_mRadius / 40075017) * 360,
        latlng = _latlng;

    return new LatLngBounds.between(
            new LatLng(latlng.lat - latRadius, latlng.lng - lngRadius),
            new LatLng(latlng.lat + latRadius, latlng.lng + lngRadius));
  }

  /**
   * Returns the current geographical position of the circle.
   */
  LatLng getLatLng() {
    return _latlng;
  }

  String getPathString() {
    var p = _point,
        r = _radius;

    if (_checkIfEmpty()) {
      return '';
    }

    if (Browser.svg) {
      return 'M${p.x},${p.y - r}A$r,$r,0,1,1,${p.x - 0.1},${p.y - r} z';
    } else {
      p.round();
      r = r.round();
      return 'AL ${p.x},${p.y} $r,$r 0,${65535 * 360}';
    }
  }

  /**
   * Returns the current radius of a circle. Units are in meters.
   */
  num getRadius() {
    return _mRadius;
  }

  // TODO Earth hardcoded, move into projection code!

  num _getLatRadius() {
    return (_mRadius / 40075017) * 360;
  }

  num _getLngRadius() {
    return _getLatRadius() / math.cos(LatLng.DEG_TO_RAD * _latlng.lat);
  }

  bool _checkIfEmpty() {
    if (_map == null) {
      return false;
    }
    final vp = _map.pathViewport,
        r = _radius,
        p = _point;

    return p.x - r > vp.max.x || p.y - r > vp.max.y ||
           p.x + r < vp.min.x || p.y + r < vp.min.y;
  }

  toGeoJSON() {
    return GeoJSON.getFeature(this, {
      'type': 'Point',
      'coordinates': GeoJSON.latLngToCoords(getLatLng())
    });
  }
}