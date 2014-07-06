part of leaflet.layer;

/**
 * FeatureGroup extends LayerGroup by introducing mouse events and additional methods
 * shared between a group of interactive layers (like vectors or markers).
 */
class FeatureGroup extends LayerGroup {

  static final EVENTS = [EventType.CLICK, EventType.DBLCLICK,
    EventType.MOUSEOVER, EventType.MOUSEOUT, EventType.MOUSEMOVE,
    EventType.CONTEXTMENU, EventType.POPUPOPEN, EventType.POPUPCLOSE];

  var _popupContent, _popupOptions;

  /**
   * Create a layer group, optionally given an initial set of layers.
   */
  FeatureGroup([List<Layer> layers = null]) : super(layers);

  void addLayer(Layer layer) {
    if (hasLayer(layer)) {
      return;
    }

    if (layer is Events) {
      layer.on(FeatureGroup.EVENTS, _propagateEvent);
    }

    super.addLayer(layer);

    if (_popupContent != null && layer.bindPopup != null) {
      layer.bindPopup(_popupContent, _popupOptions);
    }

    //fireEvent(new LayerEvent(EventType.LAYERADD, layer));
    _layerAddController.add(new LayerEvent(EventType.LAYERADD, layer));
  }

  void removeLayer(Layer layer) {
    if (!hasLayer(layer)) {
      return;
    }
    if (_layers.containsKey(layer)) {
      layer = _layers[layer];
    }

    layer.off(FeatureGroup.EVENTS, _propagateEvent);

    super.removeLayer(layer);

    if (_popupContent) {
      //      invoke('unbindPopup');
      eachLayer((layer) {
        layer.unbindPopup();
      });
    }

    //fireEvent(new LayerEvent(EventType.LAYERREMOVE, layer));
    _layerRemoveController.add(new LayerEvent(EventType.LAYERREMOVE, layer));
  }

  /**
   * Binds a popup with a particular HTML content to a click on any layer from the group that has a bindPopup method.
   */
  bindPopup(String content, [PopupOptions options=null]) {
    if (options == null) {
      options = new PopupOptions();
    }
    _popupContent = content;
    _popupOptions = options;
    //return invoke('bindPopup', content, options);
    eachLayer((layer) {
      layer.bindPopup(content, options);
      //content.bindPopup(layer, options);
    });
  }

  openPopup(latlng) {
    // Open popup on the first layer.
    for (String id in _layers) {
      _layers[id].openPopup(latlng);
      break;
    }
    return this;
  }

  /**
   * Sets the given path options to each layer of the group that has a setStyle method.
   */
  setStyle(PathOptions style) {
    //return invoke('setStyle', style);
    eachLayer((layer) {
      layer.setStyle(style);
    });
  }

  /**
   * Brings the layer group to the top of all other layers.
   */
  bringToFront() {
    //return invoke('bringToFront');
    eachLayer((layer) {
      layer.bringToFront();
    });
  }

  /**
   * Brings the layer group to the bottom of all other layers.
   */
  bringToBack() {
    //return invoke('bringToBack');
    eachLayer((layer) {
      layer.bringToBack();
    });
  }

  /**
   * Returns the LatLngBounds of the Feature Group (created from bounds and coordinates of its children).
   */
  getBounds() {
    var bounds = new LatLngBounds.between();

    eachLayer((layer) {
      bounds.extend(layer is Marker ? layer.getLatLng() : layer.getBounds());
    });

    return bounds;
  }

  _propagateEvent(Event e) {
    final ee = e.copy();
    ee.layer = e.target;
    ee.target = this;
    fire(ee.type, ee);
  }

  StreamController<MouseEvent> _clickController = new StreamController.broadcast();
  StreamController<MouseEvent> _dblClickController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseMoveController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOverController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOutController = new StreamController.broadcast();
  StreamController<MouseEvent> _contextMenuController = new StreamController.broadcast();
  StreamController<LayerEvent> _layerAddController = new StreamController.broadcast();
  StreamController<LayerEvent> _layerRemoveController = new StreamController.broadcast();

  Stream<MouseEvent> get onClick => _clickController.stream;
  Stream<MouseEvent> get onDblClick => _dblClickController.stream;
  Stream<MouseEvent> get onMouseMove => _mouseMoveController.stream;
  Stream<MouseEvent> get onMouseOver => _mouseOverController.stream;
  Stream<MouseEvent> get onMouseOut => _mouseOutController.stream;
  Stream<MouseEvent> get onContextMenu => _contextMenuController.stream;
  Stream<LayerEvent> get onLayerAdd => _layerAddController.stream;
  Stream<LayerEvent> get onLayerRemove => _layerRemoveController.stream;
}
