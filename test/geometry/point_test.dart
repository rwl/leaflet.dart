import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' show Point2D;

main() {
  group('Point', () {

    group('constructor', () {

      test('creates a point with the given x and y', () {
        final p = new Point2D(1.5, 2.5);
        expect(p.x, equals(1.5));
        expect(p.y, equals(2.5));
      });

      test('rounds the given x and y if the third argument is true', () {
        final p = new Point2D(1.3, 2.7, true);
        expect(p.x, equals(1));
        expect(p.y, equals(3));
      });
    });

    group('#subtract', () {
      test('subtracts the given point from this one', () {
        var a = new Point2D(50, 30),
            b = new Point2D(20, 10);
        expect(a - b, equals(new Point2D(30, 20)));
      });
    });

    group('#add', () {
      test('adds given point to this one', () {
        expect(new Point2D(50, 30) + new Point2D(20, 10), equals(new Point2D(70, 40)));
      });
    });

    group('#divideBy', () {
      test('divides this point by the given amount', () {
        expect(new Point2D(50, 30) / 5, equals(new Point2D(10, 6)));
      });
    });

    group('#multiplyBy', () {
      test('multiplies this point by the given amount', () {
        expect(new Point2D(50, 30) * 2, equals(new Point2D(100, 60)));
      });
    });

    group('#floor', () {
      test('returns a new point with floored coordinates', () {
        expect(new Point2D(50.56, 30.123).floored(), equals(new Point2D(50, 30)));
      });
    });

    group('#distanceTo', () {
      test('calculates distance between two points', () {
        final p1 = new Point2D(0, 30);
        final p2 = new Point2D(40, 0);
        expect(p1.distanceTo(p2), equals(50.0));
      });
    });

    group('#equals', () {
      test('returns true if points are equal', () {
        final p1 = new Point2D(20.4, 50.12);
        final p2 = new Point2D(20.4, 50.12);
        final p3 = new Point2D(20.5, 50.13);

        expect(p1 == p2, isTrue);
        expect(p1 == p3, isFalse);
      });
    });

    group('#contains', () {
      test('returns true if the point is bigger in absolute dimensions than the passed one', () {
        final p1 = new Point2D(50, 30),
            p2 = new Point2D(-40, 20),
            p3 = new Point2D(60, -20),
            p4 = new Point2D(-40, -40);

        expect(p1.contains(p2), isTrue);
        expect(p1.contains(p3), isFalse);
        expect(p1.contains(p4), isFalse);
      });
    });

    group('#toString', () {
      test('formats a string out of point coordinates', () {
        expect(new Point2D(50, 30).toString(), equals('Point(50, 30)'));
      });
    });

    group('L.point factory', () {
      test('leaves Point2D instances as is', () {
        final p = new Point2D(50, 30);
        expect(new Point2D.point(p), equals(p));
      });
      test('creates a point out of three arguments', () {
        expect(new Point2D(50.1, 30.1, true), equals(new Point2D(50, 30)));
      });
      test('creates a point from an array of coordinates', () {
        expect(new Point2D.point([50, 30]), equals(new Point2D(50, 30)));
      });
      test('does not fail on invalid arguments', () {
        //expect(L.point(undefined)).to.be(undefined);
        expect(new Point2D.point(null), isNull);
      });
    });
  });
}