
import 'dart:html' show document;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show BaseMap, containerProp;
import 'package:leaflet/geo/geo.dart' show LatLng, LatLngBounds;
import 'package:leaflet/core/core.dart' show Event, EventType;
import 'package:leaflet/layer/layer.dart' show Layer;


main() {
  useHtmlEnhancedConfiguration();

  group('Map', () {
    BaseMap map;
    bool called;

    setUp(() {
      map = new BaseMap(document.createElement('div'));
      called = false;
    });

    group('#remove', () {
      test('fires an unload event if loaded', () {
        final container = document.createElement('div'),
          map = new BaseMap(container)..setView(new LatLng(0, 0), 0);
        map.on(EventType.UNLOAD, (Object obj, Event e) {
          called = true;
        });
        map.remove();
        expect(called, isTrue);
      });

      test('fires no unload event if not loaded', () {
        final container = document.createElement('div'),
            map = new BaseMap(container);
        map.on(EventType.UNLOAD, (Object obj, Event e) {
          called = true;
        });
        map.remove();
        expect(called, isFalse);
      });

      group('corner case checking', () {
        test('throws an exception upon reinitialization', () {
          final container = document.createElement('div'),
            map = new BaseMap(container);
          try {
            new BaseMap(container);
            fail('Exception expected');
          } catch (e) {
            expect(e.message, equals('Map container is already initialized.'));
          }
          map.remove();
        });

        /*test('throws an exception if a container is not found', () {
          expect(() {
            L.map('nonexistentdivelement');
          }).to.throwException((e) {
            expect(e.message).to.eql('Map container not found.');
          });
          map.remove();
        });*/
      });

      test('undefines container._leaflet', () {
        final container = document.createElement('div'),
            map = new BaseMap(container);
        map.remove();
        expect(containerProp[container], isNull);
      });

      test('unbinds events', () {
        final container = document.createElement('div'),
            map = new BaseMap(container)..setView(new LatLng(0, 0), 1);

        final fn = (Object obj, Event e) {
          called = true;
        };
        map.on(EventType.CLICK, fn);
        map.on(EventType.DBLCLICK, fn);
        map.on(EventType.MOUSEDOWN, fn);
        map.on(EventType.MOUSEUP, fn);
        map.on(EventType.MOUSEMOVE, fn);
        map.remove();

        happen.click(container);
        happen.dblclick(container);
        happen.mousedown(container);
        happen.mouseup(container);
        happen.mousemove(container);

        expect(called, isFalse);
      });
    });


    group('#getCenter', () {
      test('throws if not set before', () {
        expect(map.getCenter(), throwsException);
      });

      test('returns a precise center when zoomed in after being set (#426)', () {
        final center = new LatLng(10, 10);
        map.setView(center, 1);
        map.setZoom(19);
        expect(map.getCenter(), equals(center));
      });

      test('returns correct center after invalidateSize (#1919)', () {
        map.setView(new LatLng(10, 10), 1);
        map.invalidateSize();
        expect(map.getCenter(), isNot(equals(new LatLng(10, 10))));
      });
    });

    group('#whenReady', () {
      group('when the map has not yet been loaded', () {
        test('calls the callback when the map is loaded', () {
          map.whenReady(() {
            called = true;
          });
          expect(called, isFalse);

          map.setView(new LatLng(0, 0), 1);
          expect(called, isTrue);
        });
      });

      group('when the map has already been loaded', () {
        test('calls the callback immediately', () {
          map.setView(new LatLng(0, 0), 1);
          map.whenReady(() {
            called = true;
          });

          expect(called, isTrue);
        });
      });
    });

    group('#setView', () {
      test('sets the view of the map', () {
        expect(map..setView(new LatLng(51.505, -0.09), 13), equals(map));
        expect(map.getZoom(), equals(13));
        expect(map.getCenter().distanceTo(new LatLng(51.505, -0.09)), lessThan(5));
      });
      test('can be passed without a zoom specified', () {
        map.setZoom(13);
        expect(map..setView(new LatLng(51.605, -0.11)), equals(map));
        expect(map.getZoom(), equals(13));
        expect(map.getCenter().distanceTo(new LatLng(51.605, -0.11)), lessThan(5));
      });
    });

    group('#getBounds', () {
      test('is safe to call from within a moveend callback during initial load (#1027)', () {
        map.on(EventType.MOVEEND, (Object obj, Event e) {
          map.getBounds();
        });

        map.setView(new LatLng(51.505, -0.09), 13);
      });
    });

    group('#setMaxBounds', () {
      test('aligns pixel-wise map view center with maxBounds center if it cannot move view bounds inside maxBounds (#1908)', () {
        final container = map.getContainer();
        // Large view, cannot fit within maxBounds.
        container.style.width = container.style.height = '1000px';
        document.body.append(container);
        // maxBounds
        final bounds = new LatLngBounds.between(new LatLng(51.5, -0.05), new LatLng(51.55, 0.05));
        map.setMaxBounds(bounds, {'animate': false});
        // Set view outside.
        map.setView(new LatLng(53.0, 0.15), 12, {'animate': false});
        // Get center of bounds in pixels.
        var boundsCenter = map.project(bounds.getCenter()).rounded();
        expect(map.project(map.getCenter()).rounded(), equals(boundsCenter));
        //document.body.removeChild(container);
        container.remove();
      });
      test('moves map view within maxBounds by changing one coordinate', () {
        var container = map.getContainer();
        // Small view, can fit within maxBounds.
        container.style.width = container.style.height = '200px';
        document.body.append(container);
        // maxBounds
        final bounds = new LatLngBounds.between(new LatLng(51, -0.2), new LatLng(52, 0.2));
        map.setMaxBounds(bounds, {'animate': false});
        // Set view outside maxBounds on one direction only
        // leaves untouched the other coordinate (that is not already centered).
        final initCenter = new LatLng(53.0, 0.1);
        map.setView(initCenter, 16, {'animate': false});
        // one pixel coordinate hasn't changed, the other has
        final pixelCenter = map.project(map.getCenter()).rounded();
        final pixelInit = map.project(initCenter).rounded();
        expect(pixelCenter.x, equals(pixelInit.x));
        expect(pixelCenter.y, equals(pixelInit.y));
        // The view is inside the bounds.
        expect(bounds.containsBounds(map.getBounds()), isTrue);
        //document.body.removeChild(container);
        container.remove();
      });
    });

    group('#getMinZoom and #getMaxZoom', () {
      group('#getMinZoom', () {
        test('returns 0 if not set by Map options or TileLayer options', () {
          final map = new BaseMap(document.createElement('div'));
          expect(map.getMinZoom(), equals(0));
        });
      });

      test('minZoom and maxZoom options overrides any minZoom and maxZoom set on layers', () {

        final map = new BaseMap(document.createElement('div'), {'minZoom': 2, 'maxZoom': 20});

        new TileLayer('{z}{x}{y}', {'minZoom': 4, 'maxZoom': 10}).addTo(map);
        new TileLayer('{z}{x}{y}', {'minZoom': 6, 'maxZoom': 17}).addTo(map);
        new TileLayer('{z}{x}{y}', {'minZoom': 0, 'maxZoom': 22}).addTo(map);

        expect(map.getMinZoom(), equals(2));
        expect(map.getMaxZoom(), equals(20));
      });
    });

    group('#addLayer', () {
      test('calls layer.onAdd immediately if the map is ready', () {
        var layer = { onAdd: sinon.spy() };
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        expect(layer.onAdd.called).to.be.ok();
      });

      test('calls layer.onAdd when the map becomes ready', () {
        var layer = { onAdd: sinon.spy() };
        map.addLayer(layer);
        expect(layer.onAdd.called).not.to.be.ok();
        map.setView(new LatLng(0, 0), 0);
        expect(layer.onAdd.called).to.be.ok();
      });

      test('does not call layer.onAdd if the layer is removed before the map becomes ready', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.addLayer(layer);
        map.removeLayer(layer);
        map.setView(new LatLng(0, 0), 0);
        expect(layer.onAdd.called).not.to.be.ok();
      });

      test('fires a layeradd event immediately if the map is ready', () {
        var layer = { onAdd: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERADD, spy);
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        expect(spy.called).to.be.ok();
      });

      test('fires a layeradd event when the map becomes ready', () {
        var layer = { onAdd: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERADD, spy);
        map.addLayer(layer);
        expect(spy.called).not.to.be.ok();
        map.setView(new LatLng(0, 0), 0);
        expect(spy.called).to.be.ok();
      });

      test('does not fire a layeradd event if the layer is removed before the map becomes ready', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERADD, spy);
        map.addLayer(layer);
        map.removeLayer(layer);
        map.setView(new LatLng(0, 0), 0);
        expect(spy.called).not.to.be.ok();
      });

      test('adds the layer before firing layeradd', (/*done*/) {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.on(EventType.LAYERADD, (Object obj, Event e) {
          expect(map.hasLayer(layer), isTrue);
          done();
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
      });

      group('When the first layer is added to a map', () {
        test('fires a zoomlevelschange event', () {
          var spy = sinon.spy();
          map.on(EventType.ZOOMLEVELSCHANGE, spy);
          expect(spy.called).not.to.be.ok();
          new TileLayer('{z}{x}{y}', {'minZoom': 0, 'maxZoom': 10}).addTo(map);
          expect(spy.called).to.be.ok();
        });
      });

      group('when a new layer with greater zoomlevel coverage than the current layer is added to a map', () {
        test('fires a zoomlevelschange event', () {
          var spy = sinon.spy();
          new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
          map.on(EventType.ZOOMLEVELSCHANGE, spy);
          expect(spy.called).not.to.be.ok();
          new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 15}).addTo(map);
          expect(spy.called).to.be.ok();
        });
      });

      group('when a new layer with the same or lower zoomlevel coverage as the current layer is added to a map', () {
        test('fires no zoomlevelschange event', () {
          var spy = sinon.spy();
          new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
          map.on(EventType.ZOOMLEVELSCHANGE, spy);
          expect(spy.called).not.to.be.ok();
          new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
          expect(spy.called).not.to.be.ok();
          new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 5}).addTo(map);
          expect(spy.called).not.to.be.ok();
        });
      });
    });

    group('#removeLayer', () {
      test('calls layer.onRemove if the map is ready', () {
        final layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(layer.onRemove.called).to.be.ok();
      });

      test('does not call layer.onRemove if the layer was not added', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.setView(new LatLng(0, 0), 0);
        map.removeLayer(layer);
        expect(layer.onRemove.called).not.to.be.ok();
      });

      test('does not call layer.onRemove if the map is not ready', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(layer.onRemove.called).not.to.be.ok();
      });

      test('fires a layerremove event if the map is ready', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERREMOVE, spy);
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(spy.called).to.be.ok();
      });

      test('does not fire a layerremove if the layer was not added', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERREMOVE, spy);
        map.setView(new LatLng(0, 0), 0);
        map.removeLayer(layer);
        expect(spy.called).not.to.be.ok();
      });

      test('does not fire a layerremove if the map is not ready', () {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
            spy = sinon.spy();
        map.on(EventType.LAYERREMOVE, spy);
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(spy.called).not.to.be.ok();
      });

      test('removes the layer before firing layerremove', (/*done*/) {
        var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
        map.on(EventType.LAYERREMOVE, (Object obj, Event e) {
          expect(map.hasLayer(layer), isFalse);
          done();
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
      });

      group('when the last tile layer on a map is removed', () {
        test('fires a zoomlevelschange event', () {
          map.whenReady(() {
            var spy = sinon.spy();
            final tl = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);

            map.on(EventType.ZOOMLEVELSCHANGE, spy);
            expect(spy.called).not.to.be.ok();
            map.removeLayer(tl);
            expect(spy.called).to.be.ok();
          });
        });
      });

      group('when a tile layer is removed from a map and it had greater zoom level coverage than the remainding layer', () {
        test('fires a zoomlevelschange event', () {
          map.whenReady(() {
            final spy = sinon.spy(),
              tl = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
                t2 = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 15}).addTo(map);

            map.on(EventType.ZOOMLEVELSCHANGE, spy);
            expect(spy.called).to.not.be.ok();
            map.removeLayer(t2);
            expect(spy.called).to.be.ok();
          });
        });
      });

      group('when a tile layer is removed from a map it and it had lesser or the sa,e zoom level coverage as the remainding layer(s)', () {
        test('fires no zoomlevelschange event', () {
          map.whenReady(() {
            final tl = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
                t2 = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
                t3 = new TileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 5}).addTo(map);

            map.on(EventType.ZOOMLEVELSCHANGE, spy);
            expect(spy).not.toHaveBeenCalled();
            map.removeLayer(t2);
            expect(spy).not.toHaveBeenCalled();
            map.removeLayer(t3);
            expect(spy).not.toHaveBeenCalled();
          });
        });
      });
    });

    group('#eachLayer', () {
      test('returns self', () {
        expect(map.eachLayer((Layer l) {}), equals(map));
      });

      test('calls the provided function for each layer', () {
        final t1 = new TileLayer('{z}{x}{y}').addTo(map),
            t2 = new TileLayer('{z}{x}{y}').addTo(map),
          spy = sinon.spy();

        map.eachLayer(spy);

        expect(spy.callCount, equals(2));
        expect(spy.firstCall.args, equals([t1]));
        expect(spy.secondCall.args, equals([t2]));
      });

      test('calls the provided function with the provided context', () {
        final t1 = new TileLayer('{z}{x}{y}').addTo(map),
          spy = sinon.spy();

        map.eachLayer(spy, map);

        expect(spy.thisValues[0], equals(map));
      });
    });

    group('#invalidateSize', () {
      var container,
          origWidth = 100,
        clock;

      setUp(() {
        container = map.getContainer();
        container.style.width = '$origWidthpx';
        document.body.append(container);
        map.setView(new LatLng(0, 0), 0);
        map.invalidateSize({pan: false});
        clock = sinon.useFakeTimers();
      });

      tearDown(() {
        //document.body.removeChild(container);
        container.remove();
        clock.restore();
      });

      test('pans by the right amount when growing in 1px increments', () {
        container.style.width = '${origWidth + 1}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(1));

        container.style.width = '${origWidth + 2}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(1));

        container.style.width = '${origWidth + 3}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(2));
      });

      test('pans by the right amount when shrinking in 1px increments', () {
        container.style.width = '${origWidth - 1}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(0));

        container.style.width = '${origWidth - 2}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(-1));

        container.style.width = '${origWidth - 3}px';
        map.invalidateSize();
        expect(map._getMapPanePos().x, equals(-1));
      });

      test('pans back to the original position after growing by an odd size and back', () {
        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        container.style.width = '${origWidth}px';
        map.invalidateSize();

        expect(map._getMapPanePos().x, equals(0));
      });

      test('emits no move event if the size has not changed', () {
        var spy = sinon.spy();
        map.on(EventType.MOVE, spy);

        map.invalidateSize();

        expect(spy.called).not.to.be.ok();
      });

      test('emits a move event if the size has changed', () {
        var spy = sinon.spy();
        map.on(EventType.MOVE, spy);

        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        expect(spy.called).to.be.ok();
      });

      test('emits a moveend event if the size has changed', () {
        var spy = sinon.spy();
        map.on(EventType.MOVEEND, spy);

        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        expect(spy.called).to.be.ok();
      });

      test('debounces the moveend event if the debounceMoveend option is given', () {
        var spy = sinon.spy();
        map.on(EventType.MOVEEND, spy);

        container.style.width = (origWidth + 5) + 'px';
        map.invalidateSize(debounceMoveend: true);

        expect(spy.called).not.to.be.ok();

        clock.tick(200);

        expect(spy.called).to.be.ok();
      });
    });
  });
}
