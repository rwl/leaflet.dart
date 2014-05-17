part of leaflet.layer.vector;

class PolylineOptions {
  // How much to simplify the polyline on each zoom level. More means better performance and smoother look, and less means more accurate representation.
  num smoothFactor  = 1.0;
  // Disabled polyline clipping.
  bool noClip  = false;
}

// Polyline is used to display polylines on a map.
class Polyline extends Path {

  List<LatLng> _latlngs;
  List<Point> _originalPoints;
  List _parts;

  Polyline(List<LatLng> latlngs, Map<String, Object> options) : super(options) {
    this._latlngs = this._convertLatLngs(latlngs);
  }

  Map<String, Object> options = {
    // how much to simplify the polyline on each zoom level
    // more = better performance and smoother look, less = more accurate
    'smoothFactor': 1.0,
    'noClip': false
  };

  projectLatlngs() {
    this._originalPoints = [];

    final len = this._latlngs.length;
    for (var i = 0; i < len; i++) {
      this._originalPoints[i] = this._map.latLngToLayerPoint(this._latlngs[i]);
    }
  }

  getPathString() {
    final len = this._parts.length;
    String str = '';
    for (var i = 0; i < len; i++) {
      str += this._getPathPartStr(this._parts[i]);
    }
    return str;
  }

  getLatLngs() {
    return this._latlngs;
  }

  setLatLngs(List<LatLng> latlngs) {
    this._latlngs = this._convertLatLngs(latlngs);
    return this.redraw();
  }

  addLatLng(latlng) {
    this._latlngs.add(new LatLng.latLng(latlng));
    return this.redraw();
  }

  spliceLatLngs(int index, int howMany) { // (Number index, Number howMany)
    final sub = _latlngs.sublist(index, index+howMany);
    _latlngs.removeRange(index, index+howMany);
//    var removed = [].splice.apply(this._latlngs, arguments);
    this._convertLatLngs(this._latlngs, true);
    this.redraw();
    return sub;
  }

  closestLayerPoint(p) {
    var minDistance = double.INFINITY;
    var parts = this._parts, p1, p2, minPoint = null;

    final jLen = parts.length;
    for (var j = 0; j < jLen; j++) {
      var points = parts[j];
      final len = points.length;
      for (var i = 1; i < len; i++) {
        p1 = points[i - 1];
        p2 = points[i];
        var sqDist = LineUtil._sqClosestPointOnSegment(p, p1, p2, true);
        if (sqDist < minDistance) {
          minDistance = sqDist;
          minPoint = LineUtil._sqClosestPointOnSegment(p, p1, p2);
        }
      }
    }
    if (minPoint) {
      minPoint.distance = math.sqrt(minDistance);
    }
    return minPoint;
  }

  getBounds() {
    return new LatLngBounds(this.getLatLngs());
  }

  _convertLatLngs(/*List<LatLng>*/var latlngs, [bool overwrite = false]) {
    var i, len;
    final target = overwrite ? latlngs : [];

    len = latlngs.length;
    for (i = 0; i < len; i++) {
      if (latlngs[i] is List && !(latlngs[i][0] is num)) {
        return target;
      }
      target[i] = new LatLng.latLng(latlngs[i]);
    }
    return target;
  }

  _initEvents() {
    super._initEvents();
  }

  _getPathPartStr(points) {
    bool round = Path.VML;

    final len2 = points.length;
    var str = '';
    for (var j = 0; j < len2; j++) {
      final p = points[j];
      if (round) {
        p._round();
      }
      str += (j != 0 ? 'L' : 'M') + p.x + ' ' + p.y;
    }
    return str;
  }

  _clipPoints() {
    var points = this._originalPoints,
        len = points.length,
        segment;

    if (this.options['noClip']) {
      this._parts = [points];
      return;
    }

    this._parts = [];

    final parts = this._parts;
    final vp = this._map._pathViewport;
    final lu = LineUtil;

    int k = 0;
    for (int i = 0; i < len - 1; i++) {
      segment = lu.clipSegment(points[i], points[i + 1], vp, i);
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
    var parts = this._parts;
    final lu = LineUtil;

    for (int i = 0; i < parts.length; i++) {
      parts[i] = lu.simplify(parts[i], this.options['smoothFactor']);
    }
  }

  _updatePath() {
    if (this._map == null) { return; }

    this._clipPoints();
    this._simplifyPoints();

    super._updatePath();
  }
}