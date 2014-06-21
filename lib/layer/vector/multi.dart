part of leaflet.layer.vector;

abstract class MultiFeatureGroup extends FeatureGroup {

  var _options;

  MultiFeatureGroup(List<LatLng> latlngs, this._options) : super(null);

  void setLatLngs(List<LatLng> latlngs) {
    int i = 0,
        len = latlngs.length;

    eachLayer((layer) {
      if (i < len) {
        layer.setLatLngs(latlngs[i++]);
      } else {
        removeLayer(layer);
      }
    });

    while (i < len) {
      _addLayer(latlngs[i++], _options);
    }
  }

  _addLayer(LatLng latlng, var options);

  List<LatLng> getLatLngs() {
    final latlngs = [];

    eachLayer((layer) {
      latlngs.add(layer.getLatLngs());
    });

    return latlngs;
  }
}

class MultiPolyline extends MultiFeatureGroup {

  MultiPolyline(List<LatLng> latlngs, options) : super(latlngs, options);

  _addLayer(LatLng latlng, var options) {
    addLayer(new Polyline([latlng], options));
  }
}

class MultiPolygon extends MultiFeatureGroup {

  MultiPolygon(List<LatLng> latlngs, options) : super(latlngs, options);

  _addLayer(LatLng latlng, var options) {
    addLayer(new Polygon([latlng], options));
  }
}
