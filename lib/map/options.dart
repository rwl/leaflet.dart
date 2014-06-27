part of leaflet.map;


class MapStateOptions {
  /**
   * Initial geographical center of the map.
   */
  LatLng center = null;

  /**
   * Initial map zoom.
   */
  num zoom = null;

  /**
   * Layers that will be added to the map initially.
   */
  List<Layer> layers = null;

  /**
   * Minimum zoom level of the map. Overrides any minZoom set on map layers.
   */
  num minZoom = null;

  /**
   * Maximum zoom level of the map. This overrides any maxZoom set on map layers.
   */
  num maxZoom = null;

  /**
   * When this option is set, the map restricts the view to the given
   * geographical bounds, bouncing the user back when he tries to pan outside
   * the view. To set the restriction dynamically, use setMaxBounds method.
   */
  LatLngBounds maxBounds = null;

  /**
   * Coordinate Reference System to use. Don't change this if you're not sure
   * what it means.
   */
  CRS crs = EPSG3857;
}

class InteractionOptions {
  /**
   * Whether the map be draggable with mouse/touch or not.
   */
  bool dragging = true;

  /**
   * Whether the map can be zoomed by touch-dragging with two fingers.
   */
  bool touchZoom = true;

  /**
   * Whether the map can be zoomed by using the mouse wheel. If passed
   * 'center', it will zoom to the center of the view regardless of where
   * the mouse was.
   */
  bool scrollWheelZoom = true;

  /**
   * Whether the map can be zoomed in by double clicking on it and zoomed out
   * by double clicking while holding shift. If passed 'center', double-click
   * zoom will zoom to the center of the view regardless of where the mouse
   * was.
   */
  bool doubleClickZoom = true;

  /**
   * Whether the map can be zoomed to a rectangular area specified by dragging
   * the mouse while pressing shift.
   */
  bool boxZoom = true;

  /**
   * Enables mobile hacks for supporting instant taps (fixing 200ms click delay
   * on iOS/Android) and touch holds (fired as contextmenu events).
   */
  bool tap = true;

  /**
   * The max number of pixels a user can shift his finger during touch for it
   * to be considered a valid tap.
   */
  num tapTolerance = 15;

  /**
   * Whether the map automatically handles browser window resize to update
   * itself.
   */
  bool trackResize = true;

  /**
   * With this option enabled, the map tracks when you pan to another "copy"
   * of the world and seamlessly jumps to the original one so that all overlays
   * like markers and vector layers are still visible.
   */
  bool worldCopyJump = false;

  /**
   * Set it to false if you don't want popups to close when user clicks the
   * map.
   */
  bool closePopupOnClick = true;

  /**
   * Set it to false if you don't want the map to zoom beyond min/max zoom and
   * then bounce back when pinch-zooming.
   */
  bool bounceAtZoomLimits = true;
}

class KeyboardNavigationOptions {
  /**
   * Makes the map focusable and allows users to navigate the map with keyboard
   * arrows and +/- keys.
   */
  bool keyboard = true;

  /**
   * Amount of pixels to pan when pressing an arrow key.
   */
  num keyboardPanOffset = 80;

  /**
   * Number of zoom levels to change when pressing + or - key.
   */
  num keyboardZoomOffset = 1;
}

class PanningInertiaOptions {
  /**
   * If enabled, panning of the map will have an inertia effect where the map
   * builds momentum while dragging and continues moving in the same direction
   * for some time. Feels especially nice on touch devices.
   */
  bool inertia = true;

  /**
   * The rate with which the inertial movement slows down, in pixels/second2.
   */
  num inertiaDeceleration = 3000;

  /**
   * Max speed of the inertial movement, in pixels/second.
   */
  num inertiaMaxSpeed = 1500;

  /**
   * Number of milliseconds that should pass between stopping the movement and
   * releasing the mouse or touch to prevent inertial movement. 32 for touch
   * devices and 14 for the rest by default.
   */
  num inertiaThreshold;
}

class ControlOptions {
  /**
   * Whether the zoom control is added to the map by default.
   */
  bool zoomControl = true;

  /**
   * Whether the attribution control is added to the map by default.
   */
  bool attributionControl = true;
}

class AnimationOptions {
  /**
   * Whether the tile fade animation is enabled. By default it's enabled in
   * all browsers that support CSS3 Transitions except Android.
   */
  bool fadeAnimation;

