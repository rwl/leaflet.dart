part of leaflet.geometry;

/**
 * Bounds represents a rectangular area on the screen in pixel coordinates.
 */
class Bounds {

  /**
   * The top left corner of the rectangle.
   */
  Point min;

  /**
   * The bottom right corner of the rectangle.
   */
  Point max;

  /**
   * Creates a Bounds object defined by the points it contains.
   */
  Bounds(List<Point> points) {
    if (points == null) { return; }

    for (var i = 0, len = points.length; i < len; i++) {
      extend(points[i]);
    }
  }

  /**
   * Creates a Bounds object from two coordinates (usually top-left and bottom-right corners).
   */
  factory Bounds.between(Point a, Point b) {
    return new Bounds([a, b]);
  }

  factory Bounds.bounds(Bounds b) {
    return b;
  }

  /**
   * Extends the bounds to contain the given point.
   */
  void extend(Point point) {
    point = new Point.point(point);

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
  Point getCenter([bool round = false]) {
    return new Point(
            (min.x + max.x) / 2,
            (min.y + max.y) / 2, round);
  }

  Point getBottomLeft() {
    return new Point(min.x, max.y);
  }

  Point getTopRight() {
    return new Point(max.x, min.y);
  }

  /**
   * Returns the size of the given bounds.
   */
  Point getSize() {
    return max - min;
  }

  /**
   * Returns true if the rectangle contains the given point.
   */
  bool contains(Point obj) {
    obj = new Point.point(obj);

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
