import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' as geom;
import 'package:leaflet/geometry/geometry.dart' show Transformation;

main() {
  group("Transformation", () {
    Transformation t;
    geom.Point p;

    setUp(() {
      t = new Transformation(1, 2, 3, 4);
      p = new geom.Point(10, 20);
    });

    group('#transform', () {
      test("performs a transformation", () {
        final p2 = t.transform(p, 2);
        expect(p2, equals(new geom.Point(24, 128)));
      });
      test('assumes a scale of 1 if not specified', () {
        final p2 = t.transform(p);
        expect(p2, equals(new geom.Point(12, 64)));
      });
    });

    group('#untransform', () {
      test("performs a reverse transformation", () {
        final p2 = t.transform(p, 2);
        final p3 = t.untransform(p2, 2);
        expect(p3, equals(p));
      });
      test('assumes a scale of 1 if not specified', () {
        final p2 = t.transform(p);
        expect(t.untransform(new geom.Point(12, 64)), equals(new geom.Point(10, 20)));
      });
    });
  });
}