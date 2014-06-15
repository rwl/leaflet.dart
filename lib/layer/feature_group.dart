part of leaflet.layer;

/**
 * FeatureGroup extends LayerGroup by introducing mouse events and additional methods
 * shared between a group of interactive layers (like vectors or markers).
 */
class FeatureGroup extends LayerGroup with core.Events {

  static final EVENTS = [EventType.CLICK, EventType.DBLCLICK, EventType.MOUSEOVER,
    EventType.MOUSEOUT, EventType.MOUSEMOVE, EventType.CONTEXTMENU,
    EventType.POPUPOPEN, EventType.POPUPCLOSE];

  var _popupContent, _popupOptions;

  /**
   * Create a layer group, optionally given an initial set of layers.
   */
  FeatureGroup([List<Layer> layers=null]) : super(layers);

  addLayer(layer) {
    if (this.hasLayer(layer)) {
      return this;
    }

    if (layer.contains('on')) {
      layer.on(FeatureGroup.EVENTS, this._propagateEvent, this);
    }

    super.addLayer(layer);

    if (this._popupContent != null && layer.bindPopup != null) {
      layer.bindPopup(this._popupContent, this._popupOptions);
    }

    return this.fire(EventType.LAYERADD, {'layer': layer});
  }

  removeLayer(layer) {
    if (!this.hasLayer(layer)) {
      return this;
    }
    if (this._layers.containsKey(layer)) {
      layer = this._layers[layer];
    }

    layer.off(FeatureGroup.EVENTS, this._propagateEvent, this);

    super.removeLayer(layer);

    if (this._popupContent) {
//      this.invoke('unbindPopup');
      this.eachLayer((layer) {
        layer.unbindPopup();
      });
    }

    return this.fire('layerremove', {layer: layer});
  }

  /**
   * Binds a popup with a particular HTML content to a click on any layer from the group that has a bindPopup method.
   */
  bindPopup(String content, PopupOptions options) {
    this._popupContent = content;
    this._popupOptions = options;
    //return this.invoke('bindPopup', content, options);
    this.eachLayer((layer) {
      layer.bindPopup(content, options);
      //content.bindPopup(layer, options);
    });
  }

  openPopup(latlng) {
    // Open popup on the first layer.
    for (String id in this._layers) {
      this._layers[id].openPopup(latlng);
      break;
    }
    return this;
  }

  /**
   * Sets the given path options to each layer of the group that has a setStyle method.
   */
  setStyle(PathOptions style) {
    //return this.invoke('setStyle', style);
    this.eachLayer((layer) {
      layer.setStyle(style);
    });
  }

  /**
   * Brings the layer group to the top of all other layers.
   */
  bringToFront() {
    //return this.invoke('bringToFront');
    this.eachLayer((layer) {
      layer.bringToFront();
    });
  }

  /**
   * Brings the layer group to the bottom of all other layers.
   */
  bringToBack() {
    //return this.invoke('bringToBack');
    this.eachLayer((layer) {
      layer.bringToBack();
    });
  }

  /**
   * Returns the LatLngBounds of the Feature Group (created from bounds and coordinates of its children).
   */
  getBounds() {
    var bounds = new LatLngBounds();

    this.eachLayer((layer) {
      bounds.extend(layer is Marker ? layer.getLatLng() : layer.getBounds());
    });

    return bounds;
  }

  _propagateEvent(Event e) {
    final ee = e.copy();
    ee.layer = e.target;
    ee.target = this;
    this.fire(ee.type, ee);
  }
}
