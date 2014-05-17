part of leaflet.layer.marker;

class IconOptions {
  // (required) The URL to the icon image (absolute or relative to your script path).
  String  iconUrl;
  // The URL to a retina sized version of the icon image (absolute or relative to your script path). Used for Retina screen devices.
  String  iconRetinaUrl;
  // Size of the icon image in pixels.
  Point iconSize;
  // The coordinates of the "tip" of the icon (relative to its top left corner). The icon will be aligned so that this point is at the marker's geographical location. Centered by default if size is specified, also can be set in CSS with negative margins.
  Point iconAnchor;
  // The URL to the icon shadow image. If not specified, no shadow image will be created.
  String  shadowUrl;
  // The URL to the retina sized version of the icon shadow image. If not specified, no shadow image will be created. Used for Retina screen devices.
  String  shadowRetinaUrl;
  // Size of the shadow image in pixels.
  Point shadowSize;
  // The coordinates of the "tip" of the shadow (relative to its top left corner) (the same as iconAnchor if not specified).
  Point shadowAnchor;
  // The coordinates of the point from which popups will "open", relative to the icon anchor.
  Point popupAnchor;
  // A custom class name to assign to both icon and shadow images. Empty by default.
  String  className;
}

// Icon is an image-based icon class that you can use with L.Marker for custom markers.
class Icon {

  final Map<String, Object> options = {
    /*
    iconUrl: (String) (required)
    iconRetinaUrl: (String) (optional, used for retina devices if detected)
    iconSize: (Point) (can be set through CSS)
    iconAnchor: (Point) (centered by default, can be set in CSS with negative margins)
    popupAnchor: (Point) (if not specified, popup opens in the anchor point)
    shadowUrl: (String) (no shadow by default)
    shadowRetinaUrl: (String) (optional, used for retina devices if detected)
    shadowSize: (Point)
    shadowAnchor: (Point)
    */
    'className': ''
  };

  Icon(Map<String, Object> options) {
    this.options.addAll(options);
  }

  createIcon(oldIcon) {
    return this._createIcon('icon', oldIcon);
  }

  createShadow(oldIcon) {
    return this._createIcon('shadow', oldIcon);
  }

  _createIcon(name, oldIcon) {
    var src = this._getIconUrl(name);

    if (src == null) {
      if (name == 'icon') {
        throw new Exception('iconUrl not set in Icon options (see the docs).');
      }
      return null;
    }

    var img;
    if (oldIcon == null || oldIcon.tagName != 'IMG') {
      img = this._createImg(src);
    } else {
      img = this._createImg(src, oldIcon);
    }
    this._setIconStyles(img, name);

    return img;
  }

  _setIconStyles(img, String name) {
    final options = this.options,
        size = new Point(options[name + 'Size']);
    var anchor = null;

    if (name == 'shadow') {
      anchor = new Point(options.containsKey('shadowAnchor') ? options['shadowAnchor'] : options['iconAnchor']);
    } else {
      anchor = new Point(options['iconAnchor']);
    }

    if (anchor == null && size != null) {
      anchor = size.divideBy(2, true);
    }

    img.className = 'leaflet-marker-' + name + ' ' + options['className'];

    if (anchor != null) {
      img.style.marginLeft = (-anchor.x) + 'px';
      img.style.marginTop  = (-anchor.y) + 'px';
    }

    if (size != null) {
      img.style.width  = size.x + 'px';
      img.style.height = size.y + 'px';
    }
  }

  _createImg(src, el) {
    el = el || document.createElement('img');
    el.src = src;
    return el;
  }

  _getIconUrl(String name) {
    if (Browser.retina && this.options[name + 'RetinaUrl']) {
      return this.options[name + 'RetinaUrl'];
    }
    return this.options[name + 'Url'];
  }
}