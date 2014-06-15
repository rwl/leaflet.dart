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
      this.extend(latlng);
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
  extend(LatLng obj) {
    if (obj == null) { return; }

    var latLng = new LatLng.latLng(obj);

    if (this._southWest == null && this._northEast == null) {
      this._southWest = new LatLng(obj.lat, obj.lng);
      this._northEast = new LatLng(obj.lat, obj.lng);
    } else {
      this._southWest.lat = math.min(obj.lat, this._southWest.lat);
      this._southWest.lng = math.min(obj.lng, this._southWest.lng);

      this._northEast.lat = math.max(obj.lat, this._northEast.lat);
      this._northEast.lng = math.max(obj.lng, this._northEast.lng);
    }
  }

  /**
   * Extend the bounds to contain the given bounds.
   */
  LatLngBounds extendBounds(LatLngBounds obj) {
    if (obj == null) { return this; }

    obj = new LatLngBounds.latLngBounds(obj);

    this.extend(obj._southWest);
    this.extend(obj._northEast);

    return this;
  }

  /**
   * Returns bigger bounds created by extending the current bounds by a given percentage in each direction.
   */
  LatLngBounds pad(num bufferRatio) {
    final sw = this._southWest;
    final ne = this._northEast;
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
            (this._southWest.lat + this._northEast.lat) / 2,
            (this._southWest.lng + this._northEast.lng) / 2);
  }

  /**
   * Returns the south-west point of the bounds.
   */
  LatLng getSouthWest() {
    return this._southWest;
  }

  /**
   * Returns the north-east point of the bounds.
   */
  LatLng getNorthEast() {
    return this._northEast;
  }

  /**
   * Returns the north-west point of the bounds.
   */
  LatLng getNorthWest() {
    return new LatLng(this.getNorth(), this.getWest());
  }

  /**
   * Returns the south-east point of the bounds.
   */
  LatLng getSouthEast() {
    return new LatLng(this.getSouth(), this.getEast());
  }

  /**
   * Returns the west longitude of the bounds.
   */
  num getWest() {
    return this._southWest.lng;
  }

  /**
   * Returns the south latitude of the bounds.
   */
  num getSouth() {
    return this._southWest.lat;
  }

  /**
   * Returns the east longitude of the bounds.
   */
  num getEast() {
    return this._northEast.lng;
  }

  /**
   * Returns the north latitude of the bounds.
   */
  num getNorth() {
    return this._northEast.lat;
  }

  /**
   * Returns true if the rectangle contains the given point.
   */
  bool contains(LatLng obj) {
    obj = new LatLng.latLng(obj);

    final sw = this._southWest,
        ne = this._northEast;

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

    final sw = this._southWest,
        ne = this._northEast;

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

    final sw = this._southWest,
        ne = this._northEast,
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
    return [this.getWest(), this.getSouth(), this.getEast(), this.getNorth()].join(',');
  }

  /**
   * Returns true if the rectangle is equivalent (within a small margin of error) to the given bounds.
   */
  bool operator ==(LatLngBounds bounds) {
    if (bounds == null) { return false; }

    bounds = new LatLngBounds.latLngBounds(bounds);

    return this._southWest == bounds.getSouthWest() &&
           this._northEast == bounds.getNorthEast();
  }

  /**
   * Returns true if the bounds are properly initialized.
   */
  bool isValid() {
    return this._southWest != null && this._northEast != null;
  }
}
