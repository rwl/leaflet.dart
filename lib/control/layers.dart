part of leaflet.control;

// Layers is a control to allow users to switch between different layers on the map.
class Layers extends Control {

  final Map<String, Object> options = {
    'collapsed': true,
    'position': 'topright',
    'autoZIndex': true
  };

  Map _layers;
  int _lastZIndex;
  bool _handlingClick;
  var _form;
  var _layersLink;
  var _baseLayersList, _overlaysList;
  var _separator;

  Layers(List baseLayers, List overlays, Map<String, Object> options) : super(options) {
    this.options.addAll(options);

    this._layers = {};
    this._lastZIndex = 0;
    this._handlingClick = false;

    for (var i in baseLayers) {
      this._addLayer(baseLayers[i], i);
    }

    for (var i in overlays) {
      this._addLayer(overlays[i], i, true);
    }
  }

  onAdd(BaseMap map) {
    this._initLayout();
    this._update();

    map
        .on('layeradd', this._onLayerChange, this)
        .on('layerremove', this._onLayerChange, this);

    return this._container;
  }

  onRemove(BaseMap map) {
    map
        .off('layeradd', this._onLayerChange)
        .off('layerremove', this._onLayerChange);
  }

  addBaseLayer(layer, String name) {
    this._addLayer(layer, name);
    this._update();
    return this;
  }

  addOverlay(layer, String name) {
    this._addLayer(layer, name, true);
    this._update();
    return this;
  }

  removeLayer(layer) {
    var id = Util.stamp(layer);
    this._layers.remove(id);
    this._update();
    return this;
  }

  _initLayout() {
    final className = 'leaflet-control-layers',
        container = this._container = DomUtil.create('div', className);

    //Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
    container.setAttribute('aria-haspopup', true);

    if (!Browser.touch) {
      DomEvent
        .disableClickPropagation(container)
        .disableScrollPropagation(container);
    } else {
      DomEvent.on(container, 'click', DomEvent.stopPropagation);
    }

    final form = this._form = DomUtil.create('form', className + '-list');

    if (this.options['collapsed']) {
      if (!Browser.android) {
        DomEvent
            .on(container, 'mouseover', this._expand, this)
            .on(container, 'mouseout', this._collapse, this);
      }
      final link = this._layersLink = DomUtil.create('a', className + '-toggle', container);
      link.href = '#';
      link.title = 'Layers';

      if (Browser.touch) {
        DomEvent
            .on(link, 'click', L.DomEvent.stop)
            .on(link, 'click', this._expand, this);
      }
      else {
        DomEvent.on(link, 'focus', this._expand, this);
      }
      //Work around for Firefox android issue https://github.com/Leaflet/Leaflet/issues/2033
      DomEvent.on(form, 'click', () {
        setTimeout(bind(this._onInputClick, this), 0);
      }, this);

      this._map.on('click', this._collapse, this);
      // TODO keyboard accessibility
    } else {
      this._expand();
    }

    this._baseLayersList = DomUtil.create('div', className + '-base', form);
    this._separator = DomUtil.create('div', className + '-separator', form);
    this._overlaysList = DomUtil.create('div', className + '-overlays', form);

    container.appendChild(form);
  }

  _addLayer(layer, String name, overlay) {
    var id = Util.stamp(layer);

    this._layers[id] = {
      layer: layer,
      name: name,
      overlay: overlay
    };

    if (this.options['autoZIndex'] && layer.setZIndex) {
      this._lastZIndex++;
      layer.setZIndex(this._lastZIndex);
    }
  }

  _update() {
    if (this._container == null) {
      return;
    }

    this._baseLayersList.innerHTML = '';
    this._overlaysList.innerHTML = '';

    bool baseLayersPresent = false,
        overlaysPresent = false;

    for (var i in this._layers) {
      final obj = this._layers[i];
      this._addItem(obj);
      overlaysPresent = overlaysPresent || obj.overlay != null;
      baseLayersPresent = baseLayersPresent || !obj.overlay != null;
    }

    this._separator.style.display = overlaysPresent && baseLayersPresent ? '' : 'none';
  }

  _onLayerChange(e) {
    final obj = this._layers[Util.stamp(e.layer)];

    if (!obj) { return; }

    if (!this._handlingClick) {
      this._update();
    }

    final type = obj.overlay != null ?
      (e.type == 'layeradd' ? 'overlayadd' : 'overlayremove') :
      (e.type == 'layeradd' ? 'baselayerchange' : null);

    if (type) {
      this._map.fire(type, obj);
    }
  }

  // IE7 bugs out if you create a radio dynamically, so you have to do it this hacky way (see http://bit.ly/PqYLBe)
  _createRadioElement(String name, bool checked) {

    var radioHtml = '<input type="radio" class="leaflet-control-layers-selector" name="' + name + '"';
    if (checked) {
      radioHtml += ' checked="checked"';
    }
    radioHtml += '/>';

    final radioFragment = document.createElement('div');
    radioFragment.setInnerHtml(radioHtml);

    return radioFragment.firstChild;
  }

  _addItem(obj) {
    final label = document.createElement('label');
    var input;
    final checked = this._map.hasLayer(obj.layer);

    if (obj.overlay != null) {
      input = document.createElement('input');
      input.type = 'checkbox';
      input.className = 'leaflet-control-layers-selector';
      input.defaultChecked = checked;
    } else {
      input = this._createRadioElement('leaflet-base-layers', checked);
    }

    input.layerId = Util.stamp(obj.layer);

    DomEvent.on(input, 'click', this._onInputClick, this);

    final name = document.createElement('span');
    name.setInnerHtml(' ' + obj.name);

    label.append(input);
    label.append(name);

    final container = obj.overlay ? this._overlaysList : this._baseLayersList;
    container.append(label);

    return label;
  }

  _onInputClick() {
//    var i, input, obj;
    final inputs = this._form.getElementsByTagName('input');

    this._handlingClick = true;

    for (int i = 0; i < inputs.length; i++) {
      final input = inputs[i];
      final obj = this._layers[input.layerId];

      if (input.checked && !this._map.hasLayer(obj.layer)) {
        this._map.addLayer(obj.layer);

      } else if (!input.checked && this._map.hasLayer(obj.layer)) {
        this._map.removeLayer(obj.layer);
      }
    }

    this._handlingClick = false;

    this._refocusOnMap();
  }

  _expand() {
    DomUtil.addClass(this._container, 'leaflet-control-layers-expanded');
  }

  _collapse() {
    this._container.className = this._container.className.replace(' leaflet-control-layers-expanded', '');
  }
}