part of leaflet.layer.test;
/*
geoJsonTest() {
  group('GeoJSON', () {
    group('addData', () {
      var geoJSON = {
        'type': 'Feature',
        'properties': {},
        'geometry': {
          'type': 'Point',
          'coordinates': [20, 10, 5]
        }
      };

      test('sets feature property on member layers', () {
        var layer = new GeoJSON();
        layer.addData(geoJSON);
        expect(layer.getLayers()[0].feature, equals(geoJSON));
      });

      test('normalizes a geometry to a Feature', () {
        var layer = new GeoJSON();
        layer.addData(geoJSON.geometry);
        expect(layer.getLayers()[0].feature, equals(geoJSON));
      });
    });
  });

  group('L.Marker#toGeoJSON', () {
    test('returns a 2D Point object', () {
      final marker = new Marker(new LatLng(10, 20));
      expect(marker.toGeoJSON()['geometry'], equals({
        'type': 'Point',
        'coordinates': [20, 10]
      }));
    });

    test('returns a 3D Point object', () {
      final marker = new Marker(new LatLng(10, 20, 30));
      expect(marker.toGeoJSON()['geometry'], equals({
        'type': 'Point',
        'coordinates': [20, 10, 30]
      }));
    });
  });

  group('Circle.toGeoJSON', () {
    test('returns a 2D Point object', () {
      final circle = new Circle(new LatLng(10, 20), 100);
      expect(circle.toGeoJSON().geometry, equals({
        'type': 'Point',
        'coordinates': [20, 10]
      }));
    });

    test('returns a 3D Point object', () {
      final circle = new Circle(new LatLng(10, 20, 30), 100);
      expect(circle.toGeoJSON().geometry, equals({
        'type': 'Point',
        'coordinates': [20, 10, 30]
      }));
    });
  });

  group('CircleMarker.toGeoJSON', () {
    test('returns a 2D Point object', () {
      final marker = new CircleMarker(new LatLng(10, 20));
      expect(marker.toGeoJSON().geometry, equals({
        'type': 'Point',
        'coordinates': [20, 10]
      }));
    });

    test('returns a 3D Point object', () {
      final marker = new CircleMarker(new LatLng(10, 20, 30));
      expect(marker.toGeoJSON().geometry, equals({
        'type': 'Point',
        'coordinates': [20, 10, 30]
      }));
    });
  });

  group('Polyline.toGeoJSON', () {
    test('returns a 2D LineString object', () {
      final polyline = new Polyline([new LatLng(10, 20), new LatLng(2, 5)]);
      expect(polyline.toGeoJSON().geometry, equals({
        'type': 'LineString',
        'coordinates': [[20, 10], [5, 2]]
      }));
    });

    test('returns a 3D LineString object', () {
      final polyline = new Polyline([new LatLng(10, 20, 30), new LatLng(2, 5, 10)]);
      expect(polyline.toGeoJSON().geometry, equals({
        'type': 'LineString',
        'coordinates': [[20, 10, 30], [5, 2, 10]]
      }));
    });
  });

  group('MultiPolyline.toGeoJSON', () {
    test('returns a 2D MultiLineString object', () {
      final multiPolyline = new MultiPolyline([[[10, 20], [2, 5]], [[1, 2], [3, 4]]]);
      expect(multiPolyline.toGeoJSON().geometry, equals({
        'type': 'MultiLineString',
        'coordinates': [
          [[20, 10], [5, 2]],
          [[2, 1], [4, 3]]
        ]
      }));
    });

    test('returns a 3D MultiLineString object', () {
      final multiPolyline = new MultiPolyline([[[10, 20, 30], [2, 5, 10]], [[1, 2, 3], [4, 5, 6]]]);
      expect(multiPolyline.toGeoJSON().geometry, equals({
        'type': 'MultiLineString',
        'coordinates': [
          [[20, 10, 30], [5, 2, 10]],
          [[2, 1, 3], [5, 4, 6]]
        ]
      }));
    });
  });

  group('Polygon.toGeoJSON', () {
    test('returns a 2D Polygon object (no holes)', () {
      var polygon = new Polygon([new LatLng(1, 2), new LatLng(3, 4), new LatLng(5, 6)]);
      expect(polygon.toGeoJSON().geometry, equals({
        'type': 'Polygon',
        'coordinates': [[[2, 1], [4, 3], [6, 5], [2, 1]]]
      }));
    });

    test('returns a 3D Polygon object (no holes)', () {
      final polygon = new Polygon([new LatLng(1, 2, 3), new LatLng(4, 5, 6), new LatLng(7, 8, 9)]);
      expect(polygon.toGeoJSON().geometry, equals({
        'type': 'Polygon',
        'coordinates': [[[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]]]
      }));
    });

    test('returns a 2D Polygon object (with holes)', () {
      final polygon = new Polygon([
        [new LatLng(1, 2), new LatLng(3, 4), new LatLng(5, 6)],
        [new LatLng(7, 8), new LatLng(9, 10), new LatLng(11, 12)]
      ]);
      expect(polygon.toGeoJSON().geometry, equals({
        'type': 'Polygon',
        'coordinates': [
          [[2, 1], [4, 3], [6, 5], [2, 1]],
          [[8, 7], [10, 9], [12, 11], [8, 7]]
        ]
      }));
    });

    test('returns a 3D Polygon object (with holes)', () {
      final polygon = new Polygon([
        [new LatLng(1, 2, 3), new LatLng(4, 5, 6), new LatLng(7, 8, 9)],
        [new LatLng(10, 11, 12), new LatLng(13, 14, 15), new LatLng(16, 17, 18)]
      ]);
      expect(polygon.toGeoJSON().geometry, equals({
        'type': 'Polygon',
        'coordinates': [
          [[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]],
          [[11, 10, 12], [14, 13, 15], [17, 16, 18], [11, 10, 12]]
        ]
      }));
    });
  });

  group('MultiPolygon.toGeoJSON', () {
    test('returns a 2D MultiPolygon object', () {
      final multiPolygon = new MultiPolygon([[new LatLng(1, 2), new LatLng(3, 4), new LatLng(5, 6)]]);
      expect(multiPolygon.toGeoJSON().geometry, equals({
        'type': 'MultiPolygon',
        'coordinates': [
          [[[2, 1], [4, 3], [6, 5], [2, 1]]]
        ]
      }));
    });

    test('returns a 3D MultiPolygon object', () {
      final multiPolygon = new MultiPolygon([[new LatLng(1, 2, 3), new LatLng(4, 5, 6), new LatLng(7, 8, 9)]]);
      expect(multiPolygon.toGeoJSON().geometry, equals({
        'type': 'MultiPolygon',
        'coordinates': [
          [[[2, 1, 3], [5, 4, 6], [8, 7, 9], [2, 1, 3]]]
        ]
      }));
    });
  });

  group('LayerGroup.toGeoJSON', () {
    test('returns a 2D FeatureCollection object', () {
      final marker = new Marker(new LatLng(10, 20)),
          polyline = new Polyline([new LatLng(10, 20), new LatLng(2, 5)]),
          layerGroup = new LayerGroup([marker, polyline]);
      expect(layerGroup.toGeoJSON().geometry, equals({
        'type': 'FeatureCollection',
        'features': [marker.toGeoJSON(), polyline.toGeoJSON()]
      }));
    });

    test('returns a 3D FeatureCollection object', () {
      final marker = new Marker(new LatLng(10, 20, 30)),
          polyline = new Polyline([new LatLng(10, 20, 30), new LatLng(2, 5, 10)]),
          layerGroup = new LayerGroup([marker, polyline]);
      expect(layerGroup.toGeoJSON().geometry, equals({
        'type': 'FeatureCollection',
        'features': [marker.toGeoJSON(), polyline.toGeoJSON()]
      }));
    });

    test('ensures that every member is a Feature', () {
      final tileLayer = new TileLayer(),
          layerGroup = new LayerGroup([tileLayer]);

      tileLayer.toGeoJSON = () {
        return {
          'type': 'Point',
          'coordinates': [20, 10]
        };
      };

      expect(layerGroup.toGeoJSON().geometry, equals({
        'type': 'FeatureCollection',
        'features': [{
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'Point',
            'coordinates': [20, 10]
          }
        }]
      }));
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
              'coordinates': [
                [-122.4425587930444, 37.80666418607323],
                [-122.4428379594768, 37.80663578323093]
              ]
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

      expect(geoJson(json).toGeoJSON().geometry, equals(json));
    });

    test('roundtrips MiltiPoint features', () {
      var json = {
        'type': 'FeatureCollection',
        'features': [{
          'type': 'Feature',
          'geometry': {
            'type': 'MultiPoint',
            'coordinates': [
              [-122.4425587930444, 37.80666418607323],
              [-122.4428379594768, 37.80663578323093]
            ]
          },
          'properties': {
            'name': 'Test MultiPoints'
          }
        }]
      };

      expect(geoJson(json).toGeoJSON().geometry, equals(json));
    });

    test('omits layers which do not implement toGeoJSON', () {
      var tileLayer = new TileLayer(),
          layerGroup = new LayerGroup([tileLayer]);
      expect(layerGroup.toGeoJSON().geometry, equals({
        'type': 'FeatureCollection',
        'features': []
      }));
    });
  });
}*/