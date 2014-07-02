part of leaflet.layer;

typedef LayerFunc(var layer);

class _LayerList extends DelegatingList<Layer> {
  final LayerGroup _group;
  final List<Layer> _list = <Layer>[];

  _LayerList(this._group);

  List get delegate => _list;

  @override
  add(Layer value) {
    super.add(value);
    if (_group._map != null) {
      _group._map.addLayer(value);
    }
  }
}

/**
 * LayerGroup is a class to combine several layers into one so that
 * you can manipulate the group (e.g. add/remove it) as one layer.
 */
class LayerGroup extends Layer {

//  Map<int, Layer> _layers;
  _LayerList _layers;
  List<Layer> get layers => _layers;
  LeafletMap _map;

  /**
   * Create a layer group, optionally given an initial set of layers.
   */
  LayerGroup([List<Layer> layers]) {
    _layers = new _LayerList(this);
    if (layers != null) _layers.addAll(layers);
  }

  /**
   * Adds a given layer to the group.
   */
  void addLayer(Layer layer) {
    final id = getLayerId(layer);

    _layers[id] = layer;

  }

  /**
   * Removes a given layer from the group.
   */
  void removeLayer(Layer layer) {
    final id = getLayerId(layer);
    removeLayerId(id);
  }

  /**
   * Removes a given layer of the given id from the group.
   */
  void removeLayerId(int id) {
    if (_map != null && _layers[id] != null) {
      _map.removeLayer(_layers[id]);
    }

    _layers.remove(id);
  }

  /**
   * Returns true if the given layer is currently added to the group.
   */
  /*bool hasLayer(String layer) {
    if (layer == null) { return false; }

    return (_layers.containsKey(layer) || _layers.containsKey(getLayerId(layer)));
  }*/
  bool hasLayer(Layer layer) {
    if (layer == null) { return false; }

    return _layers.contains(layer);
//    return _layers.containsKey(getLayerId(layer));
  }

  /**
   * Removes all the layers from the group.
   */
  void clearLayers() {
    eachLayer((layer) {
      removeLayer(layer);
    });
  }

  void onAdd(LeafletMap map) {
    _map = map;
    eachLayer((layer) {
      map.addLayer(layer);
    });
  }

  void onRemove(LeafletMap map) {
    eachLayer((layer) {
      map.removeLayer(layer);
    });
    _map = null;
  }

  /**
   * Adds the group of layers to the map.
   */
  void addTo(LeafletMap map) {
    map.addLayer(this);
  }

  /**
   * Iterates over the layers of the group.
   */
  void eachLayer(LayerFunc fn) {
    _layers.forEach((i, layer) {
      fn(layer);
    });
  }

  /**
   * Returns the layer with the given id.
   */
  Layer getLayer(String id) {
    return _layers[id];
  }

  /**
   * Returns an array of all the layers added to the group.
   */
  List<Layer> getLayers() {
    return _layers.values;
  }

  void setZIndex(zIndex) {
    eachLayer((layer) {
      layer.setZIndex(zIndex);
    });
  }

  int getLayerId(layer) {
    return stamp(layer);
  }

  var feature;

  toGeoJSON() {

    var geometry = feature != null ? feature.geometry : null;
    List jsons = [];
    var json;

    if (geometry != null && geometry.type == 'MultiPoint') {
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
