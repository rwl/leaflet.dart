library leaflet.components.map;

import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';

import 'package:leaflet/leaflet.dart';

@CustomTag('leaflet-marker')
class LeafletMarker extends PolymerElement {
  @published num lat;
  @published num lng;

  Marker _marker;

  Marker get marker => _marker;

  LeafletMarker.created() : super.created();

  void ready() {
    Polymer.onReady.then((_) {
      return new Future(_polymerReady);
    });
  }

  void _polymerReady() {
    _marker = new Marker(new LatLng(lat, lng));
  }
}
