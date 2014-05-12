part of leaflet.layer.vector;

// Polygon is used to display polygons on a map.
class Polygon extends Polyline {

  Map<String, Object> options = {
    'fill': true
  };

  List _holes;
  List _holePoints;

  Polygon(latlngs, options) : super(latlngs, options) {
    this._initWithHoles(latlngs);
  }

  _initWithHoles(/*List<LatLng>*/var latlngs) {
    if (latlngs && latlngs[0] is List && (!(latlngs[0][0] is num))) {
      this._latlngs = this._convertLatLngs(latlngs[0]);
      this._holes = latlngs.removeAt(1);

      for (int i = 0; i < _holes.length; i++) {
        final hole = this._holes[i] = this._convertLatLngs(this._holes[i]);
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
    super.projectLatlngs();

    // project polygon holes points
    // TODO move this logic to Polyline to get rid of duplication
    this._holePoints = [];

    if (this._holes == null) { return; }

    for (int i = 0; i < _holes.length; i++) {
      this._holePoints[i] = [];

      for (j = 0; j < _holes[i].length; j++) {
        this._holePoints[i][j] = this._map.latLngToLayerPoint(this._holes[i][j]);
      }
    }
  }

  setLatLngs(var latlngs) {
    if (latlngs && latlngs[0] is List && (!(latlngs[0][0] is num))) {
      this._initWithHoles(latlngs);
      return this.redraw();
    } else {
      return super.setLatLngs(latlngs);
    }
  }

  _clipPoints() {
    var points = this._originalPoints;
    final newParts = [];

    this._parts = [points];
    this._parts.addAll(this._holePoints);

    if (this.options['noClip']) { return; }

    for (int i = 0; i < _parts.length; i++) {
      var clipped = PolyUtil.clipPolygon(this._parts[i], this._map._pathViewport);
      if (clipped.length) {
        newParts.add(clipped);
      }
    }

    this._parts = newParts;
  }

  _getPathPartStr(points) {
    var str = super._getPathPartStr(points);
    return str + (Browser.svg ? 'z' : 'x');
  }
}
