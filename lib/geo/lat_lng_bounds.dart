library leaflet.geo;

// LatLngBounds represents a rectangular area on the map in geographical coordinates.
class LatLngBounds {
  LatLngBounds(southWest, northEast) { // (LatLng, LatLng) or (LatLng[])
    if (!southWest) { return; }

    var latlngs = northEast ? [southWest, northEast] : southWest;

    for (var i = 0, len = latlngs.length; i < len; i++) {
      this.extend(latlngs[i]);
    }
  }

  // Extend the bounds to contain the given point or bounds.
  extend(obj) { // (LatLng) or (LatLngBounds)
    if (!obj) { return this; }

    var latLng = L.latLng(obj);
    if (latLng != null) {
      obj = latLng;
    } else {
      obj = L.latLngBounds(obj);
    }

    if (obj is LatLng) {
      if (!this._southWest && !this._northEast) {
        this._southWest = new L.LatLng(obj.lat, obj.lng);
        this._northEast = new L.LatLng(obj.lat, obj.lng);
      } else {
        this._southWest.lat = Math.min(obj.lat, this._southWest.lat);
        this._southWest.lng = Math.min(obj.lng, this._southWest.lng);

        this._northEast.lat = Math.max(obj.lat, this._northEast.lat);
        this._northEast.lng = Math.max(obj.lng, this._northEast.lng);
      }
    } else if (obj is LatLngBounds) {
      this.extend(obj._southWest);
      this.extend(obj._northEast);
    }
    return this;
  }

  // Extend the bounds by a percentage.
  pad(bufferRatio) { // (Number) -> LatLngBounds
    var sw = this._southWest,
        ne = this._northEast,
        heightBuffer = Math.abs(sw.lat - ne.lat) * bufferRatio,
        widthBuffer = Math.abs(sw.lng - ne.lng) * bufferRatio;

    return new L.LatLngBounds(
            new L.LatLng(sw.lat - heightBuffer, sw.lng - widthBuffer),
            new L.LatLng(ne.lat + heightBuffer, ne.lng + widthBuffer));
  }

  getCenter() { // -> LatLng
    return new L.LatLng(
            (this._southWest.lat + this._northEast.lat) / 2,
            (this._southWest.lng + this._northEast.lng) / 2);
  }

  getSouthWest() {
    return this._southWest;
  }

  getNorthEast() {
    return this._northEast;
  }

  getNorthWest() {
    return new L.LatLng(this.getNorth(), this.getWest());
  }

  getSouthEast() {
    return new L.LatLng(this.getSouth(), this.getEast());
  }

  getWest() {
    return this._southWest.lng;
  }

  getSouth() {
    return this._southWest.lat;
  }

  getEast() {
    return this._northEast.lng;
  }

  getNorth() {
    return this._northEast.lat;
  }

  contains(obj) { // (LatLngBounds) or (LatLng) -> Boolean
    if (obj[0] is num || obj is LatLng) {
      obj = L.latLng(obj);
    } else {
      obj = L.latLngBounds(obj);
    }

    var sw = this._southWest,
        ne = this._northEast,
        sw2, ne2;

    if (obj is LatLngBounds) {
      sw2 = obj.getSouthWest();
      ne2 = obj.getNorthEast();
    } else {
      sw2 = ne2 = obj;
    }

    return (sw2.lat >= sw.lat) && (ne2.lat <= ne.lat) &&
           (sw2.lng >= sw.lng) && (ne2.lng <= ne.lng);
  }

  intersects(bounds) { // (LatLngBounds)
    bounds = L.latLngBounds(bounds);

    var sw = this._southWest,
        ne = this._northEast,
        sw2 = bounds.getSouthWest(),
        ne2 = bounds.getNorthEast(),

        latIntersects = (ne2.lat >= sw.lat) && (sw2.lat <= ne.lat),
        lngIntersects = (ne2.lng >= sw.lng) && (sw2.lng <= ne.lng);

    return latIntersects && lngIntersects;
  }

  toBBoxString() {
    return [this.getWest(), this.getSouth(), this.getEast(), this.getNorth()].join(',');
  }

  equals(bounds) { // (LatLngBounds)
    if (!bounds) { return false; }

    bounds = L.latLngBounds(bounds);

    return this._southWest.equals(bounds.getSouthWest()) &&
           this._northEast.equals(bounds.getNorthEast());
  }

  isValid() {
    return !!(this._southWest && this._northEast);
  }
}