part of leaflet.layer;

typedef LayerFunc(var layer);

/**
 * LayerGroup is a class to combine several layers into one so that
 * you can manipulate the group (e.g. add/remove it) as one layer.
 */
class LayerGroup {

  Map<String, Layer> _layers;
  BaseMap _map;

  /**
   * Create a layer group, optionally given an initial set of layers.
   */
  LayerGroup([List<Layer> layers=null]) {
    _layers = {};

    if (layers != null) {
      for (int i = 0; i < layers.length; i++) {
        addLayer(layers[i]);
      }
    }
  }

  /**
   * Adds a given layer to the group.
   */
  addLayer(Layer layer) {
    var id = getLayerId(layer);

    _layers[id] = layer;

    if (_map != null) {
      _map.addLayer(layer);
    }

    return this;
  }

  /**
   * Removes a given layer from the group.
   */
  removeLayer(Layer layer) {
    var id = getLayerId(layer);
    removeLayerId(id);
  }

  /**
   * Removes a given layer of the given id from the group.
   */
  removeLayerId(String id) {
    if (_map && _layers[id]) {
      _map.removeLayer(_layers[id]);
    }

    _layers.remove(id);
  }

  /**
   * Returns true if the given layer is currently added to the group.
   */
  hasLayer(String layer) {
    if (layer == null) { return false; }

    return (_layers.containsKey(layer) || _layers.containsKey(getLayerId(layer)));
  }

  /**
   * Removes all the layers from the group.
   */
  clearLayers() {
    eachLayer((layer) {
      removeLayer(layer);
    });
    return this;
  }

  onAdd(BaseMap map) {
    _map = map;
    eachLayer((layer) {
      map.addLayer(layer);
    });
  }

  onRemove(BaseMap map) {
    eachLayer((layer) {
      map.removeLayer(layer);
    });
    _map = null;
  }

  /**
   * Adds the group of layers to the map.
   */
  addTo(BaseMap map) {
    map.addLayer(this);
  }

  /**
   * Iterates over the layers of the group.
   */
  eachLayer(LayerFunc fn) {
    _layers.forEach((i, layer) {
      fn(layer);
    });
  }

  /**
   * Returns the layer with the given id.
   */
  getLayer(String id) {
    return _layers[id];
  }

  /**
   * Returns an array of all the layers added to the group.
   */
  List<Layer> getLayers() {
    return _layers.values;
  }

  setZIndex(zIndex) {
    eachLayer((layer) {
      layer.setZIndex(zIndex);
    });
  }

  getLayerId(layer) {
    return Util.stamp(layer);
  }

  toGeoJSON() {

    var geometry = feature && feature.geometry;
    List jsons = [];
    var json;

    if (geometry && geometry.type == 'MultiPoint') {
      return multiToGeoJSON('MultiPoint').call(this);
    }

    var isGeometryCollection = geometry && geometry.type == 'GeometryCollection';

    eachLayer((layer) {
      if (layer.toGeoJSON) {
        json = layer.toGeoJSON();
        jsons.add(isGeometryCollection ? json.geometry : GeoJSON.asFeature(json));
      }
    });

    if (isGeometryCollection) {
      return GeoJSON.getFeature(this, {
        'geometries': jsons,
        'type': 'GeometryCollection'
      });
    }

    return {
      'type': 'FeatureCollection',
      'features': jsons
    };
  }
}
