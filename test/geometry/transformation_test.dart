part of leaflet.geometry.test;

transformationTest() {
  group("Transformation", () {
    Transformation t;
    Point2D p;

    setUp(() {
      t = new Transformation(1, 2, 3, 4);
      p = new Point2D(10, 20);
    });

    group('transform', () {
      test("performs a transformation", () {
        final p2 = t.transform(p, 2);
        expect(p2, equals(new Point2D(24, 128)));
      });
      test('assumes a scale of 1 if not specified', () {
        final p2 = t.transform(p);
        expect(p2, equals(new Point2D(12, 64)));
      });
    });

    group('untransform', () {
      test("performs a reverse transformation", () {
        final p2 = t.transform(p, 2);
        final p3 = t.untransform(p2, 2);
        expect(p3, equals(p));
      });
      test('assumes a scale of 1 if not specified', () {
        final p2 = t.transform(p);
        expect(t.untransform(new Point2D(12, 64)), equals(new Point2D(10, 20)));
      });
    });
  });
}