part of leaflet.geometry;

/**
 * Bounds represents a rectangular area on the screen in pixel coordinates.
 */
class Bounds {

  /**
   * The top left corner of the rectangle.
   */
  Point2D min;

  /**
   * The bottom right corner of the rectangle.
   */
  Point2D max;

  /**
   * Creates a Bounds object defined by the points it contains.
   */
  Bounds([List<Point2D> points=null]) {
    if (points == null) { return; }

    for (var i = 0, len = points.length; i < len; i++) {
      extend(points[i]);
    }
  }

  /**
   * Creates a Bounds object from two coordinates (usually top-left and bottom-right corners).
   */
  factory Bounds.between(Point2D a, Point2D b) {
    return new Bounds([a, b]);
  }

  factory Bounds.bounds(Bounds b) {
    return b;
  }

  /**
   * Extends the bounds to contain the given point.
   */
  void extend(Point2D point) {
    point = new Point2D.point(point);

    if (min == null && max == null) {
      min = point.clone();
      max = point.clone();
    } else {
      min.x = math.min(point.x, min.x);
      max.x = math.max(point.x, max.x);
      min.y = math.min(point.y, min.y);
      max.y = math.max(point.y, max.y);
    }
  }

  /**
   * Returns the center point of the bounds.
   */
  Point2D getCenter([bool round = false]) {
    return new Point2D(
            (min.x + max.x) / 2,
            (min.y + max.y) / 2, round);
  }

  Point2D getBottomLeft() {
    return new Point2D(min.x, max.y);
  }

  Point2D getTopRight() {
    return new Point2D(max.x, min.y);
  }

  /**
   * Returns the size of the given bounds.
   */
  Point2D getSize() {
    return max - min;
  }

  /**
   * Returns true if the rectangle contains the given point.
   */
  bool contains(Point2D obj) {
    obj = new Point2D.point(obj);

    final min = obj;
    final max = obj;

    return (min.x >= this.min.x) &&
           (max.x <= this.max.x) &&
           (min.y >= this.min.y) &&
           (max.y <= this.max.y);
  }

  /**
   * Returns true if the rectangle contains the given one.
   */
  bool containsBounds(Bounds obj) {
    obj = new Bounds.bounds(obj);

    final min = obj.min;
    final max = obj.max;

    return (min.x >= this.min.x) &&
           (max.x <= this.max.x) &&
           (min.y >= this.min.y) &&
           (max.y <= this.max.y);
  }

  /**
   * Returns true if the rectangle intersects the given bounds.
   */
  bool intersects(Bounds bounds) {
    bounds = new Bounds.bounds(bounds);

    final min2 = bounds.min,
        max2 = bounds.max,
        xIntersects = (max2.x >= min.x) && (min2.x <= max.x),
        yIntersects = (max2.y >= min.y) && (min2.y <= max.y);

    return xIntersects && yIntersects;
  }

  /**
   * Returns true if the bounds are properly initialized.
   */
  bool isValid() {
    return min != null && max != null;
  }
}
