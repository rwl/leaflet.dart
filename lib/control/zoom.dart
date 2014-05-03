
// Zoom is used for the default zoom buttons on the map.
class Zoom extends Control {
  var options = {
    'position': 'topleft',
    'zoomInText': '+',
    'zoomInTitle': 'Zoom in',
    'zoomOutText': '-',
    'zoomOutTitle': 'Zoom out'
  };

  onAdd(map) {
    var zoomName = 'leaflet-control-zoom',
        container = L.DomUtil.create('div', zoomName + ' leaflet-bar');

    this._map = map;

    this._zoomInButton  = this._createButton(
            this.options.zoomInText, this.options.zoomInTitle,
            zoomName + '-in',  container, this._zoomIn,  this);
    this._zoomOutButton = this._createButton(
            this.options.zoomOutText, this.options.zoomOutTitle,
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
    var link = L.DomUtil.create('a', className, container);
    link.innerHTML = html;
    link.href = '#';
    link.title = title;

    var stop = L.DomEvent.stopPropagation;

    L.DomEvent
        .on(link, 'click', stop)
        .on(link, 'mousedown', stop)
        .on(link, 'dblclick', stop)
        .on(link, 'click', L.DomEvent.preventDefault)
        .on(link, 'click', fn, context)
        .on(link, 'click', this._refocusOnMap, context);

    return link;
  }

  _updateDisabled() {
    var map = this._map,
      className = 'leaflet-disabled';

    L.DomUtil.removeClass(this._zoomInButton, className);
    L.DomUtil.removeClass(this._zoomOutButton, className);

    if (map._zoom == map.getMinZoom()) {
      L.DomUtil.addClass(this._zoomOutButton, className);
    }
    if (map._zoom == map.getMaxZoom()) {
      L.DomUtil.addClass(this._zoomInButton, className);
    }
  }
}