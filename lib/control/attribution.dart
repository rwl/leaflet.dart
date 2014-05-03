
// Attribution is used for displaying attribution on the map (added by default).
class Attribution extends Control {
  var options = {
    'position': 'bottomright',
    'prefix': '<a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
  };

  Attribution(options) {
    L.setOptions(this, options);

    this._attributions = {};
  }

  onAdd(map) {
    this._container = L.DomUtil.create('div', 'leaflet-control-attribution');
    L.DomEvent.disableClickPropagation(this._container);

    for (var i in map._layers) {
      if (map._layers[i].getAttribution) {
        this.addAttribution(map._layers[i].getAttribution());
      }
    }

    map
        .on('layeradd', this._onLayerAdd, this)
        .on('layerremove', this._onLayerRemove, this);

    this._update();

    return this._container;
  }

  onRemove(map) {
    map
        .off('layeradd', this._onLayerAdd)
        .off('layerremove', this._onLayerRemove);

  }

  setPrefix(prefix) {
    this.options.prefix = prefix;
    this._update();
    return this;
  }

  addAttribution(text) {
    if (!text) { return; }

    if (!this._attributions[text]) {
      this._attributions[text] = 0;
    }
    this._attributions[text]++;

    this._update();

    return this;
  }

  removeAttribution(text) {
    if (!text) { return; }

    if (this._attributions[text]) {
      this._attributions[text]--;
      this._update();
    }

    return this;
  }

  _update() {
    if (!this._map) { return; }

    var attribs = [];

    for (var i in this._attributions) {
      if (this._attributions[i]) {
        attribs.push(i);
      }
    }

    var prefixAndAttribs = [];

    if (this.options.prefix) {
      prefixAndAttribs.push(this.options.prefix);
    }
    if (attribs.length) {
      prefixAndAttribs.push(attribs.join(', '));
    }

    this._container.innerHTML = prefixAndAttribs.join(' | ');
  }

  _onLayerAdd(e) {
    if (e.layer.getAttribution) {
      this.addAttribution(e.layer.getAttribution());
    }
  }

  _onLayerRemove(e) {
    if (e.layer.getAttribution) {
      this.removeAttribution(e.layer.getAttribution());
    }
  }
}