import 'dart:math' show Random;
import 'package:leaflet/leaflet.dart';

LatLng getRandomLatLng(LeafletMap map) {
  final bounds = map.getBounds(),
    southWest = bounds.getSouthWest(),
    northEast = bounds.getNorthEast(),
    lngSpan = northEast.lng - southWest.lng,
    latSpan = northEast.lat - southWest.lat,
    r = new Random();

  return new LatLng(
      southWest.lat + latSpan * r.nextDouble(),
      southWest.lng + lngSpan * r.nextDouble());
}

final osmTileLayer = new TileLayer(osmTileUrl, new TileLayerOptions()
  ..attribution = '© <a href="http://openstreetmap.org">OpenStreetMap</a> contributors');

final osmMapQuestLayer = new TileLayer(mapQuestUrl, new TileLayerOptions()
  ..subdomains = ['1', '2', '3', '4']
  ..attribution = '© <a href="http://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>. Tiles courtesy of <a href="http://www.mapquest.com/">MapQuest</a>');
