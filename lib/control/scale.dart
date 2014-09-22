part of leaflet.control;

class ScaleOptions extends ControlOptions {
  /**
   * The position of the control (one of the map corners). See control positions.
   */
  ControlPosition position  = ControlPosition.BOTTOMLEFT;

  /**
   * Maximum width of the control in pixels. The width is set dynamically to show round values (e.g. 100, 200, 500).
   */
  num maxWidth  = 100;

  /**
   * Whether to show the metric scale line (m/km).
   */
  bool metric  = true;

  /**
   * Whether to show the imperial scale line (mi/ft).
   */
  bool imperial  = true;

  /**
   * If true, the control is updated on moveend, otherwise it's always up-to-date (updated on move).
   */
  bool updateWhenIdle  = false;
}

/**
 * Scale is used for displaying metric/imperial scale on the map.
 */
class Scale extends Control {

  ScaleOptions get scaleOptions => options as ScaleOptions;

  Scale([ScaleOptions options=null]) : super(options) {
    if (options == null) {
      this.options = new ScaleOptions();
    }
  }

  Element _mScale, _iScale;

  StreamSubscription<MapEvent> _subscription;

  onAdd(LeafletMap map) {
    _map = map;

    final className = 'leaflet-control-scale',
        container = dom.create('div', className);

    _addScales(options, className, container);

    if (scaleOptions.updateWhenIdle) {
      _subscription = map.onMoveEnd.listen(_update);
    } else {
      _subscription = map.onMove.listen(_update);
    }
    map.whenReady(_update);

    return container;
  }

  onRemove(LeafletMap map) {
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  _addScales(ScaleOptions options, String className, Element container) {
    if (options.metric) {
      _mScale = dom.create('div', className + '-line', container);
    }
    if (options.imperial) {
      _iScale = dom.create('div', className + '-line', container);
    }
  }

  _update(_) {
    final bounds = _map.getBounds(),
        centerLat = bounds.getCenter().lat,
        halfWorldMeters = 6378137 * math.PI * math.cos(centerLat * math.PI / 180),
        dist = halfWorldMeters * (bounds.getNorthEast().lng - bounds.getSouthWest().lng) / 180,

        size = _map.getSize();
    int maxMeters = 0;

    if (size.x > 0) {
      maxMeters = (dist * (scaleOptions.maxWidth / size.x)) as int;
    }

    _updateScales(options, maxMeters);
  }

  _updateScales(options, maxMeters) {
    if (options.metric && maxMeters) {
      _updateMetric(maxMeters);
    }

    if (options.imperial && maxMeters) {
      _updateImperial(maxMeters);
    }
  }

  _updateMetric(maxMeters) {
    final meters = _getRoundNum(maxMeters);

    _mScale.style.width = _getScaleWidth(meters / maxMeters) + 'px';
    _mScale.setInnerHtml(meters < 1000 ? '$meters m' : '${meters / 1000} km');
  }

  _updateImperial(maxMeters) {
    final maxFeet = maxMeters * 3.2808399,
        scale = _iScale;
    num maxMiles, miles, feet;

    if (maxFeet > 5280) {
      maxMiles = maxFeet / 5280;
      miles = _getRoundNum(maxMiles);

      scale.style.width = _getScaleWidth(miles / maxMiles) + 'px';
      scale.setInnerHtml('$miles mi');

    } else {
      feet = _getRoundNum(maxFeet);

      scale.style.width = _getScaleWidth(feet / maxFeet) + 'px';
      scale.setInnerHtml('$feet ft');
    }
  }

  _getScaleWidth(ratio) {
    return (scaleOptions.maxWidth * ratio).round() - 10;
  }

  _getRoundNum(n) {
    final pow10 = math.pow(10, (n.floor() + '').length - 1);
    num d = n / pow10;

    d = d >= 10 ? 10 : d >= 5 ? 5 : d >= 3 ? 3 : d >= 2 ? 2 : 1;

    return pow10 * d;
  }
}