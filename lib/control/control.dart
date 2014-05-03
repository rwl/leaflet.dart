
// Control is a base class for implementing map controls. Handles positioning.
// All other controls extend from this class.
class Control {
  var options = {
    'position': 'topright'
  };

  Control(options) {
    L.setOptions(this, options);
  }

  getPosition() {
    return this.options.position;
  }

  setPosition(position) {
    var map = this._map;

    if (map) {
      map.removeControl(this);
    }

    this.options.position = position;

    if (map) {
      map.addControl(this);
    }

    return this;
  }

  getContainer() {
    return this._container;
  }

  addTo(map) {
    this._map = map;

    var container = this._container = this.onAdd(map),
        pos = this.getPosition(),
        corner = map._controlCorners[pos];

    L.DomUtil.addClass(container, 'leaflet-control');

    if (pos.indexOf('bottom') != -1) {
      corner.insertBefore(container, corner.firstChild);
    } else {
      corner.appendChild(container);
    }

    return this;
  }

  removeFrom(map) {
    var pos = this.getPosition(),
        corner = map._controlCorners[pos];

    corner.removeChild(this._container);
    this._map = null;

    if (this.onRemove) {
      this.onRemove(map);
    }

    return this;
  }

  _refocusOnMap() {
    if (this._map) {
      this._map.getContainer().focus();
    }
  }
}

class Map {
  addControl(control) {
    control.addTo(this);
    return this;
  }

  removeControl(control) {
    control.removeFrom(this);
    return this;
  }

  _initControlPos() {
    var corners = this._controlCorners = {},
        l = 'leaflet-',
        container = this._controlContainer =
                L.DomUtil.create('div', l + 'control-container', this._container);

    createCorner(vSide, hSide) {
      var className = l + vSide + ' ' + l + hSide;

      corners[vSide + hSide] = L.DomUtil.create('div', className, container);
    }

    createCorner('top', 'left');
    createCorner('top', 'right');
    createCorner('bottom', 'left');
    createCorner('bottom', 'right');
  }

  _clearControlPos() {
    this._container.removeChild(this._controlContainer);
  }
}