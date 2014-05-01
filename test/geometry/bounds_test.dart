import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Bounds', () {
    var a, b, c;

    beforeEach(() {
      a = new L.Bounds(
          new L.Point(14, 12),
          new L.Point(30, 40));
      b = new L.Bounds([
                        new L.Point(20, 12),
                        new L.Point(14, 20),
                        new L.Point(30, 40)
                        ]);
      c = new L.Bounds();
    });

    group('constructor', () {
      test('creates bounds with proper min & max on (Point, Point)', () {
        expect(a.min).to.eql(new L.Point(14, 12));
        expect(a.max).to.eql(new L.Point(30, 40));
      });
      test('creates bounds with proper min & max on (Point[])', () {
        expect(b.min).to.eql(new L.Point(14, 12));
        expect(b.max).to.eql(new L.Point(30, 40));
      });
    });

    group('#extend', () {
      test('extends the bounds to contain the given point', () {
        a.extend(new L.Point(50, 20));
        expect(a.min).to.eql(new L.Point(14, 12));
        expect(a.max).to.eql(new L.Point(50, 40));

        b.extend(new L.Point(25, 50));
        expect(b.min).to.eql(new L.Point(14, 12));
        expect(b.max).to.eql(new L.Point(30, 50));
      });
    });

    group('#getCenter', () {
      test('returns the center point', () {
        expect(a.getCenter()).to.eql(new L.Point(22, 26));
      });
    });

    group('#contains', () {
      test('contains other bounds or point', () {
        a.extend(new L.Point(50, 10));
        expect(a.contains(b)).to.be.ok();
        expect(b.contains(a)).to.not.be.ok();
        expect(a.contains(new L.Point(24, 25))).to.be.ok();
        expect(a.contains(new L.Point(54, 65))).to.not.be.ok();
      });
    });

    group('#isValid', () {
      test('returns true if properly set up', () {
        expect(a.isValid()).to.be.ok();
      });
      test('returns false if is invalid', () {
        expect(c.isValid()).to.not.be.ok();
      });
      test('returns true if extended', () {
        c.extend([0, 0]);
        expect(c.isValid()).to.be.ok();
      });
    });

    group('#getSize', () {
      test('returns the size of the bounds as point', () {
        expect(a.getSize()).to.eql(new L.Point(16, 28));
      });
    });

    group('#intersects', () {
      test('returns true if bounds intersect', () {
        expect(a.intersects(b)).to.be(true);
        expect(a.intersects(new L.Bounds(new L.Point(100, 100), new L.Point(120, 120)))).to.eql(false);
      });
    });

    group('L.bounds factory', () {
      test('creates bounds from array of number arrays', () {
        var bounds = L.bounds([[14, 12], [30, 40]]);
        expect(bounds).to.eql(a);
      });
    });
  });
}