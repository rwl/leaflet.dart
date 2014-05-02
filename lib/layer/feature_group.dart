library leaflet.layer;

import '../core/events.dart';

// FeatureGroup extends LayerGroup by introducing mouse events and additional methods
// shared between a group of interactive layers (like vectors or markers).
class FeatureGroup extends Object with Events {
  static var EVENTS = 'click dblclick mouseover mouseout mousemove contextmenu popupopen popupclose';

  addLayer(layer) {
    if (this.hasLayer(layer)) {
      return this;
    }

    if (layer.contains('on')) {
      layer.on(L.FeatureGroup.EVENTS, this._propagateEvent, this);
    }

    L.LayerGroup.prototype.addLayer.call(this, layer);

    if (this._popupContent && layer.bindPopup) {
      layer.bindPopup(this._popupContent, this._popupOptions);
    }

    return this.fire('layeradd', {'layer': layer});
  }

  removeLayer(layer) {
    if (!this.hasLayer(layer)) {
      return this;
    }
    if (this._layers.contains(layer)) {
      layer = this._layers[layer];
    }

    layer.off(L.FeatureGroup.EVENTS, this._propagateEvent, this);

    L.LayerGroup.prototype.removeLayer.call(this, layer);

    if (this._popupContent) {
      this.invoke('unbindPopup');
    }

    return this.fire('layerremove', {layer: layer});
  }

  bindPopup(content, options) {
    this._popupContent = content;
    this._popupOptions = options;
    return this.invoke('bindPopup', content, options);
  }

  openPopup(latlng) {
    // open popup on the first layer
    for (var id in this._layers) {
      this._layers[id].openPopup(latlng);
      break;
    }
    return this;
  }

  setStyle(style) {
    return this.invoke('setStyle', style);
  }

  bringToFront() {
    return this.invoke('bringToFront');
  }

  bringToBack() {
    return this.invoke('bringToBack');
  }

  getBounds() {
    var bounds = new L.LatLngBounds();

    this.eachLayer((layer) {
      bounds.extend(layer is Marker ? layer.getLatLng() : layer.getBounds());
    });

    return bounds;
  }

  _propagateEvent(e) {
    e = L.extend({
      'layer': e.target,
      'target': this
    }, e);
    this.fire(e.type, e);
  }
}
