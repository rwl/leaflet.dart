library leaflet.layer.marker.icon;

// Default is the blue marker icon used by default in Leaflet.
class Default extends Icon {
  var options = {
    'iconSize': [25, 41],
    'iconAnchor': [12, 41],
    'popupAnchor': [1, -34],

    'shadowSize': [41, 41]
  };

  _getIconUrl(name) {
    var key = name + 'Url';

    if (this.options[key]) {
      return this.options[key];
    }

    if (L.Browser.retina && name == 'icon') {
      name += '-2x';
    }

    var path = L.Icon.Default.imagePath;

    if (!path) {
      throw new Error('Couldn\'t autodetect L.Icon.Default.imagePath, set it manually.');
    }

    return path + '/marker-' + name + '.png';
  }
}