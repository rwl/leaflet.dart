part of leaflet.control;

class AttributionOptions {
  // The position of the control (one of the map corners). See control positions.
  ControlPosition position = ControlPosition.BOTTOMRIGHT;
  // The HTML text shown before the attributions. Pass false to disable.
  String  prefix = 'Leaflet';
}

// Attribution is used for displaying attribution on the map (added by default).
class Attribution extends Control {

  final Map<String, Object> options = {
    'position': 'bottomright',
    'prefix': '<a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>'
  };

  Map _attributions;

  Attribution(Map<String, Object> options) : super(options) {
    this.options.addAll(options);

    this._attributions = {};
  }

  onAdd(map) {
    this._container = DomUtil.create('div', 'leaflet-control-attribution');
    DomEvent.disableClickPropagation(this._container);

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
    this.options['prefix'] = prefix;
    this._update();
    return this;
  }

  addAttribution(String text) {
    if (text == null) { return null; }

    if (!this._attributions[text]) {
      this._attributions[text] = 0;
    }
    this._attributions[text]++;

    this._update();

    return this;
  }

  removeAttribution(text) {
    if (text == null) { return null; }

    if (this._attributions[text]) {
      this._attributions[text]--;
      this._update();
    }

    return this;
  }

  _update() {
    if (this._map == null) { return; }

    var attribs = [];

    for (var i in this._attributions) {
      if (this._attributions[i]) {
        attribs.add(i);
      }
    }

    var prefixAndAttribs = [];

    if (this.options.containsKey('prefix')) {
      prefixAndAttribs.add(this.options['prefix']);
    }
    if (attribs.length) {
      prefixAndAttribs.add(attribs.join(', '));
    }

    this._container.innerHTML = prefixAndAttribs.join(' | ');
  }

  _onLayerAdd(e) {
    if (e.layer.getAttribution != null) {
      this.addAttribution(e.layer.getAttribution());
    }
  }

  _onLayerRemove(e) {
    if (e.layer.getAttribution != null) {
      this.removeAttribution(e.layer.getAttribution());
    }
  }
}