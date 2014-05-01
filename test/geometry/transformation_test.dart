import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group("Transformation", () {
    var t, p;

    beforeEach(() {
      t = new L.Transformation(1, 2, 3, 4);
      p = new L.Point(10, 20);
    });

    group('#transform', () {
      test("performs a transformation", () {
        var p2 = t.transform(p, 2);
        expect(p2).to.eql(new L.Point(24, 128));
      });
      test('assumes a scale of 1 if not specified', () {
        var p2 = t.transform(p);
        expect(p2).to.eql(new L.Point(12, 64));
      });
    });

    group('#untransform', () {
      test("performs a reverse transformation", () {
        var p2 = t.transform(p, 2);
        var p3 = t.untransform(p2, 2);
        expect(p3).to.eql(p);
      });
      test('assumes a scale of 1 if not specified', () {
        var p2 = t.transform(p);
        expect(t.untransform(new L.Point(12, 64))).to.eql(new L.Point(10, 20));
      });
    });
  });
}