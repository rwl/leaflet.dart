part of leaflet.geometry;

/**
 * Point2D represents a point with x and y coordinates.
 */
class Point2D {

  num x, y, z;

  int _code;

  /**
   * Creates a Point2D object with the given x and y coordinates. If optional round is set to true, rounds the x and y values.
   */
  Point2D(num xx, num yy, [bool round = false]) {
    x = (round ? xx.round() : xx);
    y = (round ? yy.round() : yy);
  }

  factory Point2D.point(Point2D p) {
    return p;
  }

  factory Point2D.array(List<num> a) {
    return new Point2D(a[0], a[1]);
  }

  /**
   * Returns a copy of the current point.
   */
  Point2D clone() {
    return new Point2D(x, y);
  }

  /**
   * Returns the result of addition of the current and the given points.
   *
   * Non-destructive, returns a new point.
   */
  Point2D operator +(Point2D point) {
    final c = clone();
    c.add(new Point2D.point(point));
    return c;
  }

  /**
   * Destructive, used directly for performance in situations where it's safe to modify existing point.
   */
  void add(Point2D point) {
    x += point.x;
    y += point.y;
  }

  /**
   * Returns the result of subtraction of the given point from the current.
   */
  Point2D operator -(Point2D point) {
    final c = clone();
    c.subtract(new Point2D.point(point));
    return c;
  }

  void subtract(Point2D point) {
    x -= point.x;
    y -= point.y;
  }

  /**
   * Returns the result of division of the current point by the given number. If optional round is set to true, returns a rounded result.
   */
  Point2D operator /(num x) {//, [bool round = false]) {
    final c = clone();
    c.divideBy(x);
    /*if (round) {
      c._round();
    }*/
    return c;
  }

  void divideBy(num xx) {
    x /= xx;
    y /= xx;
  }

  /**
   * Returns the result of multiplication of the current point by the given number.
   */
  Point2D operator *(num x) {
    final c = clone();
    c.multiplyBy(x);
    return c;
  }

  void multiplyBy(num xx) {
    x *= xx;
    y *= xx;
  }

  /**
   * Returns a copy of the current point with rounded coordinates.
   */
  Point2D rounded() {
    final c = clone();
    c.round();
    return c;
  }

  void round() {
    x = x.round();
    y = y.round();
  }

  /**
   * Returns a copy of the current point with floored coordinates (rounded down).
   */
  Point2D floored() {
    final c = clone();
    c.floor();
    return c;
  }

  void floor() {
    x = x.floor();
    y = y.floor();
  }

  /**
   * Returns the distance between the current and the given points.
   */
  num distanceTo(Point2D point) {
    point = new Point2D.point(point);

    final xx = point.x - x;
    final yy = point.y - y;

    return math.sqrt(xx * xx + yy * yy);
  }

  /**
   * Returns true if the given point has the same coordinates.
   */
  bool operator ==(Point2D point) {
    point = new Point2D.point(point);

    return point.x == x && point.y == y;
  }

  /**
   * Returns true if the both coordinates of the given point are less than the corresponding current point coordinates (in absolute values).
   */
  bool contains(Point2D point) {
    point = new Point2D.point(point);

    return point.x.abs() <= x.abs() && point.y.abs() <= y.abs();
  }

  /**
   * Returns a string representation of the point for debugging purposes.
   */
  String toString() {
//    return 'Point(${formatNum(x)}, ${formatNum(y)})';
    return 'Point($x, $y)';
  }
}
