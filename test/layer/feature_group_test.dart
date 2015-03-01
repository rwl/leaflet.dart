part of leaflet.layer.test;

featureGroupTest() {
  group('FeatureGroup', () {
    LeafletMap map;
    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      map.setView(new LatLng(0, 0), 1);
    });
    group('propagateEvent', () {
      Marker marker;
      setUp(() {
        marker = new Marker(new LatLng(0, 0));
      });
      group('when a Marker is added to multiple FeatureGroups', () {
        test('e.layer should be the Marker', () {
          final fg1 = new FeatureGroup(),
              fg2 = new FeatureGroup();

          fg1.addLayer(marker);
          fg2.addLayer(marker);

          marker.fire(EventType.CLICK);//, { 'type': 'click' });

          final comp1 = new Completer();
          final comp2 = new Completer();

          fg2.onClick.listen((LayerEvent e) {
            expect(e.layer, equals(marker));
            //expect(e.target, equals(fg2));
            comp2.complete();
          });

          fg1.onClick.listen((LayerEvent e) {
            expect(e.layer, equals(marker));
            //expect(e.target, equals(fg1));
            comp1.complete();
          });

          expect(Future.wait([comp1.future, comp2.future]), completes);
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
      /*test('removes the layer passed to it by id', () {
        final fg = new FeatureGroup(),
            marker = new Marker(new LatLng(0, 0));

        fg.addLayer(marker);
        expect(fg.hasLayer(marker), isTrue);

        fg.removeLayer(stamp(marker));
        expect(fg.hasLayer(marker), isFalse);
      });*/
    });
  });
}