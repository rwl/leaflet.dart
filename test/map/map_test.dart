import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' as L;


main() {
  useHtmlEnhancedConfiguration();

  var spy, map;

  setUp(() {
    map = new Map(document.createElement('div'));
  });

  group('#remove', () {
    test('fires an unload event if loaded', () {
      var container = document.createElement('div'),
          map = new L.Map(container).setView([0, 0], 0),
        spy = sinon.spy();
      map.on('unload', spy);
      map.remove();
      expect(spy.called).to.be.ok();
    });

    test('fires no unload event if not loaded', () {
      var container = document.createElement('div'),
          map = new L.Map(container),
        spy = sinon.spy();
      map.on('unload', spy);
      map.remove();
      expect(spy.called).not.to.be.ok();
    });

    describe('corner case checking', () {
      test('throws an exception upon reinitialization', () {
        var container = document.createElement('div'),
          map = new L.Map(container);
        expect(() {
          L.map(container);
        }).to.throwException((e) {
          expect(e.message).to.eql('Map container is already initialized.');
        });
        map.remove();
      });

      test('throws an exception if a container is not found', () {
        expect(() {
          L.map('nonexistentdivelement');
        }).to.throwException((e) {
          expect(e.message).to.eql('Map container not found.');
        });
        map.remove();
      });
    });

    test('undefines container._leaflet', () {
      var container = document.createElement('div'),
          map = new L.Map(container);
      map.remove();
      expect(container._leaflet).to.be(undefined);
    });

    test('unbinds events', () {
      var container = document.createElement('div'),
          map = new L.Map(container).setView([0, 0], 1),
        spy = sinon.spy();

      map.on('click dblclick mousedown mouseup mousemove', spy);
      map.remove();

      happen.click(container);
      happen.dblclick(container);
      happen.mousedown(container);
      happen.mouseup(container);
      happen.mousemove(container);

      expect(spy.called).to.not.be.ok();
    });
  });


  describe('#getCenter', () {
    it('throws if not set before', () {
      expect(() {
        map.getCenter();
      }).to.throwError();
    });

    it('returns a precise center when zoomed in after being set (#426)', () {
      var center = L.latLng(10, 10);
      map.setView(center, 1);
      map.setZoom(19);
      expect(map.getCenter()).to.eql(center);
    });

    it('returns correct center after invalidateSize (#1919)', () {
      map.setView(L.latLng(10, 10), 1);
      map.invalidateSize();
      expect(map.getCenter()).not.to.eql(L.latLng(10, 10));
    });
  });

  describe('#whenReady', () {
    describe('when the map has not yet been loaded', () {
      test('calls the callback when the map is loaded', () {
        var spy = sinon.spy();
        map.whenReady(spy);
        expect(spy.called).to.not.be.ok();

        map.setView([0, 0], 1);
        expect(spy.called).to.be.ok();
      });
    });

    describe('when the map has already been loaded', () {
      test('calls the callback immediately', () {
        var spy = sinon.spy();
        map.setView([0, 0], 1);
        map.whenReady(spy);

        expect(spy.called).to.be.ok();
      });
    });
  });

  describe('#setView', () {
    test('sets the view of the map', () {
      expect(map.setView([51.505, -0.09], 13)).to.be(map);
      expect(map.getZoom()).to.be(13);
      expect(map.getCenter().distanceTo([51.505, -0.09])).to.be.lessThan(5);
    });
    test('can be passed without a zoom specified', () {
      map.setZoom(13);
      expect(map.setView([51.605, -0.11])).to.be(map);
      expect(map.getZoom()).to.be(13);
      expect(map.getCenter().distanceTo([51.605, -0.11])).to.be.lessThan(5);
    });
  });

  describe('#getBounds', () {
    test('is safe to call from within a moveend callback during initial load (#1027)', () {
      map.on('moveend', () {
        map.getBounds();
      });

      map.setView([51.505, -0.09], 13);
    });
  });

  describe('#setMaxBounds', () {
    test('aligns pixel-wise map view center with maxBounds center if it cannot move view bounds inside maxBounds (#1908)', () {
      var container = map.getContainer();
      // large view, cannot fit within maxBounds
      container.style.width = container.style.height = '1000px';
      document.body.appendChild(container);
      // maxBounds
      var bounds = L.latLngBounds([51.5, -0.05], [51.55, 0.05]);
      map.setMaxBounds(bounds, {animate: false});
      // set view outside
      map.setView(L.latLng([53.0, 0.15]), 12, {animate: false});
      // get center of bounds in pixels
      var boundsCenter = map.project(bounds.getCenter()).round();
      expect(map.project(map.getCenter()).round()).to.eql(boundsCenter);
      document.body.removeChild(container);
    });
    test('moves map view within maxBounds by changing one coordinate', () {
      var container = map.getContainer();
      // small view, can fit within maxBounds
      container.style.width = container.style.height = '200px';
      document.body.appendChild(container);
      // maxBounds
      var bounds = L.latLngBounds([51, -0.2], [52, 0.2]);
      map.setMaxBounds(bounds, {animate: false});
      // set view outside maxBounds on one direction only
      // leaves untouched the other coordinate (that is not already centered)
      var initCenter = [53.0, 0.1];
      map.setView(L.latLng(initCenter), 16, {animate: false});
      // one pixel coordinate hasn't changed, the other has
      var pixelCenter = map.project(map.getCenter()).round();
      var pixelInit = map.project(initCenter).round();
      expect(pixelCenter.x).to.eql(pixelInit.x);
      expect(pixelCenter.y).not.to.eql(pixelInit.y);
      // the view is inside the bounds
      expect(bounds.contains(map.getBounds())).to.be(true);
      document.body.removeChild(container);
    });
  });

  describe('#getMinZoom and #getMaxZoom', () {
    describe('#getMinZoom', () {
      it('returns 0 if not set by Map options or TileLayer options', () {
        var map = L.map(document.createElement('div'));
        expect(map.getMinZoom()).to.be(0);
      });
    });

    test('minZoom and maxZoom options overrides any minZoom and maxZoom set on layers', () {

      var map = L.map(document.createElement('div'), {minZoom: 2, maxZoom: 20});

      L.tileLayer('{z}{x}{y}', {minZoom: 4, maxZoom: 10}).addTo(map);
      L.tileLayer('{z}{x}{y}', {minZoom: 6, maxZoom: 17}).addTo(map);
      L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 22}).addTo(map);

      expect(map.getMinZoom()).to.be(2);
      expect(map.getMaxZoom()).to.be(20);
    });
  });

  describe('#addLayer', () {
    test('calls layer.onAdd immediately if the map is ready', () {
      var layer = { onAdd: sinon.spy() };
      map.setView([0, 0], 0);
      map.addLayer(layer);
      expect(layer.onAdd.called).to.be.ok();
    });

    test('calls layer.onAdd when the map becomes ready', () {
      var layer = { onAdd: sinon.spy() };
      map.addLayer(layer);
      expect(layer.onAdd.called).not.to.be.ok();
      map.setView([0, 0], 0);
      expect(layer.onAdd.called).to.be.ok();
    });

    test('does not call layer.onAdd if the layer is removed before the map becomes ready', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
      map.addLayer(layer);
      map.removeLayer(layer);
      map.setView([0, 0], 0);
      expect(layer.onAdd.called).not.to.be.ok();
    });

    test('fires a layeradd event immediately if the map is ready', () {
      var layer = { onAdd: sinon.spy() },
          spy = sinon.spy();
      map.on('layeradd', spy);
      map.setView([0, 0], 0);
      map.addLayer(layer);
      expect(spy.called).to.be.ok();
    });

    test('fires a layeradd event when the map becomes ready', () {
      var layer = { onAdd: sinon.spy() },
          spy = sinon.spy();
      map.on('layeradd', spy);
      map.addLayer(layer);
      expect(spy.called).not.to.be.ok();
      map.setView([0, 0], 0);
      expect(spy.called).to.be.ok();
    });

    test('does not fire a layeradd event if the layer is removed before the map becomes ready', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
          spy = sinon.spy();
      map.on('layeradd', spy);
      map.addLayer(layer);
      map.removeLayer(layer);
      map.setView([0, 0], 0);
      expect(spy.called).not.to.be.ok();
    });

    test('adds the layer before firing layeradd', (done) {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
      map.on('layeradd', () {
        expect(map.hasLayer(layer)).to.be.ok();
        done();
      });
      map.setView([0, 0], 0);
      map.addLayer(layer);
    });

    describe('When the first layer is added to a map', () {
      test('fires a zoomlevelschange event', () {
        var spy = sinon.spy();
        map.on('zoomlevelschange', spy);
        expect(spy.called).not.to.be.ok();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
        expect(spy.called).to.be.ok();
      });
    });

    describe('when a new layer with greater zoomlevel coverage than the current layer is added to a map', () {
      test('fires a zoomlevelschange event', () {
        var spy = sinon.spy();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
        map.on('zoomlevelschange', spy);
        expect(spy.called).not.to.be.ok();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 15}).addTo(map);
        expect(spy.called).to.be.ok();
      });
    });

    describe('when a new layer with the same or lower zoomlevel coverage as the current layer is added to a map', () {
      test('fires no zoomlevelschange event', () {
        var spy = sinon.spy();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
        map.on('zoomlevelschange', spy);
        expect(spy.called).not.to.be.ok();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);
        expect(spy.called).not.to.be.ok();
        L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 5}).addTo(map);
        expect(spy.called).not.to.be.ok();
      });
    });
  });

  describe('#removeLayer', () {
    test('calls layer.onRemove if the map is ready', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
      map.setView([0, 0], 0);
      map.addLayer(layer);
      map.removeLayer(layer);
      expect(layer.onRemove.called).to.be.ok();
    });

    test('does not call layer.onRemove if the layer was not added', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
      map.setView([0, 0], 0);
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
      map.on('layerremove', spy);
      map.setView([0, 0], 0);
      map.addLayer(layer);
      map.removeLayer(layer);
      expect(spy.called).to.be.ok();
    });

    test('does not fire a layerremove if the layer was not added', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
          spy = sinon.spy();
      map.on('layerremove', spy);
      map.setView([0, 0], 0);
      map.removeLayer(layer);
      expect(spy.called).not.to.be.ok();
    });

    test('does not fire a layerremove if the map is not ready', () {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() },
          spy = sinon.spy();
      map.on('layerremove', spy);
      map.addLayer(layer);
      map.removeLayer(layer);
      expect(spy.called).not.to.be.ok();
    });

    test('removes the layer before firing layerremove', (done) {
      var layer = { onAdd: sinon.spy(), onRemove: sinon.spy() };
      map.on('layerremove', () {
        expect(map.hasLayer(layer)).not.to.be.ok();
        done();
      });
      map.setView([0, 0], 0);
      map.addLayer(layer);
      map.removeLayer(layer);
    });

    describe('when the last tile layer on a map is removed', () {
      test('fires a zoomlevelschange event', () {
        map.whenReady(() {
          var spy = sinon.spy();
          var tl = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map);

          map.on('zoomlevelschange', spy);
          expect(spy.called).not.to.be.ok();
          map.removeLayer(tl);
          expect(spy.called).to.be.ok();
        });
      });
    });

    describe('when a tile layer is removed from a map and it had greater zoom level coverage than the remainding layer', () {
      test('fires a zoomlevelschange event', () {
        map.whenReady(() {
          var spy = sinon.spy(),
            tl = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
              t2 = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 15}).addTo(map);

          map.on('zoomlevelschange', spy);
          expect(spy.called).to.not.be.ok();
          map.removeLayer(t2);
          expect(spy.called).to.be.ok();
        });
      });
    });

    describe('when a tile layer is removed from a map it and it had lesser or the sa,e zoom level coverage as the remainding layer(s)', () {
      test('fires no zoomlevelschange event', () {
        map.whenReady(() {
          var tl = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
              t2 = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 10}).addTo(map),
              t3 = L.tileLayer('{z}{x}{y}', {minZoom: 0, maxZoom: 5}).addTo(map);

          map.on('zoomlevelschange', spy);
          expect(spy).not.toHaveBeenCalled();
          map.removeLayer(t2);
          expect(spy).not.toHaveBeenCalled();
          map.removeLayer(t3);
          expect(spy).not.toHaveBeenCalled();
        });
      });
    });
  });

  describe('#eachLayer', () {
    test('returns self', () {
      expect(map.eachLayer(() {})).to.be(map);
    });

    test('calls the provided function for each layer', () {
      var t1 = L.tileLayer('{z}{x}{y}').addTo(map),
          t2 = L.tileLayer('{z}{x}{y}').addTo(map),
        spy = sinon.spy();

      map.eachLayer(spy);

      expect(spy.callCount).to.eql(2);
      expect(spy.firstCall.args).to.eql([t1]);
      expect(spy.secondCall.args).to.eql([t2]);
    });

    test('calls the provided function with the provided context', () {
      var t1 = L.tileLayer('{z}{x}{y}').addTo(map),
        spy = sinon.spy();

      map.eachLayer(spy, map);

      expect(spy.thisValues[0]).to.eql(map);
    });
  });

  describe('#invalidateSize', () {
    var container,
        origWidth = 100,
      clock;

    beforeEach(() {
      container = map.getContainer();
      container.style.width = origWidth + 'px';
      document.body.appendChild(container);
      map.setView([0, 0], 0);
      map.invalidateSize({pan: false});
      clock = sinon.useFakeTimers();
    });

    afterEach(() {
      document.body.removeChild(container);
      clock.restore();
    });

    test('pans by the right amount when growing in 1px increments', () {
      container.style.width = (origWidth + 1) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(1);

      container.style.width = (origWidth + 2) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(1);

      container.style.width = (origWidth + 3) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(2);
    });

    test('pans by the right amount when shrinking in 1px increments', () {
      container.style.width = (origWidth - 1) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(0);

      container.style.width = (origWidth - 2) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(-1);

      container.style.width = (origWidth - 3) + 'px';
      map.invalidateSize();
      expect(map._getMapPanePos().x).to.be(-1);
    });

    test('pans back to the original position after growing by an odd size and back', () {
      container.style.width = (origWidth + 5) + 'px';
      map.invalidateSize();

      container.style.width = origWidth + 'px';
      map.invalidateSize();

      expect(map._getMapPanePos().x).to.be(0);
    });

    test('emits no move event if the size has not changed', () {
      var spy = sinon.spy();
      map.on('move', spy);

      map.invalidateSize();

      expect(spy.called).not.to.be.ok();
    });

    test('emits a move event if the size has changed', () {
      var spy = sinon.spy();
      map.on('move', spy);

      container.style.width = (origWidth + 5) + 'px';
      map.invalidateSize();

      expect(spy.called).to.be.ok();
    });

    test('emits a moveend event if the size has changed', () {
      var spy = sinon.spy();
      map.on('moveend', spy);

      container.style.width = (origWidth + 5) + 'px';
      map.invalidateSize();

      expect(spy.called).to.be.ok();
    });

    test('debounces the moveend event if the debounceMoveend option is given', () {
      var spy = sinon.spy();
      map.on('moveend', spy);

      container.style.width = (origWidth + 5) + 'px';
      map.invalidateSize({debounceMoveend: true});

      expect(spy.called).not.to.be.ok();

      clock.tick(200);

      expect(spy.called).to.be.ok();
    });
  });
}