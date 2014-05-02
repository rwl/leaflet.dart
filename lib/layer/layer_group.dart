library leaflet.layer;

// LayerGroup is a class to combine several layers into one so that
// you can manipulate the group (e.g. add/remove it) as one layer.
class LayerGroup {
  LayerGroup(layers) {
    this._layers = {};

    var i, len;

    if (layers) {
      len = layers.length;
      for (i = 0; i < len; i++) {
        this.addLayer(layers[i]);
      }
    }
  }

  addLayer(layer) {
    var id = this.getLayerId(layer);

    this._layers[id] = layer;

    if (this._map) {
      this._map.addLayer(layer);
    }

    return this;
  }

  removeLayer(layer) {
    var id = this._layers.contains(layer) ? layer : this.getLayerId(layer);

    if (this._map && this._layers[id]) {
      this._map.removeLayer(this._layers[id]);
    }

    delete(this._layers[id]);

    return this;
  }

  hasLayer(layer) {
    if (!layer) { return false; }

    return (this._layers.contains(layer) || this._layers.contains(this.getLayerId(layer)));
  }

  clearLayers() {
    this.eachLayer(this.removeLayer, this);
    return this;
  }

  invoke(methodName) {
    var args = Array.prototype.slice.call(arguments, 1),
        i, layer;

    for (i in this._layers) {
      layer = this._layers[i];

      if (layer[methodName]) {
        layer[methodName].apply(layer, args);
      }
    }

    return this;
  }

  onAdd(map) {
    this._map = map;
    this.eachLayer(map.addLayer, map);
  }

  onRemove(map) {
    this.eachLayer(map.removeLayer, map);
    this._map = null;
  }

  addTo(map) {
    map.addLayer(this);
    return this;
  }

  eachLayer(method, context) {
    for (var i in this._layers) {
      method.call(context, this._layers[i]);
    }
    return this;
  }

  getLayer(id) {
    return this._layers[id];
  }

  getLayers() {
    var layers = [];

    for (var i in this._layers) {
      layers.push(this._layers[i]);
    }
    return layers;
  }

  setZIndex(zIndex) {
    return this.invoke('setZIndex', zIndex);
  }

  getLayerId(layer) {
    return L.stamp(layer);
  }
}
