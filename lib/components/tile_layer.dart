library leaflet.components.tile_layer;

import 'dart:async';

import 'package:polymer/polymer.dart';

import 'package:leaflet/leaflet.dart';

@CustomTag('tile-layer')
class TileLayerElement extends PolymerElement {
  @published String url;

  TileLayer _layer;

  TileLayer get layer => _layer;

  TileLayerElement.created() : super.created();

  void ready() {
    Polymer.onReady.then((_) {
      return new Future(_polymerReady);
    });
  }

  void _polymerReady() {
    _layer = new TileLayer(url);
  }
}
