import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Marker', () {
    var map,
    spy,
    icon1,
    icon2;

    setUp(() {
      map = L.map(document.createElement('div')).setView([0, 0], 0);
      icon1 = new L.Icon.Default();
      icon2 = new L.Icon.Default({
        iconUrl: icon1._getIconUrl('icon') + '?2',
        shadowUrl: icon1._getIconUrl('shadow') + '?2'
      });
    });

    group('#setIcon', () {
      test('changes the icon to another image', () {
        var marker = new L.Marker([0, 0], {icon: icon1});
        map.addLayer(marker);

        var beforeIcon = marker._icon;
        marker.setIcon(icon2);
        var afterIcon = marker._icon;

        expect(beforeIcon).to.be(afterIcon);
        expect(afterIcon.src).to.contain(icon2._getIconUrl('icon'));
      });

      test('changes the icon to another DivIcon', () {
        var marker = new L.Marker([0, 0], {icon: new L.DivIcon({html: 'Inner1Text' }) });
        map.addLayer(marker);

        var beforeIcon = marker._icon;
        marker.setIcon(new L.DivIcon({html: 'Inner2Text' }));
        var afterIcon = marker._icon;

        expect(beforeIcon).to.be(afterIcon);
        expect(afterIcon.innerHTML).to.contain('Inner2Text');
      });

      test('removes text when changing to a blank DivIcon', () {
        var marker = new L.Marker([0, 0], {icon: new L.DivIcon({html: 'Inner1Text' }) });
        map.addLayer(marker);

        marker.setIcon(new L.DivIcon());
        var afterIcon = marker._icon;

        expect(marker._icon.innerHTML).to.not.contain('Inner1Text');
      });

      test('changes a DivIcon to an image', () {
        var marker = new L.Marker([0, 0], {icon: new L.DivIcon({html: 'Inner1Text' }) });
        map.addLayer(marker);
        var oldIcon = marker._icon;

        marker.setIcon(icon1);

        expect(oldIcon).to.not.be(marker._icon);
        expect(oldIcon.parentNode).to.be(null);

        expect(marker._icon.src).to.contain('marker-icon.png');
        expect(marker._icon.parentNode).to.be(map._panes.markerPane);
      });

      test('changes an image to a DivIcon', () {
        var marker = new L.Marker([0, 0], {icon: icon1});
        map.addLayer(marker);
        var oldIcon = marker._icon;

        marker.setIcon(new L.DivIcon({html: 'Inner1Text' }));

        expect(oldIcon).to.not.be(marker._icon);
        expect(oldIcon.parentNode).to.be(null);

        expect(marker._icon.innerHTML).to.contain('Inner1Text');
        expect(marker._icon.parentNode).to.be(map._panes.markerPane);
      });

      test('reuses the icon/shadow when changing icon', () {
        var marker = new L.Marker([0, 0], { icon: icon1});
        map.addLayer(marker);
        var oldIcon = marker._icon;
        var oldShadow = marker._shadow;

        marker.setIcon(icon2);

        expect(oldIcon).to.be(marker._icon);
        expect(oldShadow).to.be(marker._shadow);

        expect(marker._icon.parentNode).to.be(map._panes.markerPane);
        expect(marker._shadow.parentNode).to.be(map._panes.shadowPane);
      });
    });
  });

}