import 'dart:html';
import 'package:leaflet/map/map.dart';
import 'package:leaflet/layer/tile/tile.dart';
import 'package:leaflet/geo/geo.dart';

void main() {
  var map = new LeafletMap(querySelector('#map'),
      new MapOptions()
          ..layers=[new TileLayer('http://a.tile.openstreetmap.org/{z}/{x}/{y}.png')]
          ..minZoom = 5
          ..maxZoom = 15
          ..zoomAnimation = false)
      ..setView(new LatLng(52.520007, 13.404954), 13);
}
