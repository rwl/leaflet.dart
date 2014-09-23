part of leaflet.layer.vector.test;

circleTest() {
  group('Circle', () {
    group('getBounds', () {
      Circle circle;

      setUp(() {
        circle = new Circle(new LatLng(50, 30), 200);
      });

      test('returns bounds', () {
        final bounds = circle.getBounds();

        expect(bounds.getSouthWest() == new LatLng(49.998203369, 29.997204939), isTrue);
        expect(bounds.getNorthEast() == new LatLng(50.001796631, 30.002795061), isTrue);
      });
    });
  });
}