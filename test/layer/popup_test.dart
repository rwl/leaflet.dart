part of leaflet.layer.test;

popupTest() {
  group('Popup', () {
    Element c;
    LeafletMap map;

    setUp(() {
      c = document.createElement('div');
      c.style.width = '400px';
      c.style.height = '400px';
      map = new LeafletMap(c);
      map.setView(new LatLng(55.8, 37.6), 6);
    });

    test('closes on map click when map has closePopupOnClick option', () {
      map.options.closePopupOnClick = true;

      final popup = new Popup()
        ..setLatLng(new LatLng(55.8, 37.6))
        ..openOn(map);

      //happen.click(c);
      c.dispatchEvent(new html.MouseEvent('click'));

      expect(map.hasLayer(popup), isFalse);
    });

    test('closes on map click when popup has closeOnClick option', () {
      map.options.closePopupOnClick = false;

      final popup = new Popup(new PopupOptions()..closeOnClick = true)
        ..setLatLng(new LatLng(55.8, 37.6))
        ..openOn(map);

      //happen.click(c);
      c.dispatchEvent(new html.MouseEvent('click'));

      expect(map.hasLayer(popup), isFalse);
    });

    test('does not close on map click when popup has closeOnClick: false option', () {
      map.options.closePopupOnClick = true;

      final popup = new Popup(new PopupOptions()..closeOnClick = false)
        ..setLatLng(new LatLng(55.8, 37.6))
        ..openOn(map);

      //happen.click(c);
      c.dispatchEvent(new html.MouseEvent('click'));

      expect(map.hasLayer(popup), isTrue);
    });

    test('toggles its visibility when marker is clicked', () {
      final marker = new TestMarker(new LatLng(55.8, 37.6));
      map.addLayer(marker);

      marker..bindPopupContent('Popup1')..openPopup();

      map.options.closePopupOnClick = true;
      //happen.click(c);
      c.dispatchEvent(new html.MouseEvent('click'));

      // toggle open popup
      marker.fire(EventType.CLICK);
      expect(marker.openCallCount, equals(1));
      expect(map.hasLayer(marker.markerPopup), isTrue);

      // toggle close popup
      marker.fire(EventType.CLICK);
      expect(marker.closeCallCount, equals(1));
      expect(map.hasLayer(marker.markerPopup), isFalse);
    });

    test('should trigger popupopen on marker when popup opens', () {
      final marker1 = new Marker(new LatLng(55.8, 37.6));
      final marker2 = new Marker(new LatLng(57.123076977278, 44.861962891635));

      map.addLayer(marker1);
      map.addLayer(marker2);

      marker1.bindPopupContent('Popup1');
      marker2.bindPopupContent('Popup2');

      var called = false;
      marker1.onPopupOpen.listen((_) => called = true);

      expect(called, isFalse);
      marker2.openPopup();
      expect(called, isFalse);
      marker1.openPopup();
      expect(called, isTrue);
    });

    test('should trigger popupclose on marker when popup closes', () {
      final marker1 = new Marker(new LatLng(55.8, 37.6));
      final marker2 = new Marker(new LatLng(57.123076977278, 44.861962891635));

      map.addLayer(marker1);
      map.addLayer(marker2);

      marker1.bindPopupContent('Popup1');
      marker2.bindPopupContent('Popup2');

      var called = false;
      var callCount = 0;
      marker1.onPopupClose.listen((_) {
        called = true;
        callCount++;
      });

      expect(called, isFalse);
      marker2.openPopup();
      expect(called, isFalse);
      marker1.openPopup();
      expect(called, isFalse);
      marker2.openPopup();
      expect(called, isTrue);
      marker1.openPopup();
      marker1.closePopup();
      expect(callCount, equals(2));
    });
  });
}

class TestMarker extends Marker {
  int openCallCount = 0;
  int closeCallCount = 0;

  TestMarker(LatLng latlng, [options]) : super(latlng, options);

  openPopup() {
    openCallCount++;
    super.openPopup();
  }

  void closePopup([_]) {
    closeCallCount++;
    super.closePopup();
  }
}
