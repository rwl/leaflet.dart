import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' show Bounds, Point2D;


main() {
  group('Bounds', () {
    Bounds a, b, c;

    setUp(() {
      a = new Bounds.between(
          new Point2D(14, 12),
          new Point2D(30, 40));
      b = new Bounds([
                        new Point2D(20, 12),
                        new Point2D(14, 20),
                        new Point2D(30, 40)
                        ]);
      c = new Bounds();
    });

    group('constructor', () {
      test('creates bounds with proper min & max on (Point, Point)', () {
        expect(a.min, equals(new Point2D(14, 12)));
        expect(a.max, equals(new Point2D(30, 40)));
      });
      test('creates bounds with proper min & max on (Point[])', () {
        expect(b.min, equals(new Point2D(14, 12)));
        expect(b.max, equals(new Point2D(30, 40)));
      });
    });

    group('#extend', () {
      test('extends the bounds to contain the given point', () {
        a.extend(new Point2D(50, 20));
        expect(a.min, equals(new Point2D(14, 12)));
        expect(a.max, equals(new Point2D(50, 40)));

        b.extend(new Point2D(25, 50));
        expect(b.min, equals(new Point2D(14, 12)));
        expect(b.max, equals(new Point2D(30, 50)));
      });
    });

    group('#getCenter', () {
      test('returns the center point', () {
        expect(a.getCenter(), equals(new Point2D(22, 26)));
      });
    });

    group('#contains', () {
      test('contains other bounds or point', () {
        a.extend(new Point2D(50, 10));
        expect(a.containsBounds(b), isTrue);
        expect(b.containsBounds(a), isFalse);
        expect(a.contains(new Point2D(24, 25)), isTrue);
        expect(a.contains(new Point2D(54, 65)), isFalse);
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
        c.extend(new Point2D(0, 0));
        expect(c.isValid(), isTrue);
      });
    });

    group('#getSize', () {
      test('returns the size of the bounds as point', () {
        expect(a.getSize(), equals(new Point2D(16, 28)));
      });
    });

    group('#intersects', () {
      test('returns true if bounds intersect', () {
        expect(a.intersects(b), isTrue);
        expect(a.intersects(new Bounds.between(new Point2D(100, 100),
            new Point2D(120, 120))), isFalse);
      });
    });

    group('L.bounds factory', () {
      test('creates bounds from array of number arrays', () {
        //final bounds = new Bounds.bounds([[14, 12], [30, 40]]);
        final bounds = new Bounds.bounds(new Bounds
            .between(new Point2D(14, 12), new Point2D(30, 40)));
        expect(bounds, equals(a));
      });
    });
  });
}