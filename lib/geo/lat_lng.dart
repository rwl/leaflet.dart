part of leaflet.geo;

/// LatLng represents a geographical point with latitude and longitude
/// coordinates.
class LatLng {

  /// Latitude in degrees.
  num lat;

  /// Longitude in degrees.
  num lng;

  num alt;

  factory LatLng.parse(String lat, String lng, [String alt = '']) {
    final lt = double.parse(lat, (String s) {
      return double.NAN;
    });
    final lg = double.parse(lng, (String s) {
      return double.NAN;
    });
    final at = double.parse(alt, (String s) {
      return null;
    });
    return new LatLng(lt, lg, at);
  }

  factory LatLng.latLng(LatLng ll) {
    return ll;
  }

  /// Creates an object representing a geographical point with the given
  /// latitude and longitude (and optionally altitude).
  LatLng(this.lat, this.lng, [this.alt = null]) {
    if (lat.isNaN || lng.isNaN) {
      throw new Exception('Invalid LatLng object: ($lat, $lng)');
    }
  }

  /// A multiplier for converting degrees into radians.
  static final DEG_TO_RAD = math.PI / 180;

  /// A multiplier for converting radians into degrees.
  static final RAD_TO_DEG = 180 / math.PI;

  /// Max margin of error for the equality check.
  static final MAX_MARGIN = 1.0E-9;

  /// Returns true if the given LatLng point is at the same position (within
  /// a small margin of error).
  bool operator ==(LatLng obj) { // (LatLng) -> Boolean
    if (obj == null) {
      return false;
    }

    obj = new LatLng.latLng(obj);

    final margin = math.max((lat - obj.lat).abs(), (lng - obj.lng).abs());

    return margin <= LatLng.MAX_MARGIN;
  }

  /// Returns a string representation of the point (for debugging purposes).
  String toString([num precision = 5]) {
//    return 'LatLng(${formatNum(lat, precision)}, ${formatNum(lng, precision)})';
    return 'LatLng($lat, $lng)';
  }

  /// Returns the distance (in meters) to the given LatLng calculated using
  /// the Haversine formula
  /// see http://en.wikipedia.org/wiki/Haversine_formula
  ///
  /// TODO move to projection code, LatLng shouldn't know about Earth
  num distanceTo(LatLng other) {
    other = new LatLng.latLng(other);

    final R = 6378137, // earth radius in meters
        d2r = LatLng.DEG_TO_RAD,
        dLat = (other.lat - lat) * d2r,
        dLon = (other.lng - lng) * d2r,
        lat1 = lat * d2r,
        lat2 = other.lat * d2r,
        sin1 = math.sin(dLat / 2),
        sin2 = math.sin(dLon / 2);

    final a = sin1 * sin1 + sin2 * sin2 * math.cos(lat1) * math.cos(lat2);

    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Returns a new LatLng object with the longitude wrapped around left and
  /// right boundaries (-180 to 180 by default).
  LatLng wrap([num a = -180, num b = 180]) {
    final l = (lng + b).remainder(b - a) + (lng < a || lng == b ? b : a);

    return new LatLng(lat, l);
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
