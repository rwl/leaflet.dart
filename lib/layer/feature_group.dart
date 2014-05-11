part of leaflet.layer;

// FeatureGroup extends LayerGroup by introducing mouse events and additional methods
// shared between a group of interactive layers (like vectors or markers).
class FeatureGroup extends LayerGroup with Events {

  static final EVENTS = 'click dblclick mouseover mouseout mousemove contextmenu popupopen popupclose';

  var _popupContent, _popupOptions;

  FeatureGroup(List layers) : super(layers);

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

    return this.fire('layeradd', {'layer': layer});
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

  bindPopup(content, options) {
    this._popupContent = content;
    this._popupOptions = options;
    //return this.invoke('bindPopup', content, options);
    this.eachLayer((layer) {
      layer.bindPopup(content, options);
      //content.bindPopup(layer, options);
    });
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
    //return this.invoke('setStyle', style);
    this.eachLayer((layer) {
      layer.setStyle(style);
    });
  }

  bringToFront() {
    //return this.invoke('bringToFront');
    this.eachLayer((layer) {
      layer.bringToFront();
    });
  }

  bringToBack() {
    //return this.invoke('bringToBack');
    this.eachLayer((layer) {
      layer.bringToBack();
    });
  }

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
