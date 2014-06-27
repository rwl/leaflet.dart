import 'dart:math' as Math;
import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' show Bounds, Point2D, simplify, clipSegment, pointToSegmentDistance, closestPointOnSegment;

main() {
  group('LineUtil', () {

    group('#clipSegment', () {

      Bounds bounds;

      setUp(() {
        bounds = new Bounds.between(new Point2D(5, 0), new Point2D(15, 10));
      });

      test('clips a segment by bounds', () {
        final a = new Point2D(0, 0);
        final b = new Point2D(15, 15);

        final segment = clipSegment(a, b, bounds);

        expect(segment[0], equals(new Point2D(5, 5)));
        expect(segment[1], equals(new Point2D(10, 10)));

        final c = new Point2D(5, -5);
        final d = new Point2D(20, 10);

        final segment2 = clipSegment(c, d, bounds);

        expect(segment2[0], equals(new Point2D(10, 0)));
        expect(segment2[1], equals(new Point2D(15, 5)));
      });

      test('uses last bit code and reject segments out of bounds', () {
        final a = new Point2D(15, 15);
        final b = new Point2D(25, 20);
        final segment = clipSegment(a, b, bounds, true);

        expect(segment, isFalse);
      });
    });

    group('#pointToSegmentDistance & #closestPointOnSegment', () {

      final p1 = new Point2D(0, 10);
      final p2 = new Point2D(10, 0);
      final p = new Point2D(0, 0);

      test('calculates distance from point to segment', () {
        expect(pointToSegmentDistance(p, p1, p2), equals(Math.sqrt(200) / 2));
      });

      test('calculates point closest to segment', () {
        expect(closestPointOnSegment(p, p1, p2), equals(new Point2D(5, 5)));
      });
    });

    group('#simplify', () {
      test('simplifies polylines according to tolerance', () {
        final points = [
                      new Point2D(0, 0),
                      new Point2D(0.01, 0),
                      new Point2D(0.5, 0.01),
                      new Point2D(0.7, 0),
                      new Point2D(1, 0),
                      new Point2D(1.999, 0.999),
                      new Point2D(2, 1)
                      ];

        final simplified = simplify(points, 0.1);

        expect(simplified, equals([
                                   new Point2D(0, 0),
                                   new Point2D(1, 0),
                                   new Point2D(2, 1)
                                   ]));
      });
    });

  });
}