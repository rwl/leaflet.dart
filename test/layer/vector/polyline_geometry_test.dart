import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show BaseMap;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/vector/vector.dart' show Polyline;


main() {
  useHtmlEnhancedConfiguration();

  group('PolylineGeometry', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    final map = new BaseMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('#distanceTo', () {
      test('calculates distances to points', () {
        final p1 = map.latLngToLayerPoint(new LatLng(55.8, 37.6));
        final p2 = map.latLngToLayerPoint(new LatLng(57.123076977278, 44.861962891635));
        final latlngs = [[56.485503424111, 35.545556640339], [55.972522915346, 36.116845702918], [55.502459116923, 34.930322265253], [55.31534617509, 38.973291015816]]
        .map((ll) {
          return new LatLng(ll[0], ll[1]);
        });
        final polyline = new Polyline([], {
          'noClip': true
        });
        map.addLayer(polyline);

        expect(polyline.closestLayerPoint(p1), isNull);

        polyline.setLatLngs(latlngs);
        final point = polyline.closestLayerPoint(p1);
        expect(point, isNotNull);
        expect(point.distance, isNot(equals(double.INFINITY)));
        expect(point.distance, isNot(equals(double.NAN)));

        final point2 = polyline.closestLayerPoint(p2);

        expect(point.distance, lessThan(point2.distance));
      });
    });
  });
}
