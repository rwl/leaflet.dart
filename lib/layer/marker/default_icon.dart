part of leaflet.layer.marker;

// Default is the blue marker icon used by default in Leaflet.
class Default extends Icon {
  final Map<String, Object> options = {
    'iconSize': [25, 41],
    'iconAnchor': [12, 41],
    'popupAnchor': [1, -34],

    'shadowSize': [41, 41]
  };

  Default() : super({});

  _getIconUrl(String name) {
    var key = name + 'Url';

    if (this.options.containsKey(key)) {
      return this.options[key];
    }

    if (Browser.retina && name == 'icon') {
      name += '-2x';
    }

    final path = Icon.Default.imagePath;

    if (path == null) {
      throw new Exception('Couldn\'t autodetect Icon.Default.imagePath, set it manually.');
    }

    return path + '/marker-' + name + '.png';
  }
}