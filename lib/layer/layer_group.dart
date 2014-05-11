part of leaflet.layer;

typedef LayerFunc(var layer);

// LayerGroup is a class to combine several layers into one so that
// you can manipulate the group (e.g. add/remove it) as one layer.
class LayerGroup {
  Map _layers;
  BaseMap _map;

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

  addLayer(String layer) {
    var id = this.getLayerId(layer);

    this._layers[id] = layer;

    if (this._map != null) {
      this._map.addLayer(layer);
    }

    return this;
  }

  removeLayer(String layer) {
    var id = this._layers.containsKey(layer) ? layer : this.getLayerId(layer);

    if (this._map && this._layers[id]) {
      this._map.removeLayer(this._layers[id]);
    }

    this._layers.remove(id);

    return this;
  }

  hasLayer(String layer) {
    if (layer == null) { return false; }

    return (this._layers.containsKey(layer) || this._layers.containsKey(this.getLayerId(layer)));
  }

  clearLayers() {
    //this.eachLayer(this.removeLayer, this);
    this.eachLayer((layer) {
      this.removeLayer(layer);
    });
    return this;
  }

  /*invoke(methodName) {
    var args = Array.prototype.slice.call(arguments, 1);
    var i, layer;

    for (i in this._layers) {
      layer = this._layers[i];

      if (layer[methodName]) {
        layer[methodName].apply(layer, args);
      }
    }

    return this;
  }*/

  onAdd(BaseMap map) {
    this._map = map;
    //this.eachLayer(map.addLayer, map);
    this.eachLayer((layer) {
      map.addLayer(layer);
    });
  }

  onRemove(BaseMap map) {
    //this.eachLayer(map.removeLayer, map);
    this.eachLayer((layer) {
      map.removeLayer(layer);
    });
    this._map = null;
  }

  addTo(BaseMap map) {
    map.addLayer(this);
    return this;
  }

  /*eachLayer(method, context) {
    for (var i in this._layers) {
      method.call(context, this._layers[i]);
    }
    return this;
  }*/

  eachLayer(LayerFunc fn) {
    this._layers.forEach((i, layer) {
      fn(layer);
    });
  }

  getLayer(id) {
    return this._layers[id];
  }

  getLayers() {
    var layers = [];

    for (var i in this._layers) {
      layers.add(this._layers[i]);
    }
    return layers;
  }

  setZIndex(zIndex) {
    //return this.invoke('setZIndex', zIndex);
    eachLayer((layer) {
      layer.setZIndex(zIndex);
    });
    return this;
  }

  getLayerId(layer) {
    return Util.stamp(layer);
  }
}
