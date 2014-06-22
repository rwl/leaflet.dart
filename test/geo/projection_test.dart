import 'dart:math' as Math;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/geo/projection/projection.dart' show Mercator;
import 'package:leaflet/geometry/geometry.dart' as geom;

main() {
  useHtmlEnhancedConfiguration();

  group('Projection.Mercator', () {
    final p = Mercator;

    group('#project', () {
      test('projects a center point', () {
        //edge cases
        expect(p.project(new LatLng(0, 0)), near(new geom.Point(0, 0)));
      });

      test('projects the northeast corner of the world', () {
        expect(p.project(new LatLng(90, 180)), near(new geom.Point(20037508, 20037508)));
      });

      test('projects the southwest corner of the world', () {
        expect(p.project(new LatLng(-90, -180)), near(new geom.Point(-20037508, -20037508)));
      });

      test('projects other points', () {
        expect(p.project(new LatLng(50, 30)), near(new geom.Point(3339584, 6413524)));

        // from https://github.com/Leaflet/Leaflet/issues/1578
        expect(p.project(new LatLng(51.9371170300465, 80.11230468750001)),
            near(new geom.Point(8918060.964088084, 6755099.410887127)));
      });
    });

    group('#unproject', () {
      final pr = (geom.Point point) {
        return p.project(p.unproject(point));
      };

      test('unprojects a center point', () {
        expect(pr(new geom.Point(0, 0)), near(new geom.Point(0, 0)));
      });

      test('unprojects pi points', () {
        expect(pr(new geom.Point(-Math.PI, Math.PI)), near(new geom.Point(-Math.PI, Math.PI)));
        expect(pr(new geom.Point(-Math.PI, -Math.PI)), near(new geom.Point(-Math.PI, -Math.PI)));

        expect(pr(new geom.Point(0.523598775598, 1.010683188683)), near(new geom.Point(0.523598775598, 1.010683188683)));
      });

      test('unprojects other points', () {
        // from https://github.com/Leaflet/Leaflet/issues/1578
        expect(pr(new geom.Point(8918060.964088084, 6755099.410887127)), isNotNull);
      });
    });
  });
}