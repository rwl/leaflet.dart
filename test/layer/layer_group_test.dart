import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('LayerGroup', () {
    group('#addLayer', () {
      test('adds a layer', () {
        var lg = L.layerGroup(),
            marker = L.marker([0, 0]);

        expect(lg.addLayer(marker)).to.eql(lg);

        expect(lg.hasLayer(marker)).to.be(true);
      });
    });
    group('#removeLayer', () {
      test('removes a layer', () {
        var lg = L.layerGroup(),
            marker = L.marker([0, 0]);

        lg.addLayer(marker);
        expect(lg.removeLayer(marker)).to.eql(lg);

        expect(lg.hasLayer(marker)).to.be(false);
      });
    });
    group('#clearLayers', () {
      test('removes all layers', () {
        var lg = L.layerGroup(),
            marker = L.marker([0, 0]);

        lg.addLayer(marker);
        expect(lg.clearLayers()).to.eql(lg);

        expect(lg.hasLayer(marker)).to.be(false);
      });
    });
    group('#getLayers', () {
      test('gets all layers', () {
        var lg = L.layerGroup(),
            marker = L.marker([0, 0]);

        lg.addLayer(marker);

        expect(lg.getLayers()).to.eql([marker]);
      });
    });
    group('#eachLayer', () {
      test('iterates over all layers', () {
        var lg = L.layerGroup(),
            marker = L.marker([0, 0]),
            ctx = { foo: 'bar' };

        lg.addLayer(marker);

        lg.eachLayer((layer) {
          expect(layer).to.eql(marker);
          expect(this).to.eql(ctx);
        }, ctx);
      });
    });
  });
}