part of leaflet.control;

// Zoom is used for the default zoom buttons on the map.
class Zoom extends Control {

  Zoom() : super({});

  final Map<String, Object> options = {
    'position': 'topleft',
    'zoomInText': '+',
    'zoomInTitle': 'Zoom in',
    'zoomOutText': '-',
    'zoomOutTitle': 'Zoom out'
  };

  var _zoomInButton, _zoomOutButton;

  onAdd(BaseMap map) {
    final zoomName = 'leaflet-control-zoom',
        container = DomUtil.create('div', zoomName + ' leaflet-bar');

    this._map = map;

    this._zoomInButton = this._createButton(
            this.options['zoomInText'], this.options['zoomInTitle'],
            zoomName + '-in', container, this._zoomIn, this);
    this._zoomOutButton = this._createButton(
            this.options['zoomOutText'], this.options['zoomOutTitle'],
            zoomName + '-out', container, this._zoomOut, this);

    this._updateDisabled();
    map.on('zoomend zoomlevelschange', this._updateDisabled, this);

    return container;
  }

  onRemove(map) {
    map.off('zoomend zoomlevelschange', this._updateDisabled, this);
  }

  _zoomIn(e) {
    this._map.zoomIn(e.shiftKey ? 3 : 1);
  }

  _zoomOut(e) {
    this._map.zoomOut(e.shiftKey ? 3 : 1);
  }

  _createButton(html, title, className, container, fn, context) {
    final link = DomUtil.create('a', className, container);
    link.setInnerHTML(html);
    link.href = '#';
    link.title = title;

    final stop = DomEvent.stopPropagation;

    DomEvent
        .on(link, 'click', stop)
        .on(link, 'mousedown', stop)
        .on(link, 'dblclick', stop)
        .on(link, 'click', DomEvent.preventDefault)
        .on(link, 'click', fn, context)
        .on(link, 'click', this._refocusOnMap, context);

    return link;
  }

  _updateDisabled() {
    final map = this._map,
      className = 'leaflet-disabled';

    DomUtil.removeClass(this._zoomInButton, className);
    DomUtil.removeClass(this._zoomOutButton, className);

    if (map._zoom == map.getMinZoom()) {
      DomUtil.addClass(this._zoomOutButton, className);
    }
    if (map._zoom == map.getMaxZoom()) {
      DomUtil.addClass(this._zoomInButton, className);
    }
  }
}