part of leaflet.geometry;

// Bounds represents a rectangular area on the screen in pixel coordinates.
class Bounds {
  Point min, max;

  Bounds(List<Point> points) { //(Point, Point) or Point[]
    if (points == null) { return; }

    for (var i = 0, len = points.length; i < len; i++) {
      this.extend(points[i]);
    }
  }

  factory Bounds.points(Point a, Point b) {
    return new Bounds([a, b]);
  }

  factory Bounds.bounds(Bounds b) {
    return b;
  }

  // Extend the bounds to contain the given point.
  extend(Point point) {
    point = new Point.point(point);

    if (this.min == null && this.max == null) {
      this.min = point.clone();
      this.max = point.clone();
    } else {
      this.min.x = math.min(point.x, this.min.x);
      this.max.x = math.max(point.x, this.max.x);
      this.min.y = math.min(point.y, this.min.y);
      this.max.y = math.max(point.y, this.max.y);
    }
    return this;
  }

  Point getCenter([bool round = false]) {
    return new Point(
            (this.min.x + this.max.x) / 2,
            (this.min.y + this.max.y) / 2, round);
  }

  Point getBottomLeft() {
    return new Point(this.min.x, this.max.y);
  }

  Point getTopRight() {
    return new Point(this.max.x, this.min.y);
  }

  num getSize() {
    return this.max.subtract(this.min);
  }

  bool contains(Point obj) {
    obj = new Point.point(obj);

    final min = obj;
    final max = obj;

    return (min.x >= this.min.x) &&
           (max.x <= this.max.x) &&
           (min.y >= this.min.y) &&
           (max.y <= this.max.y);
  }

  bool containsBounds(Bounds obj) {
    obj = new Bounds.bounds(obj);

    final min = obj.min;
    final max = obj.max;

    return (min.x >= this.min.x) &&
           (max.x <= this.max.x) &&
           (min.y >= this.min.y) &&
           (max.y <= this.max.y);
  }

  bool intersects(Bounds bounds) { // (Bounds) -> Boolean
    bounds = new Bounds.bounds(bounds);

    var min = this.min,
        max = this.max,
        min2 = bounds.min,
        max2 = bounds.max,
        xIntersects = (max2.x >= min.x) && (min2.x <= max.x),
        yIntersects = (max2.y >= min.y) && (min2.y <= max.y);

    return xIntersects && yIntersects;
  }

  bool isValid() {
    return this.min != null && this.max != null;
  }
}
