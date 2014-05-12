part of leaflet.layer.vector;

// Rectangle extends Polygon and creates a rectangle when passed a LatLngBounds object.
class Rectangle extends Polygon {

  Rectangle(LatLngBounds latLngBounds, Map<String, Object> options) : super(_boundsToLatLngs(latLngBounds), options);

  setBounds(LatLngBounds latLngBounds) {
    this.setLatLngs(_boundsToLatLngs(latLngBounds));
  }

  static List<LatLng> _boundsToLatLngs(latLngBounds) {
    latLngBounds = new LatLngBounds.latLngBounds(latLngBounds);
    return [
      latLngBounds.getSouthWest(),
      latLngBounds.getNorthWest(),
      latLngBounds.getNorthEast(),
      latLngBounds.getSouthEast()
    ];
  }

}