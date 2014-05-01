import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('CircleMarker', () {
    group('#_radius', () {
      var map;
      setUp(() {
        map = L.map(document.createElement('div'));
        map.setView([0, 0], 1);
      });
      group('when a CircleMarker is added to the map ', () {
        group('with a radius set as an option', () {
          test('takes that radius', () {
            var marker = L.circleMarker([0, 0], { radius: 20 }).addTo(map);

            expect(marker._radius).to.be(20);
          });
        });

        group('and radius is set before adding it', () {
          test('takes that radius', () {
            var marker = L.circleMarker([0, 0], { radius: 20 });
            marker.setRadius(15);
            marker.addTo(map);
            expect(marker._radius).to.be(15);
          });
        });

        group('and radius is set after adding it', () {
          test('takes that radius', () {
            var marker = L.circleMarker([0, 0], { radius: 20 });
            marker.addTo(map);
            marker.setRadius(15);
            expect(marker._radius).to.be(15);
          });
        });

        group('and setStyle is used to change the radius after adding', () {
          test('takes the given radius', () {
            var marker = L.circleMarker([0, 0], { radius: 20 });
            marker.addTo(map);
            marker.setStyle({ radius: 15 });
            expect(marker._radius).to.be(15);
          });
        });
        group('and setStyle is used to change the radius before adding', () {
          test('takes the given radius', () {
            var marker = L.circleMarker([0, 0], { radius: 20 });
            marker.setStyle({ radius: 15 });
            marker.addTo(map);
            expect(marker._radius).to.be(15);
          });
        });
      });
    });
  });
}