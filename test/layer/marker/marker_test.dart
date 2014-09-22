
import 'dart:html' show document;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/marker/marker.dart' show Marker, DefaultIcon, DivIcon;


main() {
  useHtmlEnhancedConfiguration();

  group('Marker', () {
    LeafletMap map;
    Icon icon1, icon2;

    setUp(() {
      map = new LeafletMap(document.createElement('div'))..setView(new LatLng(0, 0), 0);
      icon1 = new DefaultIcon();
      icon2 = new DefaultIcon({
        'iconUrl': icon1._getIconUrl('icon') + '?2',
        'shadowUrl': icon1._getIconUrl('shadow') + '?2'
      });
    });

    group('#setIcon', () {
      test('changes the icon to another image', () {
        final marker = new Marker(new LatLng(0, 0), {'icon': icon1});
        map.addLayer(marker);

        final beforeIcon = marker._icon;
        marker.setIcon(icon2);
        final afterIcon = marker._icon;

        expect(beforeIcon, equals(afterIcon));
        expect(afterIcon.src, contains(icon2._getIconUrl('icon')));
      });

      test('changes the icon to another DivIcon', () {
        final marker = new Marker(new latLng(0, 0), {'icon': new DivIcon({'html': 'Inner1Text' }) });
        map.addLayer(marker);

        final beforeIcon = marker._icon;
        marker.setIcon(new DivIcon({html: 'Inner2Text' }));
        final afterIcon = marker._icon;

        expect(beforeIcon, equals(afterIcon));
        expect(afterIcon.innerHTML, contains('Inner2Text'));
      });

      test('removes text when changing to a blank DivIcon', () {
        final marker = new Marker(new LatLng(0, 0), {'icon': new DivIcon({'html': 'Inner1Text' }) });
        map.addLayer(marker);

        marker.setIcon(new DivIcon());
        final afterIcon = marker._icon;

        expect(marker._icon.innerHTML, isNot(contains('Inner1Text')));
      });

      test('changes a DivIcon to an image', () {
        final marker = new Marker(new LatLng(0, 0), {'icon': new DivIcon({'html': 'Inner1Text' }) });
        map.addLayer(marker);
        final oldIcon = marker._icon;

        marker.setIcon(icon1);

        expect(oldIcon, isNot(equals(marker._icon)));
        expect(oldIcon.parentNode, isNull);

        expect(marker._icon.src, contains('marker-icon.png'));
        expect(marker._icon.parentNode, equals(map._panes.markerPane));
      });

      test('changes an image to a DivIcon', () {
        final marker = new Marker(new LatLng(0, 0), {'icon': icon1});
        map.addLayer(marker);
        final oldIcon = marker._icon;

        marker.setIcon(new DivIcon({'html': 'Inner1Text' }));

        expect(oldIcon, isNot(equals(marker._icon)));
        expect(oldIcon.parentNode, isNull);

        expect(marker._icon.innerHTML, contains('Inner1Text'));
        expect(marker._icon.parentNode, equals(map.panes['markerPane']));
      });

      test('reuses the icon/shadow when changing icon', () {
        final marker = new Marker(new LatLng(0, 0), {'icon': icon1});
        map.addLayer(marker);
        final oldIcon = marker._icon;
        final oldShadow = marker._shadow;

        marker.setIcon(icon2);

        expect(oldIcon, equals(marker._icon));
        expect(oldShadow, equals(marker._shadow));

        expect(marker._icon.parentNode, equals(map.panes['markerPane']));
        expect(marker._shadow.parentNode, equals(map.panes['shadowPane']));
      });
    });
  });

}