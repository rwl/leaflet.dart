part of leaflet.geometry;

// Point represents a point with x and y coordinates.
class Point {
  num x, y;

  Point(num x, num y, [bool round=false]) {
    this.x = (round ? x.round() : x);
    this.y = (round ? y.round() : y);
  }

  factory Point.point(Point p) {
    return p;
  }

  factory Point.array(List<num> a) {
    return new Point(a[0], a[1]);
  }

  clone() {
    return new Point(x, y);
  }

  // non-destructive, returns a new point
  add(point) {
    return this.clone()._add(new Point.point(point));
  }

  // destructive, used directly for performance in situations where it's safe to modify existing point
  Point _add(point) {
    this.x += point.x;
    this.y += point.y;
    return this;
  }

  subtract(point) {
    return this.clone()._subtract(new Point.point(point));
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
    this.x = this.x.round();
    this.y = this.y.round();
    return this;
  }

  floor() {
    return this.clone()._floor();
  }

  _floor() {
    this.x = this.x.floor();
    this.y = this.y.floor();
    return this;
  }

  distanceTo(point) {
    point = new Point.point(point);

    var x = point.x - this.x,
        y = point.y - this.y;

    return math.sqrt(x * x + y * y);
  }

  bool equals(Point point) {
    point = new Point.point(point);

    return point.x == this.x &&
           point.y == this.y;
  }

  bool contains(Point point) {
    point = new Point.point(point);

    return point.x.abs() <= this.x.abs() &&
           point.y.abs() <= this.y.abs();
  }

  toString() {
    return 'Point(' +
            Util.formatNum(this.x) + ', ' +
            Util.formatNum(this.y) + ')';
  }
}