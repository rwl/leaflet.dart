library leaflet.geometry;

import 'dart:math' as math;

// Point represents a point with x and y coordinates.
class Point {
  call(/*Number*/ x, /*Number*/ y, /*Boolean*/ round) {
    this.x = (round ? math.round(x) : x);
    this.y = (round ? math.round(y) : y);
  }

  clone() {
    return new L.Point(this.x, this.y);
  }

  // non-destructive, returns a new point
  add(point) {
    return this.clone()._add(L.point(point));
  }

  // destructive, used directly for performance in situations where it's safe to modify existing point
  _add(point) {
    this.x += point.x;
    this.y += point.y;
    return this;
  }

  subtract(point) {
    return this.clone()._subtract(L.point(point));
  }

  _subtract(point) {
    this.x -= point.x;
    this.y -= point.y;
    return this;
  }

  divideBy(num) {
    return this.clone()._divideBy(num);
  }

  _divideBy(num) {
    this.x /= num;
    this.y /= num;
    return this;
  }

  multiplyBy(num) {
    return this.clone()._multiplyBy(num);
  }

  _multiplyBy(num) {
    this.x *= num;
    this.y *= num;
    return this;
  }

  round() {
    return this.clone()._round();
  }

  _round() {
    this.x = Math.round(this.x);
    this.y = Math.round(this.y);
    return this;
  }

  floor() {
    return this.clone()._floor();
  }

  _floor() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    return this;
  }

  distanceTo(point) {
    point = L.point(point);

    var x = point.x - this.x,
        y = point.y - this.y;

    return Math.sqrt(x * x + y * y);
  }

  equals(point) {
    point = L.point(point);

    return point.x == this.x &&
           point.y == this.y;
  }

  contains(point) {
    point = L.point(point);

    return Math.abs(point.x) <= Math.abs(this.x) &&
           Math.abs(point.y) <= Math.abs(this.y);
  }

  toString() {
    return 'Point(' +
            L.Util.formatNum(this.x) + ', ' +
            L.Util.formatNum(this.y) + ')';
  }
}