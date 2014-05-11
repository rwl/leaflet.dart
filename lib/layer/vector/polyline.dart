part of leaflet.layer.vector;

// Polyline is used to display polylines on a map.
class Polyline extends Path {
  Polyline(latlngs, options) {
    L.Path.prototype.initialize.call(this, options);

    this._latlngs = this._convertLatLngs(latlngs);
  }

  var options = {
    // how much to simplify the polyline on each zoom level
    // more = better performance and smoother look, less = more accurate
    'smoothFactor': 1.0,
    'noClip': false
  };

  projectLatlngs() {
    this._originalPoints = [];

    len = this._latlngs.length;
    for (var i = 0; i < len; i++) {
      this._originalPoints[i] = this._map.latLngToLayerPoint(this._latlngs[i]);
    }
  }

  getPathString() {
    len = this._parts.length;
    for (var i = 0, str = ''; i < len; i++) {
      str += this._getPathPartStr(this._parts[i]);
    }
    return str;
  }

  getLatLngs() {
    return this._latlngs;
  }

  setLatLngs(latlngs) {
    this._latlngs = this._convertLatLngs(latlngs);
    return this.redraw();
  }

  addLatLng(latlng) {
    this._latlngs.push(L.latLng(latlng));
    return this.redraw();
  }

  spliceLatLngs() { // (Number index, Number howMany)
    var removed = [].splice.apply(this._latlngs, arguments);
    this._convertLatLngs(this._latlngs, true);
    this.redraw();
    return removed;
  }

  closestLayerPoint(p) {
    var minDistance = Infinity, parts = this._parts, p1, p2, minPoint = null;

    jLen = parts.length;
    for (var j = 0; j < jLen; j++) {
      var points = parts[j];
      len = points.length;
      for (var i = 1; i < len; i++) {
        p1 = points[i - 1];
        p2 = points[i];
        var sqDist = L.LineUtil._sqClosestPointOnSegment(p, p1, p2, true);
        if (sqDist < minDistance) {
          minDistance = sqDist;
          minPoint = L.LineUtil._sqClosestPointOnSegment(p, p1, p2);
        }
      }
    }
    if (minPoint) {
      minPoint.distance = Math.sqrt(minDistance);
    }
    return minPoint;
  }

  getBounds() {
    return new L.LatLngBounds(this.getLatLngs());
  }

  _convertLatLngs(latlngs, overwrite) {
    var i, len, target = overwrite ? latlngs : [];

    len = latlngs.length;
    for (i = 0; i < len; i++) {
      if (L.Util.isArray(latlngs[i]) && !(latlngs[i][0] is num)) {
        return;
      }
      target[i] = L.latLng(latlngs[i]);
    }
    return target;
  }

  _initEvents() {
    L.Path.prototype._initEvents.call(this);
  }

  _getPathPartStr(points) {
    var round = L.Path.VML;

    for (var j = 0, len2 = points.length, str = '', p; j < len2; j++) {
      p = points[j];
      if (round) {
        p._round();
      }
      str += (j ? 'L' : 'M') + p.x + ' ' + p.y;
    }
    return str;
  }

  _clipPoints() {
    var points = this._originalPoints,
        len = points.length,
        i, k, segment;

    if (this.options.noClip) {
      this._parts = [points];
      return;
    }

    this._parts = [];

    var parts = this._parts,
        vp = this._map._pathViewport,
        lu = L.LineUtil;

    k = 0;
    for (i = 0; i < len - 1; i++) {
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
    var parts = this._parts,
        lu = L.LineUtil;

    for (var i = 0, len = parts.length; i < len; i++) {
      parts[i] = lu.simplify(parts[i], this.options.smoothFactor);
    }
  }

  _updatePath() {
    if (!this._map) { return; }

    this._clipPoints();
    this._simplifyPoints();

    L.Path.prototype._updatePath.call(this);
  }
}