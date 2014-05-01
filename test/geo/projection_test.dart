import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Projection.Mercator', () {
    var p = L.Projection.Mercator;

    group('#project', () {
      test('projects a center point', () {
        //edge cases
        expect(p.project(new L.LatLng(0, 0))).near(new L.Point(0, 0));
      });

      test('projects the northeast corner of the world', () {
        expect(p.project(new L.LatLng(90, 180))).near(new L.Point(20037508, 20037508));
      });

      test('projects the southwest corner of the world', () {
        expect(p.project(new L.LatLng(-90, -180))).near(new L.Point(-20037508, -20037508));
      });

      test('projects other points', () {
        expect(p.project(new L.LatLng(50, 30))).near(new L.Point(3339584, 6413524));

        // from https://github.com/Leaflet/Leaflet/issues/1578
        expect(p.project(new L.LatLng(51.9371170300465, 80.11230468750001)))
        .near(new L.Point(8918060.964088084, 6755099.410887127));
      });
    });

    group('#unproject', () {
      var pr = (point) {
        return p.project(p.unproject(point));
      };

      test('unprojects a center point', () {
        expect(pr(new L.Point(0, 0))).near(new L.Point(0, 0));
      });

      test('unprojects pi points', () {
        expect(pr(new L.Point(-Math.PI, Math.PI))).near(new L.Point(-Math.PI, Math.PI));
        expect(pr(new L.Point(-Math.PI, -Math.PI))).near(new L.Point(-Math.PI, -Math.PI));

        expect(pr(new L.Point(0.523598775598, 1.010683188683))).near(new L.Point(0.523598775598, 1.010683188683));
      });

      test('unprojects other points', () {
        // from https://github.com/Leaflet/Leaflet/issues/1578
        expect(pr(new L.Point(8918060.964088084, 6755099.410887127)));
      });
    });
  });
}