part of leaflet.geometry;

/**
 * Transformation is an utility class to perform simple point transformations through a 2d-matrix.
 */
class Transformation {

  num _a, _b, _c, _d;

  /**
   * Creates a transformation object with the given coefficients.
   */
  Transformation(this._a, this._b, [this._c = 0, this._d = 0]);

  /**
   * Returns a transformed point, optionally multiplied by the given scale.
   */
  Point2D transform(Point2D point, [num scale=1]) {
    final p = point.clone();
    transformPoint(p, scale);
    return p;
  }

  // destructive transform (faster)
  void transformPoint(Point2D point, [num scale = 1]) {
    point.x = scale * (_a * point.x + _b);
    point.y = scale * (_c * point.y + _d);
    //return point;
  }

  /**
   * Returns the reverse transformation of the given point, optionally divided by the given scale.
   */
  Point2D untransform(Point2D point, [num scale = 1]) {
    return new Point2D(
            (point.x / scale - _b) / _a,
            (point.y / scale - _d) / _c);
  }

}
