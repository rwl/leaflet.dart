part of leaflet.geo;

/**
 * LatLngBounds represents a rectangular area on the map in geographical coordinates.
 */
class LatLngBounds {

  LatLng _southWest, _northEast;

  factory LatLngBounds.latLngBounds(LatLngBounds llb) {
    return llb;
  }

  /**
   * Creates a LatLngBounds object defined by the geographical points it contains. Very useful for zooming the map to fit a particular set of locations with fitBounds.
   */
  LatLngBounds(List<LatLng> latlngs) {
    for (LatLng latlng in latlngs) {
      extend(latlng);
    }
  }

  /**
   * Creates a latLngBounds object by defining south-west and north-east corners of the rectangle.
   */
  factory LatLngBounds.between([LatLng southWest=null, LatLng northEast=null]) {
    return new LatLngBounds([southWest, northEast]);
  }

  /**
   * Extend the bounds to contain the given point.
   */
  void extend(LatLng obj) {
    if (obj == null) { return; }

    var latLng = new LatLng.latLng(obj);

    if (_southWest == null && _northEast == null) {
      _southWest = new LatLng(obj.lat, obj.lng);
      _northEast = new LatLng(obj.lat, obj.lng);
    } else {
      _southWest.lat = math.min(obj.lat, _southWest.lat);
      _southWest.lng = math.min(obj.lng, _southWest.lng);

      _northEast.lat = math.max(obj.lat, _northEast.lat);
      _northEast.lng = math.max(obj.lng, _northEast.lng);
    }
  }

  /**
   * Extend the bounds to contain the given bounds.
   */
  void extendBounds([LatLngBounds obj=null]) {
    if (obj == null) { return; }

    obj = new LatLngBounds.latLngBounds(obj);

    extend(obj._southWest);
    extend(obj._northEast);
  }

  /**
   * Returns bigger bounds created by extending the current bounds by a given percentage in each direction.
   */
  LatLngBounds pad(num bufferRatio) {
    final sw = _southWest;
    final ne = _northEast;
    final heightBuffer = (sw.lat - ne.lat).abs() * bufferRatio;
    final widthBuffer = (sw.lng - ne.lng).abs() * bufferRatio;

    return new LatLngBounds.between(
            new LatLng(sw.lat - heightBuffer, sw.lng - widthBuffer),
            new LatLng(ne.lat + heightBuffer, ne.lng + widthBuffer));
  }

  /**
   * Returns the center point of the bounds.
   */
  LatLng getCenter() {
    return new LatLng(
            (_southWest.lat + _northEast.lat) / 2,
            (_southWest.lng + _northEast.lng) / 2);
  }

  /**
   * Returns the south-west point of the bounds.
   */
  LatLng getSouthWest() {
    return _southWest;
  }

  /**
   * Returns the north-east point of the bounds.
   */
  LatLng getNorthEast() {
    return _northEast;
  }

  /**
   * Returns the north-west point of the bounds.
   */
  LatLng getNorthWest() {
    return new LatLng(getNorth(), getWest());
  }

  /**
   * Returns the south-east point of the bounds.
   */
  LatLng getSouthEast() {
    return new LatLng(getSouth(), getEast());
  }

  /**
   * Returns the west longitude of the bounds.
   */
  num getWest() {
    return _southWest.lng;
  }

  /**
   * Returns the south latitude of the bounds.
   */
  num getSouth() {
    return _southWest.lat;
  }

  /**
   * Returns the east longitude of the bounds.
   */
  num getEast() {
    return _northEast.lng;
  }

  /**
   * Returns the north latitude of the bounds.
   */
  num getNorth() {
    return _northEast.lat;
  }

  /**
   * Returns true if the rectangle contains the given point.
   */
  bool contains(LatLng obj) {
    obj = new LatLng.latLng(obj);

    final sw = _southWest,
        ne = _northEast;

    final sw2 = obj;
    final ne2 = obj;

    return (sw2.lat >= sw.lat) && (ne2.lat <= ne.lat) &&
           (sw2.lng >= sw.lng) && (ne2.lng <= ne.lng);
  }

  /**
   * Returns true if the rectangle contains the given one.
   */
  bool containsBounds(LatLngBounds obj) {
    obj = new LatLngBounds.latLngBounds(obj);

    final sw = _southWest,
        ne = _northEast;

    final sw2 = obj.getSouthWest();
    final ne2 = obj.getNorthEast();

    return (sw2.lat >= sw.lat) && (ne2.lat <= ne.lat) &&
           (sw2.lng >= sw.lng) && (ne2.lng <= ne.lng);
  }

  /**
   * Returns true if the rectangle intersects the given bounds.
   */
  bool intersects(LatLngBounds bounds) {
    bounds = new LatLngBounds.latLngBounds(bounds);

    final sw = _southWest,
        ne = _northEast,
        sw2 = bounds.getSouthWest(),
        ne2 = bounds.getNorthEast(),

        latIntersects = (ne2.lat >= sw.lat) && (sw2.lat <= ne.lat),
        lngIntersects = (ne2.lng >= sw.lng) && (sw2.lng <= ne.lng);

    return latIntersects && lngIntersects;
  }

  /**
   * Returns a string with bounding box coordinates in a 'southwest_lng,southwest_lat,northeast_lng,northeast_lat' format. Useful for sending requests to web services that return geo data.
   */
  String toBBoxString() {
    return [getWest(), getSouth(), getEast(), getNorth()].join(',');
  }

  /**
   * Returns true if the rectangle is equivalent (within a small margin of error) to the given bounds.
   */
  bool operator ==(LatLngBounds bounds) {
    if (bounds == null) { return false; }

    bounds = new LatLngBounds.latLngBounds(bounds);

    return _southWest == bounds.getSouthWest() &&
           _northEast == bounds.getNorthEast();
  }

  /**
   * Returns true if the bounds are properly initialized.
   */
  bool isValid() {
    return _southWest != null && _northEast != null;
  }
}
