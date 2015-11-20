import 'dart:html' show document;

import 'package:test/test.dart';

import 'package:leaflet/leaflet.dart';

markerTest() {
  group('Marker', () {
    LeafletMap map;
    DefaultIcon icon1, icon2;

    setUp(() {
      map = new LeafletMap(document.createElement('div'))
        ..setView(new LatLng(0, 0), 0);
      icon1 = new DefaultIcon();
      icon2 = new DefaultIcon()
        ..options.iconUrl = icon1.getIconUrl(IconType.ICON) + '?2'
        ..options.shadowUrl = icon1.getIconUrl(IconType.SHADOW) + '?2';
    });

    group('setIcon', () {
      test('changes the icon to another image', () {
        final marker =
            new Marker(new LatLng(0, 0), new MarkerOptions()..icon = icon1);
        map.addLayer(marker);

        final beforeIcon = marker.icon;
        marker.setIcon(icon2);
        final afterIcon = marker.icon;

        expect(beforeIcon, equals(afterIcon));
        expect(afterIcon.src, contains(icon2.getIconUrl(IconType.ICON)));
      });

      test('changes the icon to another DivIcon', () {
        final marker = new Marker(
            new LatLng(0, 0),
            new MarkerOptions()
              ..icon =
                  new DivIcon(new DivIconOptions(null)..html = 'Inner1Text'));
        map.addLayer(marker);

        final beforeIcon = marker.icon;
        marker.setIcon(
            new DivIcon(new DivIconOptions(null)..html = 'Inner2Text'));
        final afterIcon = marker.icon;

        expect(beforeIcon, equals(afterIcon));
        expect(afterIcon.text /*innerHTML*/, contains('Inner2Text'));
      });

      test('removes text when changing to a blank DivIcon', () {
        final marker = new Marker(
            new LatLng(0, 0),
            new MarkerOptions()
              ..icon =
                  new DivIcon(new DivIconOptions(null)..html = 'Inner1Text'));
        map.addLayer(marker);

        marker.setIcon(new DivIcon());
        final afterIcon = marker.icon;

        expect(marker.icon.text /*innerHTML*/, isNot(contains('Inner1Text')));
      });

      test('changes a DivIcon to an image', () {
        final marker = new Marker(
            new LatLng(0, 0),
            new MarkerOptions()
              ..icon =
                  new DivIcon(new DivIconOptions(null)..html = 'Inner1Text'));
        map.addLayer(marker);
        final oldIcon = marker.icon;

        marker.setIcon(icon1);

        expect(oldIcon, isNot(equals(marker.icon)));
        expect(oldIcon.parentNode, isNull);

        expect(marker.icon.src, contains('marker-icon.png'));
        expect(marker.icon.parentNode, equals(map.panes['markerPane']));
      });

      test('changes an image to a DivIcon', () {
        final marker =
            new Marker(new LatLng(0, 0), new MarkerOptions()..icon = icon1);
        map.addLayer(marker);
        final oldIcon = marker.icon;

        marker.setIcon(
            new DivIcon(new DivIconOptions(null)..html = 'Inner1Text'));

        expect(oldIcon, isNot(equals(marker.icon)));
        expect(oldIcon.parentNode, isNull);

        expect(marker.icon.text /*innerHTML*/, contains('Inner1Text'));
        expect(marker.icon.parentNode, equals(map.panes['markerPane']));
      });

      test('reuses the icon/shadow when changing icon', () {
        final marker =
            new Marker(new LatLng(0, 0), new MarkerOptions()..icon = icon1);
        map.addLayer(marker);
        final oldIcon = marker.icon;
        final oldShadow = marker.shadow;

        marker.setIcon(icon2);

        expect(oldIcon, equals(marker.icon));
        expect(oldShadow, equals(marker.shadow));

        expect(marker.icon.parentNode, equals(map.panes['markerPane']));
        expect(marker.shadow.parentNode, equals(map.panes['shadowPane']));
      });
    });
  });
}

main() {
  useHtmlEnhancedConfiguration();
  markerTest();
}
