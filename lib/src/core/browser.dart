library leaflet.core.browser;

import 'dart:html';

// Terrible browser detection to work around Safari / iOS / Android browser bugs.
final ua = window.navigator.userAgent.toLowerCase();

/// true for all Internet Explorer versions.
final bool ie = window.navigator.appName.contains("Microsoft")
    || window.navigator.appVersion.contains("Trident");

/// true for webkit-based browsers like Chrome and Safari (including mobile versions).
final bool webkit = ua.indexOf('webkit') != -1;

final bool gecko = ua.indexOf('gecko') != -1 && !webkit && !opera && !ie;

final bool chrome = ua.indexOf('chrome') != -1;

final phantomjs = ua.indexOf('phantom') != -1;

final bool opera = window.navigator.vendor != null && window.navigator.vendor.contains('Opera');

/// true for devices with Retina screens.
final bool retina = false;//(window.containsKey('devicePixelRatio') && window.devicePixelRatio > 1) || (window.containsKey('matchMedia') && window.matchMedia('(min-resolution:144dpi)') && window.matchMedia('(min-resolution:144dpi)').matches);

/// true for modern mobile browsers (including iOS Safari and different Android browsers).
final bool mobile = false; //window.orientation != null;

/// true for mobile webkit-based browsers.
final bool mobileWebkit = mobile && webkit;

final bool msPointer = false;//window.navigator && window.navigator.msPointerEnabled && window.navigator.msMaxTouchPoints && !window.PointerEvent;
final bool pointer = true;//(window.PointerEvent && window.navigator.pointerEnabled && window.navigator.maxTouchPoints) || msPointer;

/// true for all browsers on touch devices.
final bool touch = false;

/// true for browsers with Microsoft touch model (e.g. IE10).
final bool msTouch = null;
