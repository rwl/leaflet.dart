library leaflet.geometry;

import 'dart:math' as math;

// Bounds represents a rectangular area on the screen in pixel coordinates.
class Bounds {
  call(a, b) { //(Point, Point) or Point[]
    if (!a) { return; }

    var points = b ? [a, b] : a;

    for (var i = 0, len = points.length; i < len; i++) {
      this.extend(points[i]);
    }
  }

  // Extend the bounds to contain the given point.
  extend(point) { // (Point)
    point = L.point(point);

    if (!this.min && !this.max) {
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

  getCenter(round) { // (Boolean) -> Point
    return new L.Point(
            (this.min.x + this.max.x) / 2,
            (this.min.y + this.max.y) / 2, round);
  }

  getBottomLeft() { // -> Point
    return new L.Point(this.min.x, this.max.y);
  }

  getTopRight() { // -> Point
    return new L.Point(this.max.x, this.min.y);
  }

  getSize() {
    return this.max.subtract(this.min);
  }

  contains(obj) { // (Bounds) or (Point) -> Boolean
    var min, max;

    if (obj[0] is num || obj is Point) {
      obj = L.point(obj);
    } else {
      obj = L.bounds(obj);
    }

    if (obj is Bounds) {
      min = obj.min;
      max = obj.max;
    } else {
      min = max = obj;
    }

    return (min.x >= this.min.x) &&
           (max.x <= this.max.x) &&
           (min.y >= this.min.y) &&
           (max.y <= this.max.y);
  }

  intersects(bounds) { // (Bounds) -> Boolean
    bounds = L.bounds(bounds);

    var min = this.min,
        max = this.max,
        min2 = bounds.min,
        max2 = bounds.max,
        xIntersects = (max2.x >= min.x) && (min2.x <= max.x),
        yIntersects = (max2.y >= min.y) && (min2.y <= max.y);

    return xIntersects && yIntersects;
  }

  isValid() {
    return !(this.min && this.max);
  }
}
