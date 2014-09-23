part of leaflet.layer.test;

layerGroupTest() {
  group('LayerGroup', () {
    group('#addLayer', () {
      test('adds a layer', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        expect(lg.addLayer(marker), equals(lg));

        expect(lg.hasLayer(marker), isTrue);
      });
    });
    group('#removeLayer', () {
      test('removes a layer', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.addLayer(marker);
        expect(lg.removeLayer(marker), equals(lg));

        expect(lg.hasLayer(marker), isFalse);
      });
    });
    group('#clearLayers', () {
      test('removes all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.addLayer(marker);
        expect(lg.clearLayers(), equals(lg));

        expect(lg.hasLayer(marker), isFalse);
      });
    });
    group('#getLayers', () {
      test('gets all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0));

        lg.addLayer(marker);

        expect(lg.getLayers(), equals([marker]));
      });
    });
    group('#eachLayer', () {
      test('iterates over all layers', () {
        final lg = new LayerGroup(),
            marker = new Marker(new LatLng(0, 0)),
            ctx = { 'foo': 'bar' };

        lg.addLayer(marker);

        lg.eachLayer((layer) {
          expect(layer, equals(marker));
          //expect(this).to.eql(ctx);
        }, ctx);
      });
    });
  });
}