import 'package:unittest/unittest.dart';
import 'package:leaflet/geometry/geometry.dart' as geom;
import 'package:leaflet/geometry/geometry.dart' show Bounds;

main() {
  group('PolyUtil', () {

    group('#clipPolygon', () {
      test('clips polygon by bounds', () {
        final bounds = new Bounds.between(new geom.Point(0, 0), new geom.Point(10, 10));

        final points = [
                      new geom.Point(5, 5),
                      new geom.Point(15, 10),
                      new geom.Point(10, 15)
                      ];

        final clipped = geom.clipPolygon(points, bounds);

        for (int i = 0, len = clipped.length; i < len; i++) {
          delete(clipped[i]._code);
        }

        expect(clipped, equals([
                                new geom.Point(7.5, 10),
                                new geom.Point(5, 5),
                                new geom.Point(10, 7.5),
                                new geom.Point(10, 10)
                                ]));
      });
    });
  });
}