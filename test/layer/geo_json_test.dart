import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('L.GeoJSON', () {
    group('addData', () {
      var geoJSON = {
                     type: 'Feature',
                     properties: {},
                     geometry: {
                       type: 'Point',
                       coordinates: [20, 10, 5]
                     }
      };

      test('sets feature property on member layers', () {
        var layer = new L.GeoJSON();
        layer.addData(geoJSON);
        expect(layer.getLayers()[0].feature).to.eql(geoJSON);
      });

      test('normalizes a geometry to a Feature', () {
        var layer = new L.GeoJSON();
        layer.addData(geoJSON.geometry);
        expect(layer.getLayers()[0].feature).to.eql(geoJSON);
      });
    });
  });

  group('L.Marker#toGeoJSON', () {
    test('returns a 2D Point object', () {
      var marker = new L.Marker([10, 20]);
      expect(marker.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10]
      });
    });

    test('returns a 3D Point object', () {
      var marker = new L.Marker([10, 20, 30]);
      expect(marker.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10, 30]
      });
    });
  });

  group('L.Circle#toGeoJSON', () {
    test('returns a 2D Point object', () {
      var circle = new L.Circle([10, 20], 100);
      expect(circle.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10]
      });
    });

    test('returns a 3D Point object', () {
      var circle = new L.Circle([10, 20, 30], 100);
      expect(circle.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10, 30]
      });
    });
  });

  group('L.CircleMarker#toGeoJSON', () {
    test('returns a 2D Point object', () {
      var marker = new L.CircleMarker([10, 20]);
      expect(marker.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10]
      });
    });

    test('returns a 3D Point object', () {
      var marker = new L.CircleMarker([10, 20, 30]);
      expect(marker.toGeoJSON().geometry).to.eql({
        type: 'Point',
        coordinates: [20, 10, 30]
      });
    });
  });

  group('L.Polyline#toGeoJSON', () {
    test('returns a 2D LineString object', () {
      var polyline = new L.Polyline([[10, 20], [2, 5]]);
      expect(polyline.toGeoJSON().geometry).to.eql({
        type: 'LineString',
        coordinates: [[20, 10], [5, 2]]
      });
    });

    test('returns a 3D LineString object', () {
      var polyline = new L.Polyline([[10, 20, 30], [2, 5, 10]]);
      expect(polyline.toGeoJSON().geometry).to.eql({
        type: 'LineString',
        coordinates: [[20, 10, 30], [5, 2, 10]]
      });
    });
  });

  group('L.MultiPolyline#toGeoJSON', () {
    test('returns a 2D MultiLineString object', () {
      var multiPolyline = new L.MultiPolyline([[[10, 20], [2, 5]], [[1, 2], [3, 4]]]);
      expect(multiPolyline.toGeoJSON().geometry).to.eql({
        type: 'MultiLineString',
        coordinates: [
                      [[20, 10], [5, 2]],
                      [[2, 1], [4, 3]]
                      ]
      });
    });

    test('returns a 3D MultiLineString object', () {
      var multiPolyline = new L.MultiPolyline([[[10, 20, 30], [2, 5, 10]], [[1, 2, 3], [4, 5, 6]]]);
      expect(multiPolyline.toGeoJSON().geometry).to.eql({
        type: 'MultiLineString',
        coordinates: [
                      [[20, 10, 30], [5, 2, 10]],
                      [[2, 1, 3], [5, 4, 6]]
                      ]
      });
    });
  });

  group('L.Polygon#toGeoJSON', () {
    test('returns a 2D Polygon object (no holes)', () {
      var polygon = new L.Polygon([[1, 2], [3, 4], [5, 6]]);
      expect(polygon.toGeoJSON().geometry).to.eql({
        type: 'Polygon',
        coordinates: [[[2, 1], [4, 3], [6, 5], [2, 1]]]
      });
    });

    test('returns a 3D Polygon object (no holes)', () {
      var polygon = new L.Polygon([[1, 2, 3], [4, 5, 6], [7, 8, 9]]);
      expect(polygon.toGeoJSON().geometry).to.eql({
        type: 'Polygon',
        coordinates: [[[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]]]
      });
    });

    test('returns a 2D Polygon object (with holes)', () {
      var polygon = new L.Polygon([[[1, 2], [3, 4], [5, 6]], [[7, 8], [9, 10], [11, 12]]]);
      expect(polygon.toGeoJSON().geometry).to.eql({
        type: 'Polygon',
        coordinates: [
                      [[2, 1], [4, 3], [6, 5], [2, 1]],
                      [[8, 7], [10, 9], [12, 11], [8, 7]]
                      ]
      });
    });

    test('returns a 3D Polygon object (with holes)', () {
      var polygon = new L.Polygon([[[1, 2, 3], [4, 5, 6], [7, 8, 9]], [[10, 11, 12], [13, 14, 15], [16, 17, 18]]]);
      expect(polygon.toGeoJSON().geometry).to.eql({
        type: 'Polygon',
        coordinates: [
                      [[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]],
                      [[11, 10, 12], [14, 13, 15], [17, 16, 18], [11, 10, 12]]
                      ]
      });
    });
  });

  group('L.MultiPolygon#toGeoJSON', () {
    test('returns a 2D MultiPolygon object', () {
      var multiPolygon = new L.MultiPolygon([[[1, 2], [3, 4], [5, 6]]]);
      expect(multiPolygon.toGeoJSON().geometry).to.eql({
        type: 'MultiPolygon',
        coordinates: [
                      [[[2, 1], [4, 3], [6, 5], [2, 1]]]
                      ]
      });
    });

    test('returns a 3D MultiPolygon object', () {
      var multiPolygon = new L.MultiPolygon([[[1, 2, 3], [4, 5, 6], [7, 8, 9]]]);
      expect(multiPolygon.toGeoJSON().geometry).to.eql({
        type: 'MultiPolygon',
        coordinates: [
                      [[[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]]]
                      ]
      });
    });
  });

  group('L.LayerGroup#toGeoJSON', () {
    test('returns a 2D FeatureCollection object', () {
      var marker = new L.Marker([10, 20]),
          polyline = new L.Polyline([[10, 20], [2, 5]]),
          layerGroup = new L.LayerGroup([marker, polyline]);
      expect(layerGroup.toGeoJSON()).to.eql({
        type: 'FeatureCollection',
        features: [marker.toGeoJSON(), polyline.toGeoJSON()]
      });
    });

    test('returns a 3D FeatureCollection object', () {
      var marker = new L.Marker([10, 20, 30]),
          polyline = new L.Polyline([[10, 20, 30], [2, 5, 10]]),
          layerGroup = new L.LayerGroup([marker, polyline]);
      expect(layerGroup.toGeoJSON()).to.eql({
        type: 'FeatureCollection',
        features: [marker.toGeoJSON(), polyline.toGeoJSON()]
      });
    });

    test('ensures that every member is a Feature', () {
      var tileLayer = new L.TileLayer(),
          layerGroup = new L.LayerGroup([tileLayer]);

      tileLayer.toGeoJSON = () {
        return {
          type: 'Point',
          coordinates: [20, 10]
        };
      };

      expect(layerGroup.toGeoJSON()).to.eql({
        type: 'FeatureCollection',
        features: [{
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'Point',
            coordinates: [20, 10]
          }
        }]
      });
    });

    test('roundtrips GeometryCollection features', () {
      var json = {
                  'type': 'FeatureCollection',
                  'features': [{
                    'type': 'Feature',
                    'geometry': {
                      'type': 'GeometryCollection',
                      'geometries': [{
                        'type': 'LineString',
                        'coordinates': [[-122.4425587930444, 37.80666418607323], [-122.4428379594768, 37.80663578323093]]
                      }, {
                        'type': 'LineString',
                        'coordinates': [
                                        [-122.4425509770566, 37.80662588061205],
                                        [-122.4428340530617, 37.8065999493009]
                                        ]
                      }]
                    },
                    'properties': {
                      'name': 'SF Marina Harbor Master'
                    }
                  }]
      };

      expect(L.geoJson(json).toGeoJSON()).to.eql(json);
    });

    test('roundtrips MiltiPoint features', () {
      var json = {
                  'type': 'FeatureCollection',
                  'features': [{
                    'type': 'Feature',
                    'geometry': {
                      'type': 'MultiPoint',
                      'coordinates': [[-122.4425587930444, 37.80666418607323], [-122.4428379594768, 37.80663578323093]]
                    },
                    'properties': {
                      'name': 'Test MultiPoints'
                    }
                  }]
      };

      expect(L.geoJson(json).toGeoJSON()).to.eql(json);
    });

    test('omits layers which do not implement toGeoJSON', () {
      var tileLayer = new L.TileLayer(),
          layerGroup = new L.LayerGroup([tileLayer]);
      expect(layerGroup.toGeoJSON()).to.eql({
        type: 'FeatureCollection',
        features: []
      });
    });
  });
}