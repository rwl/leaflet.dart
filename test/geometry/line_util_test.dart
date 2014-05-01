import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('LineUtil', () {

    group('#clipSegment', () {

      var bounds;

      beforeEach(() {
        bounds = L.bounds([5, 0], [15, 10]);
      });

      test('clips a segment by bounds', () {
        var a = new L.Point(0, 0);
        var b = new L.Point(15, 15);

        var segment = L.LineUtil.clipSegment(a, b, bounds);

        expect(segment[0]).to.eql(new L.Point(5, 5));
        expect(segment[1]).to.eql(new L.Point(10, 10));

        var c = new L.Point(5, -5);
        var d = new L.Point(20, 10);

        var segment2 = L.LineUtil.clipSegment(c, d, bounds);

        expect(segment2[0]).to.eql(new L.Point(10, 0));
        expect(segment2[1]).to.eql(new L.Point(15, 5));
      });

      test('uses last bit code and reject segments out of bounds', () {
        var a = new L.Point(15, 15);
        var b = new L.Point(25, 20);
        var segment = L.LineUtil.clipSegment(a, b, bounds, true);

        expect(segment).to.be(false);
      });
    });

    group('#pointToSegmentDistance & #closestPointOnSegment', () {

      var p1 = new L.Point(0, 10);
      var p2 = new L.Point(10, 0);
      var p = new L.Point(0, 0);

      test('calculates distance from point to segment', () {
        expect(L.LineUtil.pointToSegmentDistance(p, p1, p2)).to.eql(Math.sqrt(200) / 2);
      });

      test('calculates point closest to segment', () {
        expect(L.LineUtil.closestPointOnSegment(p, p1, p2)).to.eql(new L.Point(5, 5));
      });
    });

    group('#simplify', () {
      test('simplifies polylines according to tolerance', () {
        var points = [
                      new L.Point(0, 0),
                      new L.Point(0.01, 0),
                      new L.Point(0.5, 0.01),
                      new L.Point(0.7, 0),
                      new L.Point(1, 0),
                      new L.Point(1.999, 0.999),
                      new L.Point(2, 1)
                      ];

        var simplified = L.LineUtil.simplify(points, 0.1);

        expect(simplified).to.eql([
                                   new L.Point(0, 0),
                                   new L.Point(1, 0),
                                   new L.Point(2, 1)
                                   ]);
      });
    });

  });
}