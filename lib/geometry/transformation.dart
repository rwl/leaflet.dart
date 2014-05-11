part of leaflet.geometry;

// Transformation is an utility class to perform simple point transformations through a 2d-matrix.
class Transformation {
  num _a, _b, _c, _d;

  Transformation(this._a, this._b, [this._c = 0, this._d = 0]);

  Point transform(Point point, num scale) { // (Point, Number) -> Point
    return this.destructive_transform(point.clone(), scale);
  }

  // destructive transform (faster)
  Point destructive_transform(Point point, [num scale = 1]) {
    point.x = scale * (this._a * point.x + this._b);
    point.y = scale * (this._c * point.y + this._d);
    return point;
  }

  Point untransform(Point point, [num scale = 1]) {
    return new Point(
            (point.x / scale - this._b) / this._a,
            (point.y / scale - this._d) / this._c);
  }
}