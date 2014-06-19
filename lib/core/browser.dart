part of leaflet.core;

final Browser = new BrowserSupport();

class BrowserSupport {

  bool ie, ielt9, webkit, gecko, android, android23;
  bool chrome;
  bool ie3d, webkit3d, gecko3d, opera3d, any3d;

  bool mobile, mobileWebkit, mobileWebkit3d, mobileOpera;

  bool touch, msPointer, pointer;

  bool retina;

  BrowserSupport() {
    /**
     * true for all Internet Explorer versions.
     */
    //ie = window.attributes.containsKey('ActiveXObject');
    bool ie = window.navigator.appName.contains("Microsoft") || window.navigator.appVersion.contains("Trident");
    bool ielt9 = false;//ie && !document.addEventListener;

    // Terrible browser detection to work around Safari / iOS / Android browser bugs.
    final ua = window.navigator.userAgent.toLowerCase();

    /**
     * true for webkit-based browsers like Chrome and Safari (including mobile versions).
     */
    bool webkit = ua.indexOf('webkit') != -1;
    bool chrome = ua.indexOf('chrome') != -1;
    bool phantomjs = ua.indexOf('phantom') != -1;

    /**
     * true for Android mobile browser.
     */
    bool android = ua.indexOf('android') != -1;

    /**
     * true for old Android stock browsers (2 and 3).
     */
    bool android23 = ua.contains(new RegExp(r'android [23]')) != -1;
    var gecko = ua.indexOf('gecko') != -1;
    bool opera = window.navigator.vendor != null && window.navigator.vendor.contains('Opera');
    this.gecko = gecko && !webkit && !opera && !ie;

    /**
     * true for modern mobile browsers (including iOS Safari and different Android browsers).
     */
    //mobile = typeof orientation != undefined + '',
    bool mobile = false;//context['window']['orientation'] != null;

    /**
     * true for mobile Opera.
     */
    bool mobileOpera = mobile && opera;

    bool msPointer = false;//window.navigator && window.navigator.msPointerEnabled && window.navigator.msMaxTouchPoints && !window.PointerEvent;
    bool pointer = true;//(window.PointerEvent && window.navigator.pointerEnabled && window.navigator.maxTouchPoints) || msPointer;

    /**
     * true for devices with Retina screens.
     */
    bool retina = false;//(window.containsKey('devicePixelRatio') && window.devicePixelRatio > 1) || (window.containsKey('matchMedia') && window.matchMedia('(min-resolution:144dpi)') && window.matchMedia('(min-resolution:144dpi)').matches);

    //final doc = document.documentElement;
    bool ie3d = false;//ie && doc.style.containsKey('transition');

    /**
     * true for webkit-based browsers that support CSS 3D transformations.
     */
    bool webkit3d = false;//window.containsKey('WebKitCSSMatrix') && new window.WebKitCSSMatrix().containsKey('m11') && !android23;
    bool gecko3d = false;//doc.style.containsKey('MozPerspective');
    bool opera3d = false;//doc.style.containsKey('OTransition');
    bool any3d = false;//!window.L_DISABLE_3D && (ie3d || webkit3d || gecko3d || opera3d) && !phantomjs;

    /**
     * true for mobile webkit-based browsers.
     */
    bool mobileWebkit = mobile && webkit;
    bool mobileWebkit3d = mobile && webkit3d;

    /**
     * true for all browsers on touch devices.
     */
    bool touch = null;

    /**
     * true for browsers with Microsoft touch model (e.g. IE10).
     */
    bool msTouch = null;
  }
}