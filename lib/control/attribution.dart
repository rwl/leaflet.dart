part of leaflet.control;

class AttributionOptions extends ControlOptions {
  /**
   * The position of the control (one of the map corners). See control positions.
   */
  ControlPosition position = ControlPosition.BOTTOMRIGHT;

  /**
   * The HTML text shown before the attributions. Set null to disable.
   */
  String prefix = '<a href="http://leafletjs.com" title="A JS library for interactive maps">Leaflet</a>';
}

/**
 * Attribution is used for displaying attribution on the map (added by default).
 */
class Attribution extends Control {

  AttributionOptions get attributionOptions => options as AttributionOptions;

  Map<String, int> _attributions;

  Attribution(AttributionOptions options) : super(options) {
    _attributions = {};
  }

  onAdd(LeafletMap map) {
    _container = dom.create('div', 'leaflet-control-attribution');
    dom.disableClickPropagation(_container);

    map.eachLayer((Layer layer) {
      final att = layer.getAttribution();
      if (att != null) {
        addAttribution(att);
      }
    });

    map.on(EventType.LAYERADD, _onLayerAdd);
    map.on(EventType.LAYERREMOVE, _onLayerRemove);

    _update();

    return _container;
  }

  onRemove(LeafletMap map) {
    map.off(EventType.LAYERADD, _onLayerAdd);
    map.off(EventType.LAYERREMOVE, _onLayerRemove);
  }

  /**
   * Sets the text before the attributions.
   */
  setPrefix(String prefix) {
    attributionOptions.prefix = prefix;
    _update();
  }

  /**
   * Adds an attribution text (e.g. 'Vector data &copy; Mapbox').
   */
  void addAttribution(String text) {
    if (text == null) {
      return;
    }

    if (!_attributions.containsKey(text)) {
      _attributions[text] = 0;
    }
    _attributions[text]++;

    _update();
  }

  /**
   * Removes an attribution text.
   */
  void removeAttribution(String text) {
    if (text == null) {
      return;
    }

    if (_attributions.containsKey(text)) {
      _attributions[text]--;
      _update();
    }
  }

  void _update() {
    if (_map == null) {
      return;
    }

    final attribs = _attributions.values;
    final prefixAndAttribs = [];

    if (attributionOptions.prefix != null) {
      prefixAndAttribs.add(attributionOptions.prefix);
    }
    if (attribs.length) {
      prefixAndAttribs.add(attribs.join(', '));
    }

    _container.setInnerHtml(prefixAndAttribs.join(' | '));
  }

  void _onLayerAdd(LayerEvent e) {
    if (e.layer.getAttribution != null) {
      addAttribution(e.layer.getAttribution());
    }
  }

  void _onLayerRemove(LayerEvent e) {
    if (e.layer.getAttribution != null) {
      removeAttribution(e.layer.getAttribution());
    }
  }
}
