part of leaflet.layer.marker;

class DivIconOptions {
  // Size of the icon in pixels. Can be also set through CSS.
  Point iconSize;
  // The coordinates of the "tip" of the icon (relative to its top left corner). The icon will be aligned so that this point is at the marker's geographical location. Centered by default if size is specified, also can be set in CSS with negative margins.
  Point iconAnchor;
  // A custom class name to assign to the icon. 'leaflet-div-icon' by default.
  String  className;
  // A custom HTML code to put inside the div element, empty by default.
  String  html;
}

// DivIcon is a lightweight HTML-based icon class (as opposed to the image-based Icon)
// to use with Marker.
class DivIcon extends Icon {
  final Map<String, Object> options = {
    'iconSize': [12, 12], // also can be set through CSS
    /*
    iconAnchor: (Point)
    popupAnchor: (Point)
    html: (String)
    bgPos: (Point)
    */
    'className': 'leaflet-div-icon',
    'html': false
  };

  DivIcon() : super({});

  createIcon(oldIcon) {
    final div = (oldIcon != null && oldIcon.tagName == 'DIV') ? oldIcon : document.createElement('div'),
        options = this.options;

    if (options['html'] != false) {
      div.innerHTML = options['html'];
    } else {
      div.innerHTML = '';
    }

    if (options.containsKey('bgPos')) {
      div.style.backgroundPosition =
              (-options.bgPos.x) + 'px ' + (-options.bgPos.y) + 'px';
    }

    this._setIconStyles(div, 'icon');
    return div;
  }

  createShadow() {
    return null;
  }
}