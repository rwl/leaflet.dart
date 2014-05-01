import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Point', () {

    group('constructor', () {

      test('creates a point with the given x and y', () {
        var p = new L.Point(1.5, 2.5);
        expect(p.x).to.eql(1.5);
        expect(p.y).to.eql(2.5);
      });

      test('rounds the given x and y if the third argument is true', () {
        var p = new L.Point(1.3, 2.7, true);
        expect(p.x).to.eql(1);
        expect(p.y).to.eql(3);
      });
    });

    group('#subtract', () {
      test('subtracts the given point from this one', () {
        var a = new L.Point(50, 30),
            b = new L.Point(20, 10);
        expect(a.subtract(b)).to.eql(new L.Point(30, 20));
      });
    });

    group('#add', () {
      test('adds given point to this one', () {
        expect(new L.Point(50, 30).add(new L.Point(20, 10))).to.eql(new L.Point(70, 40));
      });
    });

    group('#divideBy', () {
      test('divides this point by the given amount', () {
        expect(new L.Point(50, 30).divideBy(5)).to.eql(new L.Point(10, 6));
      });
    });

    group('#multiplyBy', () {
      test('multiplies this point by the given amount', () {
        expect(new L.Point(50, 30).multiplyBy(2)).to.eql(new L.Point(100, 60));
      });
    });

    group('#floor', () {
      test('returns a new point with floored coordinates', () {
        expect(new L.Point(50.56, 30.123).floor()).to.eql(new L.Point(50, 30));
      });
    });

    group('#distanceTo', () {
      test('calculates distance between two points', () {
        var p1 = new L.Point(0, 30);
        var p2 = new L.Point(40, 0);
        expect(p1.distanceTo(p2)).to.eql(50.0);
      });
    });

    group('#equals', () {
      test('returns true if points are equal', () {
        var p1 = new L.Point(20.4, 50.12);
        var p2 = new L.Point(20.4, 50.12);
        var p3 = new L.Point(20.5, 50.13);

        expect(p1.equals(p2)).to.be(true);
        expect(p1.equals(p3)).to.be(false);
      });
    });

    group('#contains', () {
      test('returns true if the point is bigger in absolute dimensions than the passed one', () {
        var p1 = new L.Point(50, 30),
            p2 = new L.Point(-40, 20),
            p3 = new L.Point(60, -20),
            p4 = new L.Point(-40, -40);

        expect(p1.contains(p2)).to.be(true);
        expect(p1.contains(p3)).to.be(false);
        expect(p1.contains(p4)).to.be(false);
      });
    });

    group('#toString', () {
      test('formats a string out of point coordinates', () {
        expect(new L.Point(50, 30) + '').to.eql('Point(50, 30)');
      });
    });

    group('L.point factory', () {
      test('leaves L.Point instances as is', () {
        var p = new L.Point(50, 30);
        expect(L.point(p)).to.be(p);
      });
      test('creates a point out of three arguments', () {
        expect(L.point(50.1, 30.1, true)).to.eql(new L.Point(50, 30));
      });
      test('creates a point from an array of coordinates', () {
        expect(L.point([50, 30])).to.eql(new L.Point(50, 30));
      });
      test('does not fail on invalid arguments', () {
        expect(L.point(undefined)).to.be(undefined);
        expect(L.point(null)).to.be(null);
      });
    });
  });
}