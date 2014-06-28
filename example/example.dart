import 'dart:html';
import 'package:leaflet/map/map.dart';
import 'package:leaflet/layer/tile/tile.dart';
import 'package:leaflet/geo/geo.dart';

void main() {
  var map = new LeafletMap(querySelector('#map'),
      stateOptions: new MapStateOptions()
          ..layers=[new TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')])
      ..setView(new LatLng(51.505, -0.09), 13);
}
