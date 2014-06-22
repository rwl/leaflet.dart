import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show BaseMap;
import 'package:leaflet/layer/vector/vector.dart' show CircleMarker;
import 'package:leaflet/geo/geo.dart' show LatLng;

main() {
  useHtmlEnhancedConfiguration();

  group('CircleMarker', () {
    group('#_radius', () {
      BaseMap map;
      setUp(() {
        map = new BaseMap(document.createElement('div'));
        map.setView([0, 0], 1);
      });
      group('when a CircleMarker is added to the map ', () {
        group('with a radius set as an option', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), { 'radius': 20 })..addTo(map);

            expect(marker._radius, equals(20));
          });
        });

        group('and radius is set before adding it', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), { 'radius': 20 });
            marker.setRadius(15);
            marker.addTo(map);
            expect(marker._radius, equals(15));
          });
        });

        group('and radius is set after adding it', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), { 'radius': 20 });
            marker.addTo(map);
            marker.setRadius(15);
            expect(marker._radius).to.be(15);
          });
        });

        group('and setStyle is used to change the radius after adding', () {
          test('takes the given radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), { 'radius': 20 });
            marker.addTo(map);
            marker.setStyle({ 'radius': 15 });
            expect(marker._radius, equals(15));
          });
        });
        group('and setStyle is used to change the radius before adding', () {
          test('takes the given radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), { 'radius': 20 });
            marker.setStyle({ radius: 15 });
            marker.addTo(map);
            expect(marker._radius, equals(15));
          });
        });
      });
    });
  });
}