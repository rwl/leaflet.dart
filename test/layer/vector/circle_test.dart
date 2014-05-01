import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Circle', () {
    group('#getBounds', () {

      var circle;

      setUp(() {
        circle = L.circle([50, 30], 200);
      });

      test('returns bounds', () {
        var bounds = circle.getBounds();

        expect(bounds.getSouthWest().equals([49.998203369, 29.997204939])).to.be.ok();
        expect(bounds.getNorthEast().equals([50.001796631, 30.002795061])).to.be.ok();
      });
    });
  });
}