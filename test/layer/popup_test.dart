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
      final marker = new Marker(new LatLng(55.8, 37.6));
      map.addLayer(marker);

      marker..bindPopup('Popup1')..openPopup();

      map.options.closePopupOnClick = true;
      //happen.click(c);
      c.dispatchEvent(new html.MouseEvent('click'));

      // toggle open popup
      sinon.spy(marker, 'openPopup');
      marker.fire(EventType.CLICK);
      expect(marker.openPopup.calledOnce, isTrue);
      expect(map.hasLayer(marker._popup), isTrue);
      marker.openPopup.restore();

      // toggle close popup
      sinon.spy(marker, 'closePopup');
      marker.fire(EventType.CLICK);
      expect(marker.closePopup.calledOnce, isTrue);
      expect(map.hasLayer(marker._popup), isFalse);
      marker.closePopup.restore();
    });

    test('should trigger popupopen on marker when popup opens', () {
      final marker1 = new Marker(new LatLng(55.8, 37.6));
      final marker2 = new Marker(new LatLng(57.123076977278, 44.861962891635));

      map.addLayer(marker1);
      map.addLayer(marker2);

      marker1.bindPopup('Popup1');
      marker2.bindPopup('Popup2');

      var spy = sinon.spy();

      marker1.onPopupOpen.listen(spy);

      expect(spy.called, isFalse);
      marker2.openPopup();
      expect(spy.called, isFalse);
      marker1.openPopup();
      expect(spy.called, isTrue);
    });

    test('should trigger popupclose on marker when popup closes', () {
      final marker1 = new Marker(new LatLng(55.8, 37.6));
      final marker2 = new Marker(new LatLng(57.123076977278, 44.861962891635));

      map.addLayer(marker1);
      map.addLayer(marker2);

      marker1.bindPopup('Popup1');
      marker2.bindPopup('Popup2');

      var spy = sinon.spy();

      marker1.onPopupClose.listen(spy);

      expect(spy.called, isFalse);
      marker2.openPopup();
      expect(spy.called, isFalse);
      marker1.openPopup();
      expect(spy.called, isFalse);
      marker2.openPopup();
      expect(spy.called, isTrue);
      marker1.openPopup();
      marker1.closePopup();
      expect(spy.callCount, equals(2));
    });
  });
}