import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' show Bounds, clipPolygon, Point2D;

main() {
  group('PolyUtil', () {

    group('#clipPolygon', () {
      test('clips polygon by bounds', () {
        final bounds = new Bounds.between(new Point2D(0, 0), new Point2D(10, 10));

        final points = [
                      new Point2D(5, 5),
                      new Point2D(15, 10),
                      new Point2D(10, 15)
                      ];

        final clipped = clipPolygon(points, bounds);

        for (int i = 0, len = clipped.length; i < len; i++) {
          delete(clipped[i]._code);
        }

        expect(clipped, equals([
                                new Point2D(7.5, 10),
                                new Point2D(5, 5),
                                new Point2D(10, 7.5),
                                new Point2D(10, 10)
                                ]));
      });
    });
  });
}