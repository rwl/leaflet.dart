

// Rectangle extends Polygon and creates a rectangle when passed a LatLngBounds object.
class Rectangle extends Polygon {
  Rectangle(latLngBounds, options) {
    L.Polygon.prototype.initialize.call(this, this._boundsToLatLngs(latLngBounds), options);
  }

  setBounds(latLngBounds) {
    this.setLatLngs(this._boundsToLatLngs(latLngBounds));
  }

  _boundsToLatLngs(latLngBounds) {
    latLngBounds = L.latLngBounds(latLngBounds);
    return [
      latLngBounds.getSouthWest(),
      latLngBounds.getNorthWest(),
      latLngBounds.getNorthEast(),
      latLngBounds.getSouthEast()
    ];
  }
}