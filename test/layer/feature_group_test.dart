part of leaflet.layer.test;

featureGroupTest() {
  group('FeatureGroup', () {
    LeafletMap map;
    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      map.setView(new LatLng(0, 0), 1);
    });
    group('#_propagateEvent', () {
      Marker marker;
      setUp(() {
        marker = new Marker(new LatLng(0, 0));
      });
      group('when a Marker is added to multiple FeatureGroups ', () {
        test('e.layer should be the Marker', () {
          final fg1 = new FeatureGroup(),
              fg2 = new FeatureGroup();

          fg1.addLayer(marker);
          fg2.addLayer(marker);

          bool wasClicked1 = false,
            wasClicked2 = false;

          fg2.on(EventType.CLICK, (Object obj, Event e) {
            expect(e.layer, equals(marker));
            expect(e.target, equals(fg2));
            wasClicked2 = true;
          });

          fg1.on(EventType.CLICK, (Object obj, Event e) {
            expect(e.layer, equals(marker));
            expect(e.target, equals(fg1));
            wasClicked1 = true;
          });

          marker.fire(EventType.CLICK, { 'type': 'click' });

          expect(wasClicked1, isTrue);
          expect(wasClicked2, isTrue);
        });
      });
    });
    group('addLayer', () {
      test('adds the layer', () {
        final fg = new FeatureGroup(),
            marker = new Marker(new LatLng(0, 0));

        expect(fg.hasLayer(marker), isFalse);

        fg.addLayer(marker);

        expect(fg.hasLayer(marker), isTrue);
      });
      test('supports non-evented layers', () {
        final fg = new FeatureGroup(),
            g = new LayerGroup();

        expect(fg.hasLayer(g), isFalse);

        fg.addLayer(g);

        expect(fg.hasLayer(g), isTrue);
      });
    });
    group('removeLayer', () {
      test('removes the layer passed to it', () {
        final fg = new FeatureGroup(),
            marker = new Marker(new LatLng(0, 0));

        fg.addLayer(marker);
        expect(fg.hasLayer(marker), isTrue);

        fg.removeLayer(marker);
        expect(fg.hasLayer(marker), isFalse);
      });
      test('removes the layer passed to it by id', () {
        final fg = new FeatureGroup(),
            marker = new Marker(new LatLng(0, 0));

        fg.addLayer(marker);
        expect(fg.hasLayer(marker), isTrue);

        fg.removeLayer(stamp(marker));
        expect(fg.hasLayer(marker), isFalse);
      });
    });
  });
}