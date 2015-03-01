part of leaflet.layer.vector.test;

polylineGeometryTest() {
  group('PolylineGeometry', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    final map = new LeafletMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('distanceTo', () {
      test('calculates distances to points', () {
        final p1 = map.latLngToLayerPoint(new LatLng(55.8, 37.6));
        final p2 = map.latLngToLayerPoint(new LatLng(57.123076977278, 44.861962891635));
        final latlngs = [
          [56.485503424111, 35.545556640339],
          [55.972522915346, 36.116845702918],
          [55.502459116923, 34.930322265253],
          [55.31534617509, 38.973291015816]
        ].map((ll) {
          return new LatLng(ll[0], ll[1]);
        }).toList();
        final polyline = new Polyline([], new PolylineOptions()
          ..noClip = true);
        map.addLayer(polyline);

        expect(polyline.closestLayerPoint(p1), isNull);

        polyline.setLatLngs(latlngs);
        var distance = [0];
        final point = polyline.closestLayerPoint(p1, distance);
        expect(point, isNotNull);
        expect(distance[0], isNot(equals(double.INFINITY)));
        expect(distance[0], isNotNaN);

        var distance2 = [0];
        final point2 = polyline.closestLayerPoint(p2, distance2);

        expect(distance[0], lessThan(distance2[0]));
      });
    });
  });
}
