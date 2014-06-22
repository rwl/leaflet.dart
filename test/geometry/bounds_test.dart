import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' as geom;
import 'package:leaflet/geometry/geometry.dart' show Bounds;


main() {
  group('Bounds', () {
    Bounds a, b, c;

    setUp(() {
      a = new Bounds.between(
          new geom.Point(14, 12),
          new geom.Point(30, 40));
      b = new Bounds([
                        new geom.Point(20, 12),
                        new geom.Point(14, 20),
                        new geom.Point(30, 40)
                        ]);
      c = new Bounds();
    });

    group('constructor', () {
      test('creates bounds with proper min & max on (Point, Point)', () {
        expect(a.min, equals(new geom.Point(14, 12)));
        expect(a.max, equals(new geom.Point(30, 40)));
      });
      test('creates bounds with proper min & max on (Point[])', () {
        expect(b.min, equals(new geom.Point(14, 12)));
        expect(b.max, equals(new geom.Point(30, 40)));
      });
    });

    group('#extend', () {
      test('extends the bounds to contain the given point', () {
        a.extend(new geom.Point(50, 20));
        expect(a.min, equals(new geom.Point(14, 12)));
        expect(a.max, equals(new geom.Point(50, 40)));

        b.extend(new geom.Point(25, 50));
        expect(b.min, equals(new geom.Point(14, 12)));
        expect(b.max, equals(new geom.Point(30, 50)));
      });
    });

    group('#getCenter', () {
      test('returns the center point', () {
        expect(a.getCenter(), equals(new geom.Point(22, 26)));
      });
    });

    group('#contains', () {
      test('contains other bounds or point', () {
        a.extend(new geom.Point(50, 10));
        expect(a.containsBounds(b), isTrue);
        expect(b.containsBounds(a), isFalse);
        expect(a.contains(new geom.Point(24, 25)), isTrue);
        expect(a.contains(new geom.Point(54, 65)), isFalse);
      });
    });

    group('#isValid', () {
      test('returns true if properly set up', () {
        expect(a.isValid(), isTrue);
      });
      test('returns false if is invalid', () {
        expect(c.isValid(), isFalse);
      });
      test('returns true if extended', () {
        c.extend(new geom.Point(0, 0));
        expect(c.isValid(), isTrue);
      });
    });

    group('#getSize', () {
      test('returns the size of the bounds as point', () {
        expect(a.getSize(), equals(new geom.Point(16, 28)));
      });
    });

    group('#intersects', () {
      test('returns true if bounds intersect', () {
        expect(a.intersects(b), isTrue);
        expect(a.intersects(new Bounds.between(new geom.Point(100, 100),
            new geom.Point(120, 120))), isFalse);
      });
    });

    group('L.bounds factory', () {
      test('creates bounds from array of number arrays', () {
        //final bounds = new Bounds.bounds([[14, 12], [30, 40]]);
        final bounds = new Bounds.bounds(new Bounds
            .between(new geom.Point(14, 12), new geom.Point(30, 40)));
        expect(bounds, equals(a));
      });
    });
  });
}