import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Polyline', () {

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

        var polyline = new L.Polyline(sourceLatLngs);

        expect(sourceLatLngs).to.eql(originalLatLngs);
        expect(polyline._latlngs).to.not.eql(sourceLatLngs);
      });
    });

    group('#setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        var originalLatLngs = [
                               [1, 2],
                               [3, 4]
                               ];
        var sourceLatLngs = originalLatLngs.slice();

        var polyline = new L.Polyline(sourceLatLngs);

        polyline.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs).to.eql(originalLatLngs);
      });
    });

    group('#spliceLatLngs', () {
      test('splices the internal latLngs', () {
        var latLngs = [
                       [1, 2],
                       [3, 4],
                       [5, 6]
                       ];

        var polyline = new L.Polyline(latLngs);

        polyline.spliceLatLngs(1, 1, [7, 8]);

        expect(polyline._latlngs).to.eql([L.latLng([1, 2]), L.latLng([7, 8]), L.latLng([5, 6])]);
      });
    });
  });
}
