part of leaflet;

/// LatLng represents a geographical point with latitude and longitude
/// coordinates.
class LatLng {
  JsObject _L, _latlng;

  LatLng._(this._L, this._latlng);

  /// Creates an object representing a geographical point with the given
  /// latitude and longitude (and optionally altitude).
  LatLng(num lat, num lng, [num alt]) {
    _L = context['L'];
    var args = [lat, lng];
    if (alt != null) args.add(alt);
    _latlng = _L.callMethod('latLng', args);
  }

  /// Latitude in degrees.
  num get lat => _latlng['lat'];

  /// Longitude in degrees.
  num get lng => _latlng['lng'];
}

/// LatLngBounds represents a rectangular area on the map in geographical
/// coordinates.
class LatLngBounds {
  JsObject _L, _llb;

  LatLngBounds._(this._L, this._llb);

  LatLngBounds.from(LatLngBounds llb) {
    _L = context['L'];
    _L.callMethod('latLngBounds', [llb._llb]);
  }

  /// Creates a LatLngBounds object defined by the geographical points it
  /// contains. Very useful for zooming the map to fit a particular set of
  /// locations with fitBounds.
  LatLngBounds(List<LatLng> latlngs) {
    _L = context['L'];
    var arg0 = latlngs.map((ll) => ll._latlng).toList();
    _L.callMethod('latLngBounds', [arg0]);
  }

  /// Creates a latLngBounds object by defining south-west and north-east
  /// corners of the rectangle.
  LatLngBounds.between([LatLng southWest, LatLng northEast]) {
    _L = context['L'];
    _L.callMethod('latLngBounds', [southWest._latlng, northEast._latlng]);
  }

  /// Returns the center point of the bounds.
  LatLng getCenter() {
    return new LatLng._(_L, _llb.callMethod('getCenter'));
  }

  /// Returns the south-west point of the bounds.
  LatLng getSouthWest() => new LatLng._(_L, _llb.callMethod('getSouthWest'));

  /// Returns the north-east point of the bounds.
  LatLng getNorthEast() => new LatLng._(_L, _llb.callMethod('getNorthEast'));

  /// Returns the north-west point of the bounds.
  LatLng getNorthWest() => new LatLng._(_L, _llb.callMethod('getNorthWest'));

  /// Returns the south-east point of the bounds.
  LatLng getSouthEast() => new LatLng._(_L, _llb.callMethod('getSouthEast'));

  /// Returns the west longitude of the bounds.
  num getWest() => _llb.callMethod('getWest');

  /// Returns the south latitude of the bounds.
  num getSouth() => _llb.callMethod('getSouth');

  /// Returns the east longitude of the bounds.
  num getEast() => _llb.callMethod('getEast');

  /// Returns the north latitude of the bounds.
  num getNorth() => _llb.callMethod('getNorth');
}
