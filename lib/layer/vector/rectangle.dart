part of leaflet.layer.vector;

/// Rectangle extends Polygon and creates a rectangle when passed a
/// LatLngBounds object.
class Rectangle extends Polygon {

  Rectangle(LatLngBounds latLngBounds, [PolygonOptions options=null]) :
    super(_boundsToLatLngs(latLngBounds), options);

  /// Redraws the rectangle with the passed bounds.
  setBounds(LatLngBounds latLngBounds) {
    setLatLngs(_boundsToLatLngs(latLngBounds));
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
