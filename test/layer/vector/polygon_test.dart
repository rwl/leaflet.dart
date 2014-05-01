import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Polygon', () {

    var c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    var map = new L.Map(c);
    map.setView(new L.LatLng(55.8, 37.6), 6);

    group('#initialize', () {
      test('doesn\'t overwrite the given latlng array', () {
        var originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        var sourceLatLngs = originalLatLngs.slice();

        var polygon = new L.Polygon(sourceLatLngs);

        expect(sourceLatLngs).to.eql(originalLatLngs);
        expect(polygon._latlngs).to.not.eql(sourceLatLngs);
      });

      test('can be called with an empty array', () {
        var polygon = new L.Polygon([]);
        expect(polygon.getLatLngs()).to.eql([]);
      });

      test('can be initialized with holes', () {
        var originalLatLngs = [
                               [ //external rink
                                 [0, 10], [10, 10], [10, 0]
                                 ], [ //hole
                                      [2, 3], [2, 4], [3, 4]
                                      ]
                               ];

        var polygon = new L.Polygon(originalLatLngs);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs()).to.eql([L.latLng([0, 10]), L.latLng([10, 10]), L.latLng([10, 0])]);
      });
    });

    group('#setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        var originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        var sourceLatLngs = originalLatLngs.slice();

        var polygon = new L.Polygon(sourceLatLngs);

        polygon.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs).to.eql(originalLatLngs);
      });

      test('can be set external ring and holes', () {
        var latLngs = [
                       [ //external rink
                         [0, 10], [10, 10], [10, 0]
                         ], [ //hole
                              [2, 3], [2, 4], [3, 4]
                              ]
                       ];

        var polygon = new L.Polygon([]);
        polygon.setLatLngs(latLngs);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs()).to.eql([L.latLng([0, 10]), L.latLng([10, 10]), L.latLng([10, 0])]);
      });
    });

    group('#spliceLatLngs', () {
      test('splices the internal latLngs', () {
        var latLngs = [
                       [1, 2],
                       [3, 4],
                       [5, 6]
                       ];

        var polygon = new L.Polygon(latLngs);

        polygon.spliceLatLngs(1, 1, [7, 8]);

        expect(polygon._latlngs).to.eql([L.latLng([1, 2]), L.latLng([7, 8]), L.latLng([5, 6])]);
      });
    });
  });
}