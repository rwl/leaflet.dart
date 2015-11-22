part of leaflet;

class MapOptions extends Object
    with
        MapStateOptions,
        InteractionOptions,
        KeyboardNavigationOptions,
        PanningInertiaOptions,
        ControlOptions,
        AnimationOptions,
        LocateOptions,
        ZoomPanOptions {
  Map<String, dynamic> _toJsonMap() {
    var m = {};

    if (center != null) m['center'] = center._latlng;
    if (zoom != null) m['zoom'] = zoom;
    if (layers != null) m['layers'] = layers.map((l) => l.layer).toList();
    if (minZoom != null) m['minZoom'] = minZoom;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (maxBounds != null) m['maxBounds'] = maxBounds._llb;
    if (crs != null) m['crs'] = crs._toJsonMap();

    if (dragging != null) m['dragging'] = dragging;
    if (touchZoom != null) m['touchZoom'] = touchZoom;
    if (scrollWheelZoom != null) m['scrollWheelZoom'] = scrollWheelZoom;
    if (doubleClickZoom != null) m['doubleClickZoom'] = doubleClickZoom;
    if (boxZoom != null) m['boxZoom'] = boxZoom;
    if (tap != null) m['tap'] = tap;
    if (tapTolerance != null) m['tapTolerance'] = tapTolerance;
    if (trackResize != null) m['trackResize'] = trackResize;
    if (worldCopyJump != null) m['worldCopyJump'] = worldCopyJump;
    if (closePopupOnClick != null) m['closePopupOnClick'] = closePopupOnClick;
    if (bounceAtZoomLimits != null) m['bounceAtZoomLimits'] =
        bounceAtZoomLimits;

    if (keyboard != null) m['keyboard'] = keyboard;
    if (keyboardPanOffset != null) m['keyboardPanOffset'] = keyboardPanOffset;
    if (keyboardZoomOffset != null) m['keyboardZoomOffset'] =
        keyboardZoomOffset;

    if (inertia != null) m['inertia'] = inertia;
    if (inertiaDeceleration != null) m['inertiaDeceleration'] =
        inertiaDeceleration;
    if (inertiaMaxSpeed != null) m['inertiaMaxSpeed'] = inertiaMaxSpeed;
    if (inertiaThreshold != null) m['inertiaThreshold'] = inertiaThreshold;

    if (zoomControl != null) m['zoomControl'] = zoomControl;
    if (attributionControl != null) m['attributionControl'] =
        attributionControl;

    if (fadeAnimation != null) m['fadeAnimation'] = fadeAnimation;
    if (zoomAnimation != null) m['zoomAnimation'] = zoomAnimation;
    if (zoomAnimationThreshold != null) m['zoomAnimationThreshold'] =
        zoomAnimationThreshold;
    if (markerZoomAnimation != null) m['markerZoomAnimation'] =
        markerZoomAnimation;

    if (watch != null) m['watch'] = watch;
    if (setView != null) m['setView'] = setView;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (timeout != null) m['timeout'] = timeout;
    if (maximumAge != null) m['maximumAge'] = maximumAge;
    if (enableHighAccuracy != null) m['enableHighAccuracy'] =
        enableHighAccuracy;

    if (reset != null) m['reset'] = reset;
    if (panOptions != null) m['panOptions'] = panOptions._toJsonMap();
    if (zoomOptions != null) m['zoomOptions'] = zoomOptions._toJsonMap();
    if (animate != null) m['animate'] = animate;
    if (paddingTopLeft != null) m['paddingTopLeft'] = _pointMap(paddingTopLeft);
    if (paddingBottomRight != null) m['paddingBottomRight'] =
        _pointMap(paddingBottomRight);
    if (padding != null) m['padding'] = _pointMap(padding);
    if (maxZoom != null) m['maxZoom'] = maxZoom;

    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class MapStateOptions {
  /// Initial geographical center of the map.
  LatLng center;

  /// Initial map zoom.
  num zoom;

  /// Layers that will be added to the map initially.
  List<Layer> layers;

  /// Minimum zoom level of the map. Overrides any minZoom set on map
  /// layers.
  num minZoom;

  /// Maximum zoom level of the map. This overrides any maxZoom set on map
  /// layers.
  num maxZoom;

  /// When this option is set, the map restricts the view to the given
  /// geographical bounds, bouncing the user back when he tries to pan outside
  /// the view. To set the restriction dynamically, use setMaxBounds method.
  LatLngBounds maxBounds;

  /// Coordinate Reference System to use. Don't change this if you're not sure
  /// what it means. Default: EPSG3857
  /*CRS*/ var crs;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (center != null) m['center'] = center._latlng;
    if (zoom != null) m['zoom'] = zoom;
    if (layers != null) m['layers'] = layers.map((l) => l.layer).toList();
    if (minZoom != null) m['minZoom'] = minZoom;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (maxBounds != null) m['maxBounds'] = maxBounds._llb;
    if (crs != null) m['crs'] = crs._crs;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class InteractionOptions {
  /// Whether the map be draggable with mouse/touch or not. Default: true
  bool dragging;

  /// Whether the map can be zoomed by touch-dragging with two fingers.
  /// Default: true
  bool touchZoom;

  /// Whether the map can be zoomed by using the mouse wheel. If passed
  /// 'center', it will zoom to the center of the view regardless of where
  /// the mouse was. Default: true
  var scrollWheelZoom;

  /// Whether the map can be zoomed in by double clicking on it and zoomed out
  /// by double clicking while holding shift. If passed 'center', double-click
  /// zoom will zoom to the center of the view regardless of where the mouse
  /// was. Default: true
  bool doubleClickZoom;

  /// Whether the map can be zoomed to a rectangular area specified by dragging
  /// the mouse while pressing shift. Default: true
  bool boxZoom;

  /// Enables mobile hacks for supporting instant taps (fixing 200ms click delay
  /// on iOS/Android) and touch holds (fired as contextmenu events).
  /// Default: true
  bool tap;

  /// The max number of pixels a user can shift his finger during touch for it
  /// to be considered a valid tap. Default: 15
  num tapTolerance;

  /// Whether the map automatically handles browser window resize to update
  /// itself. Default: true
  bool trackResize;

  /// With this option enabled, the map tracks when you pan to another "copy"
  /// of the world and seamlessly jumps to the original one so that all overlays
  /// like markers and vector layers are still visible. Default: false
  bool worldCopyJump;

  /// Set it to false if you don't want popups to close when user clicks the
  /// map. Default: true
  bool closePopupOnClick;

  /// Set it to false if you don't want the map to zoom beyond min/max zoom and
  /// then bounce back when pinch-zooming. Default: true
  bool bounceAtZoomLimits;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (dragging != null) m['dragging'] = dragging;
    if (touchZoom != null) m['touchZoom'] = touchZoom;
    if (scrollWheelZoom != null) m['scrollWheelZoom'] = scrollWheelZoom;
    if (doubleClickZoom != null) m['doubleClickZoom'] = doubleClickZoom;
    if (boxZoom != null) m['boxZoom'] = boxZoom;
    if (tap != null) m['tap'] = tap;
    if (tapTolerance != null) m['tapTolerance'] = tapTolerance;
    if (trackResize != null) m['trackResize'] = trackResize;
    if (worldCopyJump != null) m['worldCopyJump'] = worldCopyJump;
    if (closePopupOnClick != null) m['closePopupOnClick'] = closePopupOnClick;
    if (bounceAtZoomLimits != null) m['bounceAtZoomLimits'] =
        bounceAtZoomLimits;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class KeyboardNavigationOptions {
  /// Makes the map focusable and allows users to navigate the map with keyboard
  /// arrows and +/- keys. Default: true
  bool keyboard;

  /// Amount of pixels to pan when pressing an arrow key. Default: 80
  num keyboardPanOffset;

  /// Number of zoom levels to change when pressing + or - key. Default: 1
  num keyboardZoomOffset;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (keyboard != null) m['keyboard'] = keyboard;
    if (keyboardPanOffset != null) m['keyboardPanOffset'] = keyboardPanOffset;
    if (keyboardZoomOffset != null) m['keyboardZoomOffset'] =
        keyboardZoomOffset;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class PanningInertiaOptions {
  /// If enabled, panning of the map will have an inertia effect where the map
  /// builds momentum while dragging and continues moving in the same direction
  /// for some time. Feels especially nice on touch devices. Default: true
  bool inertia;

  /// The rate with which the inertial movement slows down, in pixels/second2.
  /// Default: 3000
  num inertiaDeceleration;

  /// Max speed of the inertial movement, in pixels/second. Default: 1500
  num inertiaMaxSpeed;

  /// Number of milliseconds that should pass between stopping the movement and
  /// releasing the mouse or touch to prevent inertial movement. 32 for touch
  /// devices and 14 for the rest by default.
  num inertiaThreshold;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (inertia != null) m['inertia'] = inertia;
    if (inertiaDeceleration != null) m['inertiaDeceleration'] =
        inertiaDeceleration;
    if (inertiaMaxSpeed != null) m['inertiaMaxSpeed'] = inertiaMaxSpeed;
    if (inertiaThreshold != null) m['inertiaThreshold'] = inertiaThreshold;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class ControlOptions {
  /// Whether the zoom control is added to the map by default. Default: true
  bool zoomControl;

  /// Whether the attribution control is added to the map by default.
  /// Default: true
  bool attributionControl;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (zoomControl != null) m['zoomControl'] = zoomControl;
    if (attributionControl != null) m['attributionControl'] =
        attributionControl;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class AnimationOptions {
  /// Whether the tile fade animation is enabled. By default it's enabled in
  /// all browsers that support CSS3 Transitions except Android.
  bool fadeAnimation;

  /// Whether the tile zoom animation is enabled. By default it's enabled in
  /// all browsers that support CSS3 Transitions except Android.
  bool zoomAnimation;

  /// Won't animate zoom if the zoom difference exceeds this value. Default: 4
  num zoomAnimationThreshold;

  /// Whether markers animate their zoom with the zoom animation, if disabled
  /// they will disappear for the length of the animation. By default it's
  /// enabled in all browsers that support CSS3 Transitions except Android.
  bool markerZoomAnimation;

  /*AnimationOptions() {
    fadeAnimation = true; //dom.TRANSITION != null && !Browser.android23;
    markerZoomAnimation = true; // dom.TRANSITION != null && Browser.any3d;
  }*/

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (fadeAnimation != null) m['fadeAnimation'] = fadeAnimation;
    if (zoomAnimation != null) m['zoomAnimation'] = zoomAnimation;
    if (zoomAnimationThreshold != null) m['zoomAnimationThreshold'] =
        zoomAnimationThreshold;
    if (markerZoomAnimation != null) m['markerZoomAnimation'] =
        markerZoomAnimation;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class LocateOptions {
  /// If true, starts continous watching of location changes (instead of
  /// detecting it once) using W3C watchPosition method. You can later stop
  /// watching using map.stopLocate() method. Default: false
  bool watch;

  /// If true, automatically sets the map view to the user location with
  /// respect to detection accuracy, or to world view if geolocation failed.
  /// Default: false
  bool setView;

  /// The maximum zoom for automatic view setting when using `setView` option.
  /// Default: [double.INFINITY]
  num maxZoom;

  /// Number of milliseconds to wait for a response from geolocation before
  /// firing a locationerror event. Default: 10000
  num timeout;

  /// Maximum age of detected location. If less than this amount of milliseconds
  /// passed since last geolocation response, locate will return a cached
  /// location. Default: 0
  num maximumAge;

  /// Enables high accuracy, see description in the W3C spec. Default: false
  bool enableHighAccuracy;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (watch != null) m['watch'] = watch;
    if (setView != null) m['setView'] = setView;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (timeout != null) m['timeout'] = timeout;
    if (maximumAge != null) m['maximumAge'] = maximumAge;
    if (enableHighAccuracy != null) m['enableHighAccuracy'] =
        enableHighAccuracy;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class ZoomPanOptions {
  /// If true, the map view will be completely reset (without any animations).
  bool reset;

  /// Sets the options for the panning (without the zoom change) if it occurs.
  PanOptions panOptions;

  /// Sets the options for the zoom change if it occurs.
  ZoomOptions zoomOptions;

  /// An equivalent of passing animate to both zoom and pan options (see below).
  /*void set animate(bool anim) {
    pan.animate = anim;
    zoom.animate = anim;
  }*/
  bool animate;

  /// Sets the amount of padding in the top left corner of a map container that
  /// shouldn't be accounted for when setting the view to fit bounds. Useful if
  /// you have some control overlays on the map like a sidebar and you don't want
  /// them to obscure objects you're zooming to.
  Point paddingTopLeft;

  /// The same for bottom right corner of the map.
  Point paddingBottomRight;

  /// Equivalent of setting both top left and bottom right padding to the same
  /// value.
  Point padding;
  /*void set padding(Point2D point) {
    if (point == null) {
      point = new Point2D([0, 0]);
    }
    paddingTopLeft = point;
    paddingBottomRight = point;
  }*/

  /// The maximum possible zoom to use.
  num maxZoom;

  /*ZoomPanOptions({this.reset: false, this.pan, this.zoom, this.paddingTopLeft: null, this.paddingBottomRight: null, this.maxZoom}) {
    if (paddingTopLeft == null) {
      paddingTopLeft = new Point2D(0, 0);
    }
    this.paddingTopLeft = paddingTopLeft;
    if (paddingBottomRight == null) {
      paddingBottomRight = new Point2D(0, 0);
    }
    this.paddingBottomRight = paddingBottomRight;
  }*/

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (reset != null) m['reset'] = reset;
    if (panOptions != null) m['panOptions'] = panOptions._toJsonMap();
    if (zoomOptions != null) m['zoomOptions'] = zoomOptions._toJsonMap();
    if (animate != null) m['animate'] = animate;
    if (paddingTopLeft != null) m['paddingTopLeft'] = _pointMap(paddingTopLeft);
    if (paddingBottomRight != null) m['paddingBottomRight'] =
        _pointMap(paddingBottomRight);
    if (padding != null) m['padding'] = _pointMap(padding);
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class PanOptions {
  /// If true, panning will always be animated if possible. If false, it will
  /// not animate panning, either resetting the map view if panning more than a
  /// screen away, or just setting a new offset for the map pane (except for
  /// `panBy` which always does the latter).
  bool animate;

  /// Duration of animated panning. Default: 0.25
  num duration;

  /// The curvature factor of panning animation easing (third parameter of the
  /// Cubic Bezier curve). 1.0 means linear animation, the less the more bowed
  /// the curve. Default: 0.25
  num easeLinearity;

  /// If true, panning won't fire movestart event on start (used internally for
  /// panning inertia). Default: false
  bool noMoveStart;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (animate != null) m['animate'] = animate;
    if (duration != null) m['duration'] = duration;
    if (easeLinearity != null) m['easeLinearity'] = easeLinearity;
    if (noMoveStart != null) m['noMoveStart'] = noMoveStart;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

class ZoomOptions {
  /// If not specified, zoom animation will happen if the zoom origin is inside
  /// the current view. If true, the map will attempt animating zoom
  /// disregarding where zoom origin is. Setting false will make it always reset
  /// the view completely without animation.
  bool animate;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (animate != null) m['animate'] = animate;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}

//class FitBoundsOptions extends ZoomPanOptions {
//}

Map _pointMap(Point point) => {'x': point.x, 'y': point.y};
