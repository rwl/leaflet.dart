library leaflet.geo;

// LatLng represents a geographical point with latitude and longitude coordinates.
class LatLng {

  LatLng(lat, lng, alt) {
    lat = parseFloat(lat);
    lng = parseFloat(lng);

    if (isNaN(lat) || isNaN(lng)) {
      throw new Error('Invalid LatLng object: (' + lat + ', ' + lng + ')');
    }

    this.lat = lat;
    this.lng = lng;

    if (alt != null) {
      this.alt = parseFloat(alt);
    }
  }

  static var DEG_TO_RAD = Math.PI / 180;
  static var RAD_TO_DEG = 180 / Math.PI;
  static var MAX_MARGIN = 1.0E-9; // max margin of error for the "equals" check

  equals(obj) { // (LatLng) -> Boolean
    if (!obj) { return false; }

    obj = L.latLng(obj);

    var margin = Math.max(
            Math.abs(this.lat - obj.lat),
            Math.abs(this.lng - obj.lng));

    return margin <= L.LatLng.MAX_MARGIN;
  }

  toString(precision) { // (Number) -> String
    return 'LatLng(' +
            L.Util.formatNum(this.lat, precision) + ', ' +
            L.Util.formatNum(this.lng, precision) + ')';
  }

  // Haversine distance formula, see http://en.wikipedia.org/wiki/Haversine_formula
  // TODO move to projection code, LatLng shouldn't know about Earth
  distanceTo(other) { // (LatLng) -> Number
    other = L.latLng(other);

    var R = 6378137, // earth radius in meters
        d2r = L.LatLng.DEG_TO_RAD,
        dLat = (other.lat - this.lat) * d2r,
        dLon = (other.lng - this.lng) * d2r,
        lat1 = this.lat * d2r,
        lat2 = other.lat * d2r,
        sin1 = Math.sin(dLat / 2),
        sin2 = Math.sin(dLon / 2);

    var a = sin1 * sin1 + sin2 * sin2 * Math.cos(lat1) * Math.cos(lat2);

    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  wrap(a, b) { // (Number, Number) -> LatLng
    var lng = this.lng;

    a = a || -180;
    b = b ||  180;

    lng = (lng + b) % (b - a) + (lng < a || lng == b ? b : a);

    return new LatLng(this.lat, lng);
  }
}

latLng(a, b) { // (LatLng) or ([Number, Number]) or (Number, Number)
  if (a is LatLng) {
    return a;
  }
  if (L.Util.isArray(a)) {
    if (a[0] is num || a[0] is String) {
      return new LatLng(a[0], a[1], a[2]);
    } else {
      return null;
    }
  }
  if (a == null) {
    return a;
  }
  if (a is Map && a.contains('lat')) {
    return new LatLng(a.lat, a.contains('lng') ? a.lng : a.lon);
  }
  if (b == null) {
    return null;
  }
  return new LatLng(a, b);
}
