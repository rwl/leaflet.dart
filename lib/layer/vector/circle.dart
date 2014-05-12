part of leaflet.layer.vector;

// Circle is a circle overlay (with a certain radius in meters).
class Circle extends Path {

  Map<String, Object> options = {
    'fill': true
  };

  LatLng _latlng;
  var _mRadius;
  Point _point;
  num _radius;

  Circle(LatLng latlng, num radius, Map<String, Object> options) : super(options) {
//    L.Path.prototype.initialize.call(this, options);

    this._latlng = new LatLng.latLng(latlng);
    this._mRadius = radius;
  }

  setLatLng(latlng) {
    this._latlng = new LatLng.latLng(latlng);
    return this.redraw();
  }

  setRadius(radius) {
    this._mRadius = radius;
    return this.redraw();
  }

  projectLatlngs() {
    var lngRadius = this._getLngRadius(),
        latlng = this._latlng,
        pointLeft = this._map.latLngToLayerPoint([latlng.lat, latlng.lng - lngRadius]);

    this._point = this._map.latLngToLayerPoint(latlng);
    this._radius = math.max(this._point.x - pointLeft.x, 1);
  }

  getBounds() {
    var lngRadius = this._getLngRadius(),
        latRadius = (this._mRadius / 40075017) * 360,
        latlng = this._latlng;

    return new LatLngBounds(
            [latlng.lat - latRadius, latlng.lng - lngRadius],
            [latlng.lat + latRadius, latlng.lng + lngRadius]);
  }

  getLatLng() {
    return this._latlng;
  }

  getPathString() {
    var p = this._point,
        r = this._radius;

    if (this._checkIfEmpty()) {
      return '';
    }

    if (Browser.svg) {
      return 'M' + p.x + ',' + (p.y - r) +
             'A' + r + ',' + r + ',0,1,1,' +
             (p.x - 0.1) + ',' + (p.y - r) + ' z';
    } else {
      p._round();
      r = r.round();
      return 'AL ' + p.x + ',' + p.y + ' ' + r + ',' + r + ' 0,${65535 * 360}';
    }
  }

  getRadius() {
    return this._mRadius;
  }

  // TODO Earth hardcoded, move into projection code!

  _getLatRadius() {
    return (this._mRadius / 40075017) * 360;
  }

  _getLngRadius() {
    return this._getLatRadius() / math.cos(LatLng.DEG_TO_RAD * this._latlng.lat);
  }

  _checkIfEmpty() {
    if (this._map == null) {
      return false;
    }
    var vp = this._map._pathViewport,
        r = this._radius,
        p = this._point;

    return p.x - r > vp.max.x || p.y - r > vp.max.y ||
           p.x + r < vp.min.x || p.y + r < vp.min.y;
  }
}