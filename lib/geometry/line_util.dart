part of leaflet.geometry;

//final LineUtil = new _LineUtil();

/// LineUtil contains different utility functions for line segments
/// and polylines (clipping, simplification, distances, etc.)
//class _LineUtil {

/// Dramatically reduces the number of points in a polyline while retaining
/// its shape and returns a new array of simplified points. Used for a huge
/// performance boost when processing/displaying Leaflet polylines for each
/// zoom level and also reducing visual noise. tolerance affects the amount
/// of simplification (lesser value means higher quality but slower and with
/// more points).
///
/// Douglas-Peucker simplification
List<Point2D> simplify(List<Point2D> points, num tolerance) {
//    if (!tolerance || !points.length) {
//      return points.slice();
//    }

  var sqTolerance = tolerance * tolerance;

  // stage 1: vertex reduction
  points = _reducePoints(points, sqTolerance);

  // stage 2: Douglas-Peucker simplification
  points = _simplifyDP(points, sqTolerance);

  return points;
}

/// Returns the distance between point p and segment p1 to p2.
num pointToSegmentDistance(Point2D p, Point2D p1, Point2D p2) {
  return math.sqrt(_sqClosestPointOnSegment(p, p1, p2, true));
}

/// Returns the closest point from a point p on a segment p1 to p2.
Point2D closestPointOnSegment(Point2D p, Point2D p1, Point2D p2) {
  return _sqClosestPointOnSegment(p, p1, p2);
}

/// Douglas-Peucker simplification, see http://en.wikipedia.org/wiki/Douglas-Peucker_algorithm
List<Point2D> _simplifyDP(List<Point2D> points, num sqTolerance) {

  final len = points.length,
      //ArrayConstructor = typeof Uint8Array !== undefined + '' ? Uint8Array : Array,
      markers = new List<bool>(len);

  markers[0] = markers[len - 1] = true;

  _simplifyDPStep(points, markers, sqTolerance, 0, len - 1);

  final newPoints = [];

  for (int i = 0; i < len; i++) {
    if (markers[i] != null && markers[i]) {
      newPoints.add(points[i]);
    }
  }

  return newPoints;
}

void _simplifyDPStep(List<Point2D> points, List<bool >markers, num sqTolerance, int first, int last) {
  num maxSqDist = 0;
  int index;

  for (int i = first + 1; i <= last - 1; i++) {
    final sqDist = _sqClosestPointOnSegment(points[i], points[first], points[last], true);

    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    markers[index] = true;

    _simplifyDPStep(points, markers, sqTolerance, first, index);
    _simplifyDPStep(points, markers, sqTolerance, index, last);
  }
}

/// Reduce points that are too close to each other to a single point.
List<Point2D> _reducePoints(points, sqTolerance) {
  var reducedPoints = [points[0]];

  int prev = 0;
  final len = points.length;
  for (int i = 1; i < len; i++) {
    if (_sqDist(points[i], points[prev]) > sqTolerance) {
      reducedPoints.add(points[i]);
      prev = i;
    }
  }
  if (prev < len - 1) {
    reducedPoints.add(points[len - 1]);
  }
  return reducedPoints;
}

int _lastCode;

/// Clips the segment a to b by rectangular bounds (modifying the segment
/// points directly!). Used by Leaflet to only show polyline points that
/// are on the screen or near, increasing performance.
///
/// Cohen-Sutherland line clipping algorithm.
clipSegment(Point2D a, Point2D b, Bounds bounds, [bool useLastCode=false]) {
  int codeA = useLastCode ? _lastCode : _getBitCode(a, bounds),
      codeB = _getBitCode(b, bounds);

  //var codeOut, p, newCode;

  // save 2nd code to avoid calculating it on the next segment
  _lastCode = codeB;

  while (true) {
    // if a,b is inside the clip window (trivial accept)
    if ((codeA | codeB) == 0) {
      return [a, b];
    // if a,b is outside the clip window (trivial reject)
    } else if ((codeA & codeB) != 0) {
      return false;
    // other cases
    } else {
      final codeOut = codeA != 0 ? codeA : codeB;
      final p = _getEdgeIntersection(a, b, codeOut, bounds);
      final newCode = _getBitCode(p, bounds);

      if (codeOut == codeA) {
        a = p;
        codeA = newCode;
      } else {
        b = p;
        codeB = newCode;
      }
    }
  }
}

Point2D _getEdgeIntersection(Point2D a, Point2D b, int code, Bounds bounds) {
  final dx = b.x - a.x,
      dy = b.y - a.y,
      min = bounds.min,
      max = bounds.max;

  if ((code & 8) != 0) { // top
    return new Point2D(a.x + dx * (max.y - a.y) / dy, max.y);
  } else if ((code & 4) != 0) { // bottom
    return new Point2D(a.x + dx * (min.y - a.y) / dy, min.y);
  } else if ((code & 2) != 0) { // right
    return new Point2D(max.x, a.y + dy * (max.x - a.x) / dx);
  } else if ((code & 1) != 0) { // left
    return new Point2D(min.x, a.y + dy * (min.x - a.x) / dx);
  }
  return null;
}

int _getBitCode(Point2D p, Bounds bounds) {
  var code = 0;

  if (p.x < bounds.min.x) { // left
    code |= 1;
  } else if (p.x > bounds.max.x) { // right
    code |= 2;
  }
  if (p.y < bounds.min.y) { // bottom
    code |= 4;
  } else if (p.y > bounds.max.y) { // top
    code |= 8;
  }

  return code;
}

/// Square distance (to avoid unnecessary Math.sqrt calls).
num _sqDist(Point2D p1, Point2D p2) {
  final dx = p2.x - p1.x,
      dy = p2.y - p1.y;
  return dx * dx + dy * dy;
}

/// Return closest point on segment or distance to that point.
_sqClosestPointOnSegment(Point2D p, Point2D p1, Point2D p2, [bool sqDist=false]) {
  var x = p1.x,
      y = p1.y,
      dx = p2.x - x,
      dy = p2.y - y,
      dot = dx * dx + dy * dy,
      t;

  if (dot > 0) {
    t = ((p.x - x) * dx + (p.y - y) * dy) / dot;

    if (t > 1) {
      x = p2.x;
      y = p2.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;

  return sqDist ? dx * dx + dy * dy : new Point2D(x, y);
}
