part of leaflet.layer.vector.test;

circleMarkerTest() {
  group('CircleMarker', () {
    group('#_radius', () {
      LeafletMap map;
      setUp(() {
        map = new LeafletMap(document.createElement('div'));
        map.setView(new LatLng(0, 0), 1);
      });
      group('when a CircleMarker is added to the map ', () {
        group('with a radius set as an option', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), new CircleMarkerOptions()
              ..radius = 20)..addTo(map);

            expect(marker.getRadius(), equals(20));
          });
        });

        group('and radius is set before adding it', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), new CircleMarkerOptions()
            ..radius = 20);
            marker.setRadius(15);
            marker.addTo(map);
            expect(marker.getRadius(), equals(15));
          });
        });

        group('and radius is set after adding it', () {
          test('takes that radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), new CircleMarkerOptions()
            ..radius = 20);
            marker.addTo(map);
            marker.setRadius(15);
            expect(marker.getRadius(), equals(15));
          });
        });

        group('and setStyle is used to change the radius after adding', () {
          test('takes the given radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), new CircleMarkerOptions()
            ..radius = 20);
            marker.addTo(map);
            marker.setStyle(new CircleMarkerOptions()..radius = 15);
            expect(marker.getRadius(), equals(15));
          });
        });
        group('and setStyle is used to change the radius before adding', () {
          test('takes the given radius', () {
            final marker = new CircleMarker(new LatLng(0, 0), new CircleMarkerOptions()
            ..radius = 20);
            marker.setStyle(new CircleMarkerOptions()..radius = 15);
            marker.addTo(map);
            expect(marker.getRadius(), equals(15));
          });
        });
      });
    });
  });
}
