part of leaflet.control;

class ScaleOptions {
  // The position of the control (one of the map corners). See control positions.
  ControlPosition position  = ControlPosition.BOTTOMLEFT;
  // Maximum width of the control in pixels. The width is set dynamically to show round values (e.g. 100, 200, 500).
  num maxWidth  = 100;
  // Whether to show the metric scale line (m/km).
  bool metric  = true;
  // Whether to show the imperial scale line (mi/ft).
  bool imperial  = true;
  // If true, the control is updated on moveend, otherwise it's always up-to-date (updated on move).
  bool updateWhenIdle  = false;
}

// Scale is used for displaying metric/imperial scale on the map.
class Scale extends Control {

  Scale() : super({});

  final Map<String, Object> options = {
    'position': 'bottomleft',
    'maxWidth': 100,
    'metric': true,
    'imperial': true,
    'updateWhenIdle': false
  };

  var _mScale, _iScale;

  onAdd(map) {
    this._map = map;

    final className = 'leaflet-control-scale',
        container = DomUtil.create('div', className),
        options = this.options;

    this._addScales(options, className, container);

    map.on(options['updateWhenIdle'] ? 'moveend' : 'move', this._update, this);
    map.whenReady(this._update, this);

    return container;
  }

  onRemove(map) {
    map.off(this.options['updateWhenIdle'] ? 'moveend' : 'move', this._update, this);
  }

  _addScales(options, className, container) {
    if (options['metric']) {
      this._mScale = DomUtil.create('div', className + '-line', container);
    }
    if (options['imperial']) {
      this._iScale = DomUtil.create('div', className + '-line', container);
    }
  }

  _update() {
    final bounds = this._map.getBounds(),
        centerLat = bounds.getCenter().lat,
        halfWorldMeters = 6378137 * math.PI * math.cos(centerLat * math.PI / 180),
        dist = halfWorldMeters * (bounds.getNorthEast().lng - bounds.getSouthWest().lng) / 180,

        size = this._map.getSize(),
        options = this.options;
    int maxMeters = 0;

    if (size.x > 0) {
      maxMeters = dist * (options['maxWidth'] / size.x);
    }

    this._updateScales(options, maxMeters);
  }

  _updateScales(options, maxMeters) {
    if (options.metric && maxMeters) {
      this._updateMetric(maxMeters);
    }

    if (options.imperial && maxMeters) {
      this._updateImperial(maxMeters);
    }
  }

  _updateMetric(maxMeters) {
    var meters = this._getRoundNum(maxMeters);

    this._mScale.style.width = this._getScaleWidth(meters / maxMeters) + 'px';
    this._mScale.innerHTML = meters < 1000 ? meters + ' m' : (meters / 1000) + ' km';
  }

  _updateImperial(maxMeters) {
    var maxFeet = maxMeters * 3.2808399,
        scale = this._iScale,
        maxMiles, miles, feet;

    if (maxFeet > 5280) {
      maxMiles = maxFeet / 5280;
      miles = this._getRoundNum(maxMiles);

      scale.style.width = this._getScaleWidth(miles / maxMiles) + 'px';
      scale.innerHTML = miles + ' mi';

    } else {
      feet = this._getRoundNum(maxFeet);

      scale.style.width = this._getScaleWidth(feet / maxFeet) + 'px';
      scale.innerHTML = feet + ' ft';
    }
  }

  _getScaleWidth(ratio) {
    return (this.options['maxWidth'] * ratio).round() - 10;
  }

  _getRoundNum(n) {
    var pow10 = math.pow(10, (n.floor() + '').length - 1),
        d = n / pow10;

    d = d >= 10 ? 10 : d >= 5 ? 5 : d >= 3 ? 3 : d >= 2 ? 2 : 1;

    return pow10 * d;
  }
}