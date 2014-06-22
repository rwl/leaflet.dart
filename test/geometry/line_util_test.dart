import 'dart:math' as Math;
import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' as geom;
import 'package:leaflet/geometry/geometry.dart' show Bounds;

main() {
  group('LineUtil', () {

    group('#clipSegment', () {

      Bounds bounds;

      setUp(() {
        bounds = new Bounds.between(new geom.Point(5, 0), new geom.Point(15, 10));
      });

      test('clips a segment by bounds', () {
        final a = new geom.Point(0, 0);
        final b = new geom.Point(15, 15);

        final segment = geom.clipSegment(a, b, bounds);

        expect(segment[0], equals(new geom.Point(5, 5)));
        expect(segment[1], equals(new geom.Point(10, 10)));

        final c = new geom.Point(5, -5);
        final d = new geom.Point(20, 10);

        final segment2 = geom.clipSegment(c, d, bounds);

        expect(segment2[0], equals(new geom.Point(10, 0)));
        expect(segment2[1], equals(new geom.Point(15, 5)));
      });

      test('uses last bit code and reject segments out of bounds', () {
        final a = new geom.Point(15, 15);
        final b = new geom.Point(25, 20);
        final segment = geom.clipSegment(a, b, bounds, true);

        expect(segment, isFalse);
      });
    });

    group('#pointToSegmentDistance & #closestPointOnSegment', () {

      final p1 = new geom.Point(0, 10);
      final p2 = new geom.Point(10, 0);
      final p = new geom.Point(0, 0);

      test('calculates distance from point to segment', () {
        expect(geom.pointToSegmentDistance(p, p1, p2), equals(Math.sqrt(200) / 2));
      });

      test('calculates point closest to segment', () {
        expect(geom.closestPointOnSegment(p, p1, p2), equals(new geom.Point(5, 5)));
      });
    });

    group('#simplify', () {
      test('simplifies polylines according to tolerance', () {
        final points = [
                      new geom.Point(0, 0),
                      new geom.Point(0.01, 0),
                      new geom.Point(0.5, 0.01),
                      new geom.Point(0.7, 0),
                      new geom.Point(1, 0),
                      new geom.Point(1.999, 0.999),
                      new geom.Point(2, 1)
                      ];

        final simplified = geom.simplify(points, 0.1);

        expect(simplified, equals([
                                   new geom.Point(0, 0),
                                   new geom.Point(1, 0),
                                   new geom.Point(2, 1)
                                   ]));
      });
    });

  });
}