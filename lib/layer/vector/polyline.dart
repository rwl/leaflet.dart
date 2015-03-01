part of leaflet.layer.vector;

class PolylineOptions extends PathOptions {
  /// How much to simplify the polyline on each zoom level. More means
  /// better performance and smoother look, and less means more accurate
  /// representation.
  num smoothFactor  = 1.0;

  /// Disabled polyline clipping.
  bool noClip  = false;
}

/// Polyline is used to display polylines on a map.
class Polyline extends Path {

  List<Point2D> _originalPoints;
  List _parts;

  Polyline(List<LatLng> latlngs, [PolylineOptions polylineOptions=null]) : super(polylineOptions) {
    if (options == null) {
      options = new PolylineOptions();
    }
    _latlngs = new List.from(latlngs);//_convertLatLngs(latlngs);
    //polylineOptions = polylineOptions;
  }

  PolylineOptions get polylineOptions => options as PolylineOptions;
  /*Map<String, Object> options = {
    // how much to simplify the polyline on each zoom level
    // more = better performance and smoother look, less = more accurate
    'smoothFactor': 1.0,
    'noClip': false
  };*/

  projectLatlngs() {
    final len = _latlngs.length;
    _originalPoints = new List(len);

    for (var i = 0; i < len; i++) {
      _originalPoints[i] = _map.latLngToLayerPoint(_latlngs[i]);
    }
  }

  getPathString() {
    final len = _parts.length;
    String str = '';
    for (var i = 0; i < len; i++) {
      str += _getPathPartStr(_parts[i]);
    }
    return str;
  }

  /// Returns an array of the points in the path.
  getLatLngs() {
    return _latlngs;
  }

  /// Replaces all the points in the polyline with the given array of
  /// geographical points.
  setLatLngs(List<LatLng> latlngs) {
    _latlngs = latlngs;//_convertLatLngs(latlngs);
    return redraw();
  }

  /// Adds a given point to the polyline.
  addLatLng(LatLng latlng) {
    _latlngs.add(new LatLng.latLng(latlng));
    return redraw();
  }

  /// Allows adding, removing or replacing points in the polyline. Syntax
  /// is the same as in Array#splice. Returns the array of removed points
  /// (if any).
  spliceLatLngs(int index, int howMany, [List<LatLng> add=null]) { // (Number index, Number howMany)
//    final sub = _latlngs.sublist(index, index+howMany);
    _latlngs.removeRange(index, index+howMany);
    if (add != null) {
      _latlngs.insertAll(index, add);
    }
//    var removed = [].splice.apply(_latlngs, arguments);
    //_convertLatLngs(_latlngs, true);
    redraw();
    return _latlngs;
  }

  /// [distance] is only used for testing.
  closestLayerPoint(p, [List distance]) {
    var minDistance = double.INFINITY;
    var parts = _parts, p1, p2;
    Point2D minPoint = null;

    final jLen = parts.length;
    for (var j = 0; j < jLen; j++) {
      var points = parts[j];
      final len = points.length;
      for (var i = 1; i < len; i++) {
        p1 = points[i - 1];
        p2 = points[i];
        var sqDist = sqClosestPointOnSegment(p, p1, p2, true);
        if (sqDist < minDistance) {
          minDistance = sqDist;
          minPoint = sqClosestPointOnSegment(p, p1, p2);
        }
      }
    }
    if (minPoint != null && distance != null) {
      distance[0] = math.sqrt(minDistance);
    }
    return minPoint;
  }

  /// Returns the LatLngBounds of the polyline.
  getBounds() {
    return new LatLngBounds(getLatLngs());
  }

  /*List<LatLng> _convertLatLngs(List<List<LatLng>> latlngs) {//, [bool overwrite = false]) {
    final target = [];//overwrite ? latlngs : [];

    for (int i = 0; i < latlngs.length; i++) {
      if (latlngs[i] is List && !(latlngs[i][0] is num)) {
        return target;
      }
      target[i] = new LatLng.latLng(latlngs[i]);
    }
    return target;
  }*/

  _initEvents() {
    super._initEvents();
  }

  _getPathPartStr(points) {
    bool round = false;//Path.VML;

    final len2 = points.length;
    var str = '';
    for (var j = 0; j < len2; j++) {
      final p = points[j];
      if (round) {
        p._round();
      }
      str += (j != 0 ? 'L' : 'M') + '${p.x} ${p.y}';
    }
    return str;
  }

  _clipPoints() {
    var points = _originalPoints,
        len = points.length,
        segment;

    if (polylineOptions.noClip) {
      _parts = [points];
      return;
    }

    _parts = [];

    final parts = _parts;
    final vp = _map.pathViewport;

    int k = 0;
    for (int i = 0; i < len - 1; i++) {
      segment = clipSegment(points[i], points[i + 1], vp, i != 0);
      if (!segment) {
        continue;
      }

      parts[k] = parts[k] || [];
      parts[k].push(segment[0]);

      // if segment goes out of screen, or it's the last one, it's the end of the line part
      if ((segment[1] != points[i + 1]) || (i == len - 2)) {
        parts[k].push(segment[1]);
        k++;
      }
    }
  }

  // simplify each clipped part of the polyline
  _simplifyPoints() {
    final parts = _parts;

    for (int i = 0; i < parts.length; i++) {
      parts[i] = simplify(parts[i], polylineOptions.smoothFactor);
    }
  }

  _updatePath([Object obj, MapEvent e]) {
    if (_map == null) { return; }

    _clipPoints();
    _simplifyPoints();

    super._updatePath();
  }

  toGeoJSON() {
    return GeoJSON.getFeature(this, {
      'type': 'LineString',
      'coordinates': GeoJSON.latLngsToCoords(getLatLngs())
    });
  }
}