  /**
   * Whether the tile zoom animation is enabled. By default it's enabled in
   * all browsers that support CSS3 Transitions except Android.
   */
  bool zoomAnimation;

  /**
   * Won't animate zoom if the zoom difference exceeds this value.
   */
  num zoomAnimationThreshold = 4;

  /**
   * Whether markers animate their zoom with the zoom animation, if disabled
   * they will disappear for the length of the animation. By default it's
   * enabled in all browsers that support CSS3 Transitions except Android.
   */
  bool markerZoomAnimation;

  AnimationOptions() {
    fadeAnimation = dom.TRANSITION && !Browser.android23;
    markerZoomAnimation = dom.TRANSITION && Browser.any3d;
  }
}

class LocateOptions {
  /**
   * If true, starts continous watching of location changes (instead of
   * detecting it once) using W3C watchPosition method. You can later stop
   * watching using map.stopLocate() method.
   */
  bool watch = false;

  /**
   * If true, automatically sets the map view to the user location with
   * respect to detection accuracy, or to world view if geolocation failed.
   */
  bool setView = false;

  /**
   * The maximum zoom for automatic view setting when using `setView` option.
   */
  num maxZoom = double.INFINITY;

  /**
   * Number of milliseconds to wait for a response from geolocation before
   * firing a locationerror event.
   */
  num timeout = 10000;

  /**
   * Maximum age of detected location. If less than this amount of milliseconds
   * passed since last geolocation response, locate will return a cached
   * location.
   */
  num maximumAge = 0;

  /**
   * Enables high accuracy, see description in the W3C spec.
   */
  bool enableHighAccuracy = false;
}

class ZoomPanOptions {
  /**
   * If true, the map view will be completely reset (without any animations).
   */
  bool reset = false;

  /**
   * Sets the options for the panning (without the zoom change) if it occurs.
   */
  PanOptions pan;

  /**
   * Sets the options for the zoom change if it occurs.
   */
  ZoomOptions zoom;

  /**
   * An equivalent of passing animate to both zoom and pan options (see below).
   */
  /*void set animate(bool anim) {
    pan.animate = anim;
    zoom.animate = anim;
  }*/
  bool animate;

  /**
   * Sets the amount of padding in the top left corner of a map container that
   * shouldn't be accounted for when setting the view to fit bounds. Useful if
   * you have some control overlays on the map like a sidebar and you don't want
   * them to obscure objects you're zooming to.
   */
  Point2D paddingTopLeft;

  /**
   * The same for bottom right corner of the map.
   */
  Point2D paddingBottomRight = new Point2D(0, 0);

  /**
   * Equivalent of setting both top left and bottom right padding to the same
   * value.
   */
  Point2D padding = new Point2D(0, 0);
  /*void set padding(Point2D point) {
    if (point == null) {
      point = new Point2D([0, 0]);
    }
    paddingTopLeft = point;
    paddingBottomRight = point;
  }*/

  /**
   * The maximum possible zoom to use.
   */
  num maxZoom;

  ZoomPanOptions({this.reset: false, this.pan, this.zoom, this.paddingTopLeft: null, this.paddingBottomRight: null, this.maxZoom}) {
    if (paddingTopLeft == null) {
      paddingTopLeft = new Point2D(0, 0);
    }
    this.paddingTopLeft = paddingTopLeft;
    if (paddingBottomRight == null) {
      paddingBottomRight = new Point2D(0, 0);
    }
    this.paddingBottomRight = paddingBottomRight;
  }
}

class PanOptions {
  /**
   * If true, panning will always be animated if possible. If false, it will
   * not animate panning, either resetting the map view if panning more than a
   * screen away, or just setting a new offset for the map pane (except for
   * `panBy` which always does the latter).
   */
  bool animate;

  /**
   * Duration of animated panning.
   */
  num duration = 0.25;

  /**
   * The curvature factor of panning animation easing (third parameter of the
   * Cubic Bezier curve). 1.0 means linear animation, the less the more bowed
   * the curve.
   */
  num easeLinearity = 0.25;

  /**
   * If true, panning won't fire movestart event on start (used internally for
   * panning inertia).
   */
  bool noMoveStart = false;
}

class ZoomOptions {
  /**
   * If not specified, zoom animation will happen if the zoom origin is inside
   * the current view. If true, the map will attempt animating zoom
   * disregarding where zoom origin is. Setting false will make it always reset
   * the view completely without animation.
   */
  bool animate;
}

//class FitBoundsOptions extends ZoomPanOptions {
//}
