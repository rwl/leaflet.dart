import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/geo/crs/crs.dart' show EPSG3395, EPSG3857;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/geometry/geometry.dart' show Point2D;
import 'package:leaflet/test/test.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('CRS.EPSG3395', () {
    final crs = EPSG3395;

    group('#latLngToPoint', () {
      test('projects a center point', () {
        expect(crs.latLngToPoint(new LatLng(0, 0), 0), near(new Point2D(128, 128), 0.01));
      });

      test('projects the northeast corner of the world', () {
        expect(crs.latLngToPoint(new LatLng(85.0840591556, 180), 0), near(new Point2D(256, 0)));
      });
    });

    group('#pointToLatLng', () {
      test('reprojects a center point', () {
        expect(crs.pointToLatLng(new Point2D(128, 128), 0), nearLatLng(new LatLng(0, 0), 0.01));
      });

      test('reprojects the northeast corner of the world', () {
        expect(crs.pointToLatLng(new Point2D(256, 0), 0), nearLatLng(new LatLng(85.0840591556, 180)));
      });
    });
  });

  group('CRS.EPSG3857', () {
    final crs = EPSG3857;

    group('#latLngToPoint', () {
      test('projects a center point', () {
        expect(crs.latLngToPoint(new LatLng(0, 0), 0), near(new Point2D(128, 128), 0.01));
      });

      test('projects the northeast corner of the world', () {
        expect(crs.latLngToPoint(new LatLng(85.0511287798, 180), 0), near(new Point2D(256, 0)));
      });
    });

    group('#pointToLatLng', () {
      test('reprojects a center point', () {
        expect(crs.pointToLatLng(new Point2D(128, 128), 0), nearLatLng(new LatLng(0, 0), 0.01));
      });

      test('reprojects the northeast corner of the world', () {
        expect(crs.pointToLatLng(new Point2D(256, 0), 0), nearLatLng(new LatLng(85.0511287798, 180)));
      });
    });
  });

}
