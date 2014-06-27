part of leaflet.geometry;

//final PolyUtil = new _PolyUtil();

/**
 * PolyUtil contains utility functions for polygons (clipping, etc.).
 */
//class _PolyUtil {

/**
 * Clips the polygon geometry defined by the given points by rectangular
 * bounds. Used by Leaflet to only show polygon points that are on the
 * screen or near, increasing performance. Note that polygon points needs
 * different algorithm for clipping than polyline, so there's a seperate
 * method for it.
 *
 * Sutherland-Hodgeman polygon clipping algorithm.
 */
List<Point2D> clipPolygon(List<Point2D> points, Bounds bounds) {
  final edges = [1, 4, 2, 8];

  final len = points.length;
  for (int i = 0; i < len; i++) {
    points[i]._code = _getBitCode(points[i], bounds);
  }

  // for each edge (left, bottom, right, top)
  for (int k = 0; k < 4; k++) {
    final edge = edges[k];
    final clippedPoints = [];

    final len = points.length;
    int j = len - 1;
    for (int i = 0; i < len; j = i++) {
      final a = points[i];
      final b = points[j];

      // if a is inside the clip window
      if ((a._code & edge) == 0) {
        // if b is outside the clip window (a->b goes out of screen)
        if ((b._code & edge) != 0) {
          final p = _getEdgeIntersection(b, a, edge, bounds);
          p._code = _getBitCode(p, bounds);
          clippedPoints.add(p);
        }
        clippedPoints.add(a);

        // else if b is inside the clip window (a->b enters the screen)
      } else if (!(b._code & edge)) {
        final p = _getEdgeIntersection(b, a, edge, bounds);
        p._code = _getBitCode(p, bounds);
        clippedPoints.add(p);
      }
    }
    points = clippedPoints;
  }

  return points;
}
