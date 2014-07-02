import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/layer/layer.dart' show LayerGroup;
import 'package:leaflet/layer/marker/marker.dart' show Marker;
import 'package:leaflet/geo/geo.dart' show LatLng;

main() {
  useHtmlEnhancedConfiguration();

  group('LayerGroup', () {
    group('#addLayer', () {
      test('adds a layer', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.layers.add(marker);

        expect(lg.layers.contains(marker), isTrue);
      });
    });
    group('#removeLayer', () {
      test('removes a layer', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.layers.add(marker);
        lg.layers.remove(marker);

        expect(lg.layers.contains(marker), isFalse);
      });
    });
    group('#clearLayers', () {
      test('removes all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.layers.add(marker);
        lg.layers.clear();

        expect(lg.layers.contains(marker), isFalse);
      });
    });
    group('#getLayers', () {
      test('gets all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.layers.add(marker);

        expect(lg.layers, equals([marker]));
      });
    });
    group('#eachLayer', () {
      test('iterates over all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0)),
            ctx = { 'foo': 'bar' };

        lg.layers.add(marker);

        lg.layers.forEach((layer) {
          expect(layer, equals(marker));
          //expect(this).to.eql(ctx);
        });
      });
    });
  });
}