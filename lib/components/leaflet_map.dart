library leaflet.components.map;

//import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';

import 'package:leaflet/leaflet.dart';
import 'tile_layer.dart';
import 'leaflet_marker.dart';

@CustomTag('leaflet-map')
class LeafletMapElement extends PolymerElement {
  @published num lat;
  @published num lng;
  @published num zoom;
  @published bool zoomControl;

  LeafletMap _map;

  LeafletMap get map => _map;

  LeafletMapElement.created() : super.created();

  void ready() {
    Polymer.onReady.then((_) {
      return new Future(_polymerReady);
    });
  }

  void _polymerReady() {
    var options = new MapOptions();
    if (zoomControl != null) {
      options.zoomControl = zoomControl;
    }

    _map = new LeafletMap(this.$['map'], options);

    for (TileLayerElement elem in layers) {
      _map.addLayer(elem.layer);
    }

    for (LeafletMarker elem in markers) {
      _map.addLayer(elem.marker);
    }

    if (lat != null && lng != null) {
      if (zoom != null) {
        _map.setView(new LatLng(lat, lng), zoom);
      } else {
        _map.panTo(new LatLng(lat, lng));
      }
    }
  }

  List<TileLayerElement> get layers => this.$['tile-layers'].getDistributedNodes();

  List<LeafletMarker> get markers => this.$['markers'].getDistributedNodes();
}
