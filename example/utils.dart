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
