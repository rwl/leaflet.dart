import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('FeatureGroup', () {
    var map;
    beforeEach(() {
      map = L.map(document.createElement('div'));
      map.setView([0, 0], 1);
    });
    group('#_propagateEvent', () {
      var marker;
      beforeEach(() {
        marker = L.marker([0, 0]);
      });
      group('when a Marker is added to multiple FeatureGroups ', () {
        test('e.layer should be the Marker', () {
          var fg1 = L.featureGroup(),
              fg2 = L.featureGroup();

          fg1.addLayer(marker);
          fg2.addLayer(marker);

          var wasClicked1,
          wasClicked2;

          fg2.on('click', (e) {
            expect(e.layer).to.be(marker);
            expect(e.target).to.be(fg2);
            wasClicked2 = true;
          });

          fg1.on('click', (e) {
            expect(e.layer).to.be(marker);
            expect(e.target).to.be(fg1);
            wasClicked1 = true;
          });

          marker.fire('click', { type: 'click' });

          expect(wasClicked1).to.be(true);
          expect(wasClicked2).to.be(true);
        });
      });
    });
    group('addLayer', () {
      test('adds the layer', () {
        var fg = L.featureGroup(),
            marker = L.marker([0, 0]);

        expect(fg.hasLayer(marker)).to.be(false);

        fg.addLayer(marker);

        expect(fg.hasLayer(marker)).to.be(true);
      });
      test('supports non-evented layers', () {
        var fg = L.featureGroup(),
            g = L.layerGroup();

        expect(fg.hasLayer(g)).to.be(false);

        fg.addLayer(g);

        expect(fg.hasLayer(g)).to.be(true);
      });
    });
    group('removeLayer', () {
      test('removes the layer passed to it', () {
        var fg = L.featureGroup(),
            marker = L.marker([0, 0]);

        fg.addLayer(marker);
        expect(fg.hasLayer(marker)).to.be(true);

        fg.removeLayer(marker);
        expect(fg.hasLayer(marker)).to.be(false);
      });
      test('removes the layer passed to it by id', () {
        var fg = L.featureGroup(),
            marker = L.marker([0, 0]);

        fg.addLayer(marker);
        expect(fg.hasLayer(marker)).to.be(true);

        fg.removeLayer(L.stamp(marker));
        expect(fg.hasLayer(marker)).to.be(false);
      });
    });
  });
}