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
    //ie = window.attributes.containsKey('ActiveXObject');
    ie = window.navigator.appName.contains("Microsoft") || window.navigator.appVersion.contains("Trident");
    ielt9 = false;//ie && !document.addEventListener;

    // Terrible browser detection to work around Safari / iOS / Android browser bugs.
    final ua = window.navigator.userAgent.toLowerCase();
    webkit = ua.indexOf('webkit') != -1;
    chrome = ua.indexOf('chrome') != -1;
    bool phantomjs = ua.indexOf('phantom') != -1;
    android = ua.indexOf('android') != -1;
    android23 = ua.contains(new RegExp(r'android [23]')) != -1;
    var gecko = ua.indexOf('gecko') != -1;
    bool opera = window.navigator.vendor != null && window.navigator.vendor.contains('Opera');
    this.gecko = gecko && !webkit && !opera && !ie;

    //mobile = typeof orientation != undefined + '',
    mobile = false;//context['window']['orientation'] != null;
    mobileWebkit = mobile && webkit;
    mobileWebkit3d = mobile && webkit3d;
    mobileOpera = mobile && opera;

    msPointer = false;//window.navigator && window.navigator.msPointerEnabled && window.navigator.msMaxTouchPoints && !window.PointerEvent;
    pointer = true;//(window.PointerEvent && window.navigator.pointerEnabled && window.navigator.maxTouchPoints) || msPointer;
    retina = false;//(window.containsKey('devicePixelRatio') && window.devicePixelRatio > 1) || (window.containsKey('matchMedia') && window.matchMedia('(min-resolution:144dpi)') && window.matchMedia('(min-resolution:144dpi)').matches);

    //final doc = document.documentElement;
    ie3d = false;//ie && doc.style.containsKey('transition');
    webkit3d = false;//window.containsKey('WebKitCSSMatrix') && new window.WebKitCSSMatrix().containsKey('m11') && !android23;
    gecko3d = false;//doc.style.containsKey('MozPerspective');
    opera3d = false;//doc.style.containsKey('OTransition');
    any3d = false;//!window.L_DISABLE_3D && (ie3d || webkit3d || gecko3d || opera3d) && !phantomjs;
  }
}