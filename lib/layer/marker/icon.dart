part of leaflet.layer.marker;

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