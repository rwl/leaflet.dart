part of leaflet.control.test;

layersTest() {
  group('Layers', () {
    LeafletMap map;

    bool called;
    //List<Object> objs;
    List<LayersControlEvent> events;
    Action action = (LayersControlEvent e) {
      called = true;
      //objs.add(obj);
      events.add(e);
    };

    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      called = false;
      //objs = new List<Object>();
      events = new List<LayersControlEvent>();
    });

    group('baselayerchange event', () {
      test('is fired on input that changes the base layer', () {
        final baseLayers = {'Layer 1': new TileLayer(), 'Layer 2': new TileLayer()},
          layers = new Layers(baseLayers)..addTo(map);
          //spy = sinon.spy();


        map.onBaseLayerChange.listen(action);
        map.whenReady((_) {
//            happen.click(layers.baseLayersList.querySelectorAll('input')[0]);
          layers.baseLayersList.querySelectorAll('input')[0].dispatchEvent(new html.MouseEvent('click'));

          expect(called, isTrue);
          expect(events[0].layer, equals(baseLayers['Layer 1']));
        });
      });

      test('is not fired on input that doesn\'t change the base layer', () {
        final overlays = {'Marker 1': new Marker(new LatLng(0, 0)),
                          'Marker 2': new Marker(new LatLng(0, 0))};
        final layers = new Layers({}, overlays)..addTo(map);
          //spy = sinon.spy();

        map.onBaseLayerChange.listen(action);
        layers.overlaysList.querySelectorAll('input')[0].dispatchEvent(new html.MouseEvent('click'));

        expect(called, isFalse);
      });
    });

    group('updates', () {
      setUp(() {
        map.setView(new LatLng(0, 0), 14);
      });

      test('when an included layer is added or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new TestLayers({'Base': baseLayer}, {'Overlay': overlay})..addTo(map);

        //var spy = sinon.spy(layers, '_update');
        layers.resetTest();

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(new Future.delayed(const Duration(milliseconds: 500), () {
          expect(layers.called, isTrue);
          expect(layers.callCount, equals(2));
        }), completes);
      });

      test('not when a non-included layer is added or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new TestLayers({'Base': baseLayer})..addTo(map);

        //var spy = sinon.spy(layers, '_update');
        layers.resetTest();

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(new Future.delayed(const Duration(milliseconds: 500), () {
          expect(layers.called, isFalse);
        }), completes);
      });
    });
  });
}

class TestLayers extends Layers {
  bool called = false;
  int callCount = 0;

  TestLayers(LinkedHashMap<String, Layer> baseLayers, [LinkedHashMap<String, Layer> overlays=null,
      LayersOptions options=null]) : super(baseLayers, overlays, options);

  void update() {
    called = true;
    callCount++;
    super.update();
  }

  void resetTest() {
    called = false;
    callCount = 0;
  }
}