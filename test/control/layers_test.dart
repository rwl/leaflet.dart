import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' as L;


main() {
  useHtmlEnhancedConfiguration();

  var map;

  setUp(() {
    map = new Map(document.createElement('div'));
  });

  describe('baselayerchange event', () {
    test('is fired on input that changes the base layer', () {
      var baseLayers = {'Layer 1': L.tileLayer(), 'Layer 2': L.tileLayer()},
        layers = L.control.layers(baseLayers).addTo(map),
        spy = sinon.spy();

      map.on('baselayerchange', spy)
        .whenReady(() {
          happen.click(layers._baseLayersList.getElementsByTagName('input')[0]);

          expect(spy.called).to.be.ok();
          expect(spy.mostRecentCall.args[0].layer).to.be(baseLayers['Layer 1']);
        });
    });

    test('is not fired on input that doesn\'t change the base layer', () {
      var overlays = {'Marker 1': L.marker([0, 0]), 'Marker 2': L.marker([0, 0])},
        layers = L.control.layers({}, overlays).addTo(map),
        spy = sinon.spy();

      map.on('baselayerchange', spy);
      happen.click(layers._overlaysList.getElementsByTagName('input')[0]);

      expect(spy.called).to.not.be.ok();
    });
  });

  describe('updates', () {
    beforeEach(() {
      map.setView([0, 0], 14);
    });

    test('when an included layer is addded or removed', () {
      var baseLayer = L.tileLayer(),
        overlay = L.marker([0, 0]),
        layers = L.control.layers({'Base': baseLayer}, {'Overlay': overlay}).addTo(map);

      var spy = sinon.spy(layers, '_update');

      map.addLayer(overlay);
      map.removeLayer(overlay);

      expect(spy.called).to.be.ok();
      expect(spy.callCount).to.eql(2);
    });

    test('not when a non-included layer is added or removed', () {
      var baseLayer = L.tileLayer(),
        overlay = L.marker([0, 0]),
        layers = L.control.layers({'Base': baseLayer}).addTo(map);

      var spy = sinon.spy(layers, '_update');

      map.addLayer(overlay);
      map.removeLayer(overlay);

      expect(spy.called).to.not.be.ok();
    });
  });
}