part of leaflet.geo;

// LatLng represents a geographical point with latitude and longitude coordinates.
class LatLng {

  num lat, lng, alt;

  factory LatLng.parse(String lat, String lng, [String alt='']) {
    final lt = double.parse(lat, (String s) { return double.NAN; });
    final lg = double.parse(lng, (String s) { return double.NAN; });
    final at = double.parse(alt, (String s) { return null; });
    return new LatLng(lt, lg, at);
  }

  factory LatLng.latLng(LatLng ll) {
    return ll;
  }

  LatLng(num lat, num lng, [num alt=null]) {
    if (lat.isNaN || lng.isNaN) {
      throw new Exception('Invalid LatLng object: ($lat, $lng)');
    }

    this.lat = lat;
    this.lng = lng;
    this.alt = alt;
  }

  static final DEG_TO_RAD = math.PI / 180;
  static final RAD_TO_DEG = 180 / math.PI;
  static final MAX_MARGIN = 1.0E-9; // max margin of error for the "equals" check

  bool equals(LatLng obj) { // (LatLng) -> Boolean
    if (obj == null) { return false; }

    obj = new LatLng.latLng(obj);

    var margin = math.max(
            (this.lat - obj.lat).abs(),
            (this.lng - obj.lng).abs());

    return margin <= LatLng.MAX_MARGIN;
  }

  String toString([num precision=5]) { // (Number) -> String
    return 'LatLng(${Util.formatNum(this.lat, precision)}, ${Util.formatNum(this.lng, precision)})';
  }

  // Haversine distance formula, see http://en.wikipedia.org/wiki/Haversine_formula
  // TODO move to projection code, LatLng shouldn't know about Earth
  num distanceTo(LatLng other) { // (LatLng) -> Number
    other = new LatLng.latLng(other);

    var R = 6378137, // earth radius in meters
        d2r = LatLng.DEG_TO_RAD,
        dLat = (other.lat - this.lat) * d2r,
        dLon = (other.lng - this.lng) * d2r,
        lat1 = this.lat * d2r,
        lat2 = other.lat * d2r,
        sin1 = math.sin(dLat / 2),
        sin2 = math.sin(dLon / 2);

    var a = sin1 * sin1 + sin2 * sin2 * math.cos(lat1) * math.cos(lat2);

    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  LatLng wrap([num a=-180, num b=180]) { // (Number, Number) -> LatLng
    var lng = this.lng;

    lng = (lng + b) % (b - a) + (lng < a || lng == b ? b : a);

    return new LatLng(this.lat, lng);
  }
}
/*
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
*/