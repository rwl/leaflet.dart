
import 'dart:html' as html;
import 'dart:html' show document;

import 'dart:collection' show LinkedHashMap;

import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/core/core.dart' show EventType, Event, Action, LayersControlEvent;
import 'package:leaflet/control/control.dart' show Layers, LayersOptions;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer;
import 'package:leaflet/layer/marker/marker.dart' show Marker;
import 'package:leaflet/layer/layer.dart' show Layer;
import 'package:leaflet/geo/geo.dart' show LatLng;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Control.Layers', () {
    LeafletMap map;

    bool called;
    //List<Object> objs;
    List<LayersControlEvent> events;
    Action action = (Event e) {
      called = true;
      //objs.add(obj);
      events.add(e);
    };

    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      called = false;
      //objs = new List<Object>();
      events = new List<Event>();
    });

    group('baselayerchange event', () {
      test('is fired on input that changes the base layer', () {
        final baseLayers = {'Layer 1': new TileLayer(), 'Layer 2': new TileLayer()},
          layers = new Layers(baseLayers)..addTo(map);
          //spy = sinon.spy();


        map.on(EventType.BASELAYERCHANGE, action);
        map.whenReady(() {
//            happen.click(layers.baseLayersList.querySelectorAll('input')[0]);
          layers.baseLayersList.querySelectorAll('input')[0].dispatchEvent(new html.Event('click'));

          expect(called, isTrue);
          expect(events[0].layer, equals(baseLayers['Layer 1']));
        });
      });

      test('is not fired on input that doesn\'t change the base layer', () {
        final overlays = {'Marker 1': new Marker(new LatLng(0, 0)),
                          'Marker 2': new Marker(new LatLng(0, 0))};
        final layers = new Layers({}, overlays)..addTo(map);
          //spy = sinon.spy();

        map.on(EventType.BASELAYERCHANGE, action);
        layers.overlaysList.querySelectorAll('input')[0].dispatchEvent(new html.Event('click'));

        expect(called, isFalse);
      });
    });

    group('updates', () {
      setUp(() {
        map.setView(new LatLng(0, 0), 14);
      });

      test('when an included layer is addded or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new TestLayers({'Base': baseLayer}, {'Overlay': overlay})..addTo(map);

        //var spy = sinon.spy(layers, '_update');

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(layers.called, isTrue);
        expect(layers.callCount, equals(2));
      });

      test('not when a non-included layer is added or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new TestLayers({'Base': baseLayer})..addTo(map);

        //var spy = sinon.spy(layers, '_update');

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(layers.called, isFalse);
      });
    });
  });
}

class TestLayers extends Layers {
  bool called = false;
  int callCount = 0;

  TestLayers(LinkedHashMap<String, Layer> baseLayers, [LinkedHashMap<String, Layer> overlays=null, LayersOptions options=null]) : super(baseLayers, overlays, options);

  void update() {
    called = true;
    callCount++;
    super.update();
  }
}