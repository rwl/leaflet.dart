import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/vector/vector.dart' show Polygon;

main() {
  useHtmlEnhancedConfiguration();

  group('Polygon', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    var map = new LeafletMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('#initialize', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        final sourceLatLngs = originalLatLngs.slice();

        final polygon = new Polygon(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
        expect(polygon._latlngs, isNot(equals(sourceLatLngs)));
      });

      test('can be called with an empty array', () {
        final polygon = new Polygon([]);
        expect(polygon.getLatLngs(), equals([]));
      });

      test('can be initialized with holes', () {
        final originalLatLngs = [
                               [ //external rink
                                 [0, 10], [10, 10], [10, 0]
                                 ], [ //hole
                                      [2, 3], [2, 4], [3, 4]
                                      ]
                               ];

        final polygon = new Polygon(originalLatLngs);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs(), equals([new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)]));
      });
    });

    group('#setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        final sourceLatLngs = originalLatLngs.slice();

        final polygon = new Polygon(sourceLatLngs);

        polygon.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
      });

      test('can be set external ring and holes', () {
        final latLngs = [
                       [ //external rink
                         [0, 10], [10, 10], [10, 0]
                         ], [ //hole
                              [2, 3], [2, 4], [3, 4]
                              ]
                       ];

        final polygon = new Polygon([]);
        polygon.setLatLngs(latLngs);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs(), equals([new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)]));
      });
    });

    group('#spliceLatLngs', () {
      test('splices the internal latLngs', () {
        final latLngs = [
                       [1, 2],
                       [3, 4],
                       [5, 6]
                       ];

        final polygon = new Polygon(latLngs);

        polygon.spliceLatLngs(1, 1, [7, 8]);

        expect(polygon._latlngs, equals([new LatLng(1, 2), new LatLng(7, 8), new LatLng(5, 6)]));
      });
    });
  });
}