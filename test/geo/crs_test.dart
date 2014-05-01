import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/geo/crs/crs.dart';
import 'package:leaflet/leaflet.dart' as L;


main() {
  useHtmlEnhancedConfiguration();

  group('CRS.EPSG3395', () {
    var crs = L.CRS.EPSG3395;

    group('#latLngToPoint', () {
      test('projects a center point', () {
        expect(crs.latLngToPoint(L.latLng(0, 0), 0)).near(new L.Point(128, 128), 0.01);
      });

      test('projects the northeast corner of the world', () {
        expect(crs.latLngToPoint(L.latLng(85.0840591556, 180), 0)).near(new L.Point(256, 0));
      });
    });

    group('#pointToLatLng', () {
      test('reprojects a center point', () {
        expect(crs.pointToLatLng(new L.Point(128, 128), 0)).nearLatLng(L.latLng(0, 0), 0.01);
      });

      test('reprojects the northeast corner of the world', () {
        expect(crs.pointToLatLng(new L.Point(256, 0), 0)).nearLatLng(L.latLng(85.0840591556, 180));
      });
    });
  });

  group('CRS.EPSG3857', () {
    var crs = L.CRS.EPSG3857;

    group('#latLngToPoint', () {
      test('projects a center point', () {
        expect(crs.latLngToPoint(L.latLng(0, 0), 0)).near(new L.Point(128, 128), 0.01);
      });

      test('projects the northeast corner of the world', () {
        expect(crs.latLngToPoint(L.latLng(85.0511287798, 180), 0)).near(new L.Point(256, 0));
      });
    });

    group('#pointToLatLng', () {
      test('reprojects a center point', () {
        expect(crs.pointToLatLng(new L.Point(128, 128), 0)).nearLatLng(L.latLng(0, 0), 0.01);
      });

      test('reprojects the northeast corner of the world', () {
        expect(crs.pointToLatLng(new L.Point(256, 0), 0)).nearLatLng(L.latLng(85.0511287798, 180));
      });
    });
  });

}
