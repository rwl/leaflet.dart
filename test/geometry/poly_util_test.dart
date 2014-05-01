import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('PolyUtil', () {

    group('#clipPolygon', () {
      test('clips polygon by bounds', () {
        var bounds = L.bounds([0, 0], [10, 10]);

        var points = [
                      new L.Point(5, 5),
                      new L.Point(15, 10),
                      new L.Point(10, 15)
                      ];

        var clipped = L.PolyUtil.clipPolygon(points, bounds);

        for (var i = 0, len = clipped.length; i < len; i++) {
          delete(clipped[i]._code);
        }

        expect(clipped).to.eql([
                                new L.Point(7.5, 10),
                                new L.Point(5, 5),
                                new L.Point(10, 7.5),
                                new L.Point(10, 10)
                                ]);
      });
    });
  });
}