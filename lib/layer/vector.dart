part of leaflet;

/// Polyline is used to display polylines on a map.
class Polyline implements Layer {
  final JsObject layer;

  /// For internal use.
  Polyline.wrap(this.layer);
}

/// Polygon is used to display polygons on a map.
///
/// Note that points you pass when creating a polygon shouldn't have an
/// additional last point equal to the first one - it's better to filter
/// out such points.
class Polygon implements Layer {
  final JsObject layer;

  /// For internal use.
  Polygon.wrap(this.layer);
}

/// Rectangle creates a rectangle when passed a [LatLngBounds] object.
class Rectangle implements Layer {
  final JsObject layer;

  /// For internal use.
  Rectangle.wrap(this.layer);
}

/// Circle is a circle overlay (with a certain radius in meters).
class Circle implements Layer {
  final JsObject layer;

  /// For internal use.
  Circle.wrap(this.layer);
}
