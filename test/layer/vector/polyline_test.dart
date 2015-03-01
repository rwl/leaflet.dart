part of leaflet.layer.vector.test;

polylineTest() {
  group('Polyline', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    final map = new LeafletMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('initialize', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4),
        ];
        final sourceLatLngs = new List.from(originalLatLngs);

        final polyline = new Polyline(sourceLatLngs);

        sourceLatLngs.removeLast();

        expect(polyline.latlngs, equals(originalLatLngs));
        expect(originalLatLngs, isNot(equals(sourceLatLngs)));
      });
    });

    group('setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4)
        ];
        final sourceLatLngs = new List.from(originalLatLngs);

        final polyline = new Polyline(sourceLatLngs);

        polyline.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
      });
    });

    group('spliceLatLngs', () {
      test('splices the internal latLngs', () {
        final latLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4),
          new LatLng(5, 6)
        ];

        final polyline = new Polyline(latLngs);

        polyline.spliceLatLngs(1, 1, [new LatLng(7, 8)]);

        expect(polyline.latlngs, equals([
          new LatLng(1, 2), new LatLng(7, 8), new LatLng(5, 6)
        ]));
      });
    });
  });
}
