

// Polygon is used to display polygons on a map.
class Polygon extends Polyline {
  var options = {
    'fill': true
  };

  Polygon(latlngs, options) {
    L.Polyline.prototype.initialize.call(this, latlngs, options);
    this._initWithHoles(latlngs);
  }

  _initWithHoles(latlngs) {
    var i, len, hole;
    if (latlngs && L.Util.isArray(latlngs[0]) && (!(latlngs[0][0] is num))) {
      this._latlngs = this._convertLatLngs(latlngs[0]);
      this._holes = latlngs.slice(1);

      len = this._holes.length;
      for (i = 0; i < len; i++) {
        hole = this._holes[i] = this._convertLatLngs(this._holes[i]);
        if (hole[0].equals(hole[hole.length - 1])) {
          hole.pop();
        }
      }
    }

    // filter out last point if its equal to the first one
    latlngs = this._latlngs;

    if (latlngs.length >= 2 && latlngs[0].equals(latlngs[latlngs.length - 1])) {
      latlngs.pop();
    }
  }

  projectLatlngs() {
    L.Polyline.prototype.projectLatlngs.call(this);

    // project polygon holes points
    // TODO move this logic to Polyline to get rid of duplication
    this._holePoints = [];

    if (!this._holes) { return; }

    var i, j, len, len2;

    len = this._holes.length;
    for (i = 0; i < len; i++) {
      this._holePoints[i] = [];

      len2 = this._holes[i].length;
      for (j = 0; j < len2; j++) {
        this._holePoints[i][j] = this._map.latLngToLayerPoint(this._holes[i][j]);
      }
    }
  }

  setLatLngs(latlngs) {
    if (latlngs && L.Util.isArray(latlngs[0]) && (!(latlngs[0][0] is num))) {
      this._initWithHoles(latlngs);
      return this.redraw();
    } else {
      return L.Polyline.prototype.setLatLngs.call(this, latlngs);
    }
  }

  _clipPoints() {
    var points = this._originalPoints,
        newParts = [];

    this._parts = [points].concat(this._holePoints);

    if (this.options.noClip) { return; }

    len = this._parts.length;
    for (var i = 0; i < len; i++) {
      var clipped = L.PolyUtil.clipPolygon(this._parts[i], this._map._pathViewport);
      if (clipped.length) {
        newParts.push(clipped);
      }
    }

    this._parts = newParts;
  }

  _getPathPartStr(points) {
    var str = L.Polyline.prototype._getPathPartStr.call(this, points);
    return str + (L.Browser.svg ? 'z' : 'x');
  }
}