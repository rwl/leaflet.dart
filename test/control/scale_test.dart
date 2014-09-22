part of leaflet.control.test;

scaleTest() {
  group('Scale', () {
    test('can be added to an unloaded map', () {
      final map = new LeafletMap(document.createElement('div'));
      new Scale()..addTo(map);
    });
  });
}
