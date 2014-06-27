part of leaflet.layer.vector;

class PolygonOptions extends PolylineOptions {
  bool fill = true;
}

/**
 * Polygon is used to display polygons on a map.
 *
 * Note that points you pass when creating a polygon shouldn't have an additional last point equal to the first one - it's better to filter out such points.
 */
class Polygon extends Polyline {

  /*Map<String, Object> options = {
    'fill': true
  };*/

  PolygonOptions get polygonOptions => options as PolygonOptions;

  List<List<LatLng>> _holes;
  List _holePoints;

  Polygon(List<LatLng> latlngs, [PolygonOptions options=null, this._holes=null]) : super(latlngs, options) {
    if (options == null) {
      options = PolygonOptions();
    }

    if (_holes != null) {
      for (int i = 0; i < _holes.length; i++) {
        final hole = _holes[i];// = this._convertLatLngs(_holes[i]);
        if (hole[0] == hole[hole.length - 1]) {
          hole.removeLast();
        }
      }
    }

    // Filter out last point if its equal to the first one.
    latlngs = _latlngs;

    if (latlngs.length >= 2 && latlngs[0] == latlngs[latlngs.length - 1]) {
      latlngs.removeLast();
    }
  }

  projectLatlngs() {
    super.projectLatlngs();

    // project polygon holes points
    // TODO move this logic to Polyline to get rid of duplication
    _holePoints = [];

    if (_holes == null) { return; }

    for (int i = 0; i < _holes.length; i++) {
      _holePoints[i] = [];

      for (int j = 0; j < _holes[i].length; j++) {
        _holePoints[i][j] = _map.latLngToLayerPoint(_holes[i][j]);
      }
    }
  }

  /*setLatLngs(var latlngs) {
    if (latlngs && latlngs[0] is List && (!(latlngs[0][0] is num))) {
      _initWithHoles(latlngs);
      return redraw();
    } else {
      return super.setLatLngs(latlngs);
    }
  }*/

  setHoles(List<List<LatLng>> holes) {
    _holes = holes;
    for (int i = 0; i < _holes.length; i++) {
      final hole = _holes[i];// = _convertLatLngs(_holes[i]);
      if (hole[0] == hole[hole.length - 1]) {
        hole.removeLast();
      }
    }
    redraw();
  }

  _clipPoints() {
    var points = _originalPoints;
    final newParts = [];

    _parts = [points];
    _parts.addAll(_holePoints);

    if (polylineOptions.noClip) { return; }

    for (int i = 0; i < _parts.length; i++) {
      var clipped = clipPolygon(_parts[i], _map.pathViewport);
      if (clipped.length) {
        newParts.add(clipped);
      }
    }

    _parts = newParts;
  }

  _getPathPartStr(points) {
    var str = super._getPathPartStr(points);
    return str + (Browser.svg ? 'z' : 'x');
  }

  toGeoJSON() {
    final coords = [GeoJSON.latLngsToCoords(getLatLngs())];

    coords[0].add(coords[0][0]);

    if (_holes != null) {
      for (int i = 0; i < _holes.length; i++) {
        final hole = GeoJSON.latLngsToCoords(_holes[i]);
        hole.add(hole[0]);
        coords.add(hole);
      }
    }

    return GeoJSON.getFeature(this, {
      'type': 'Polygon',
      'coordinates': coords
    });
  }
}
