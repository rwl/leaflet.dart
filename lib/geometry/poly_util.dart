part of leaflet.geometry;

final PolyUtil = new _PolyUtil();

// PolyUtil contains utility functions for polygons (clipping, etc.).
class _PolyUtil {

  // Sutherland-Hodgeman polygon clipping algorithm.
  // Used to avoid rendering parts of a polygon that are not currently visible.
  clipPolygon(points, bounds) {
    var clippedPoints,
    edges = [1, 4, 2, 8],
    i, j, k,
    a, b,
    len, edge, p,
    lu = LineUtil;

    len = points.length;
    for (i = 0; i < len; i++) {
      points[i]._code = lu._getBitCode(points[i], bounds);
    }

    // for each edge (left, bottom, right, top)
    for (k = 0; k < 4; k++) {
      edge = edges[k];
      clippedPoints = [];

      len = points.length;
      j = len - 1;
      for (i = 0; i < len; j = i++) {
        a = points[i];
        b = points[j];

        // if a is inside the clip window
        if (!(a._code & edge)) {
          // if b is outside the clip window (a->b goes out of screen)
          if (b._code & edge) {
            p = lu._getEdgeIntersection(b, a, edge, bounds);
            p._code = lu._getBitCode(p, bounds);
            clippedPoints.add(p);
          }
          clippedPoints.add(a);

          // else if b is inside the clip window (a->b enters the screen)
        } else if (!(b._code & edge)) {
          p = lu._getEdgeIntersection(b, a, edge, bounds);
          p._code = lu._getBitCode(p, bounds);
          clippedPoints.add(p);
        }
      }
      points = clippedPoints;
    }

    return points;
  }
}