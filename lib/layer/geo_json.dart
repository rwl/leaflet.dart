part of leaflet.layer;

typedef PointToLayerFunc(GeoJSON featureData, LatLng latlng);
typedef StyleFunc(GeoJSON featureData);
typedef FeatureFunc(GeoJSON featureData, Layer layer);
typedef bool FilterFunc(GeoJSON featureData, Layer layer);
typedef LatLng CoordsToLatLngFunc(List coords);

class GeoJSONOptions extends PathOptions {
  /**
   * Function that will be used for creating layers for GeoJSON points (if not specified, simple markers will be created).
   */
  PointToLayerFunc pointToLayer;

  /**
   * Function that will be used to get style options for vector layers created for GeoJSON features.
   */
  StyleFunc style;

  /**
   * Function that will be called on each created feature layer. Useful for attaching events and popups to features.
   */
  FeatureFunc onEachFeature;

  /**
   * Function that will be used to decide whether to show a feature or not.
   */
  FilterFunc filter;

  /**
   * Function that will be used for converting GeoJSON coordinates to LatLng points (if not specified, coords will be assumed to be WGS84 — standard [longitude, latitude] values in degrees).
   */
  CoordsToLatLngFunc coordsToLatLng;
}

/**
 * GeoJSON turns any GeoJSON data into a Leaflet layer.
 */
class GeoJSON extends FeatureGroup {

  GeoJSONOptions options;

  /**
   * Creates a GeoJSON layer. Optionally accepts an object in GeoJSON format to display on the map (you can alternatively add it later with addData method) and an options object.
   */
  GeoJSON([geojson = null, this.options = null]) : super([]) {
    //_layers = {};

    if (geojson != null) {
      addData(geojson);
    }
  }

  /**
   * Adds a GeoJSON object to the layer.
   */
  void addData(geojson) {
    final features = geojson is List ? geojson : geojson.features;

    if (features != null) {
      final len = features.length;
      for (int i = 0; i < len; i++) {
        // Only add this if geometry or geometries are set and not null
        feature = features[i];
        if (feature.geometries || feature.geometry || feature.features || feature.coordinates) {
          addData(features[i]);
        }
      }
      return;
    }

    if (options.filter != null && !options.filter(geojson)) {
      return;
    }

    final layer = GeoJSON.geometryToLayer(geojson, options.pointToLayer, options.coordsToLatLng, options);
    layer.feature = GeoJSON.asFeature(geojson);

    layer.defaultOptions = layer.options;
    resetStyle(layer);

    if (options.onEachFeature != null) {
      options.onEachFeature(geojson, layer);
    }

    addLayer(layer);
  }

  /**
   * Resets the given vector layer's style to the original GeoJSON style, useful for resetting style after hover events.
   */
  void resetStyle(Path layer) {
    final style = options.style;
    if (style != null) {
      // reset any custom styles
      layer.options.addAll(layer.defaultOptions);

      _setLayerStyle(layer, style);
    }
  }

  /**
   * Changes styles of GeoJSON vector layers with the given style function.
   */
  void setStyle(StyleFunc style) {
    eachLayer((layer) {
      _setLayerStyle(layer, style);
    });
  }

  void _setLayerStyle(layer, style) {
    if (style is Function) {
      style = style(layer.feature);
    }
    if (layer.setStyle) {
      layer.setStyle(style);
    }
  }


  /**
   * Creates a layer from a given GeoJSON feature.
   */
  static Layer geometryToLayer(geojson, pointToLayer, coordsToLatLng, vectorOptions) {
    var geometry = geojson.type == 'Feature' ? geojson.geometry : geojson,
        coords = geometry.coordinates,
        latlng, latlngs, i, len;
    List layers = [];

    coordsToLatLng = coordsToLatLng || coordsToLatLng;

    switch (geometry.type) {
    case 'Point':
      latlng = coordsToLatLng(coords);
      return pointToLayer ? pointToLayer(geojson, latlng) : new Marker(latlng);

    case 'MultiPoint':
      len = coords.length;
      for (i = 0; i < len; i++) {
        latlng = coordsToLatLng(coords[i]);
        layers.add(pointToLayer ? pointToLayer(geojson, latlng) : new Marker(latlng));
      }
      return new FeatureGroup(layers);

    case 'LineString':
      latlngs = coordsToLatLngs(coords, 0, coordsToLatLng);
      return new Polyline(latlngs, vectorOptions);

    case 'Polygon':
      if (coords.length == 2 && !coords[1].length) {
        throw new Exception('Invalid GeoJSON object.');
      }
      latlngs = coordsToLatLngs(coords, 1, coordsToLatLng);
      return new Polygon(latlngs, vectorOptions);

    case 'MultiLineString':
      latlngs = coordsToLatLngs(coords, 1, coordsToLatLng);
      return new MultiPolyline(latlngs, vectorOptions);

    case 'MultiPolygon':
      latlngs = coordsToLatLngs(coords, 2, coordsToLatLng);
      return new MultiPolygon(latlngs, vectorOptions);

    case 'GeometryCollection':
      len = geometry.geometries.length;
      for (i = 0; i < len; i++) {

        layers.add(geometryToLayer({
          'geometry': geometry.geometries[i],
          'type': 'Feature',
          'properties': geojson.properties
        }, pointToLayer, coordsToLatLng, vectorOptions));
      }
      return new FeatureGroup(layers);

    default:
      throw new Exception('Invalid GeoJSON object.');
    }
  }

  /**
   * Creates a LatLng object from an array of 2 numbers (latitude, longitude) used in GeoJSON for points. If reverse is set to true, the numbers will be interpreted as (longitude, latitude).
   */
  static LatLng coordsToLatLng(List coords) {
    return new LatLng(coords[1], coords[0], coords[2]);
  }

  /**
   * Creates a multidimensional array of LatLng objects from a GeoJSON coordinates array. levelsDeep specifies the nesting level (0 is for an array of points, 1 for an array of arrays of points, etc., 0 by default). If reverse is set to true, the numbers will be interpreted as (longitude, latitude).
   */
  static List<LatLng> coordsToLatLngs(coords, [num levelsDeep = null, CoordsToLatLngFunc coordsToLatLng = null]) {
    var latlng, i, len;
    List latlngs = [];

    len = coords.length;
    for (i = 0; i < len; i++) {
      latlng = levelsDeep != null ?
              coordsToLatLngs(coords[i], levelsDeep - 1, coordsToLatLng) :
              (coordsToLatLng != null ? coordsToLatLng : coordsToLatLng)(coords[i]);

      latlngs.add(latlng);
    }

    return latlngs;
  }

  static List latLngToCoords(LatLng latlng) {
    final coords = [latlng.lng, latlng.lat];

    if (latlng.alt != null) {
      coords.add(latlng.alt);
    }
    return coords;
  }

  static List latLngsToCoords(latLngs) {
    var coords = [];

    for (int i = 0, len = latLngs.length; i < len; i++) {
      coords.add(GeoJSON.latLngToCoords(latLngs[i]));
    }

    return coords;
  }

  static Map getFeature(layer, newGeometry) {
    if (layer.feature != null) {
      final f = {};
      f.addAll(layer.feature);
      f['geometry'] =  newGeometry;
      return f;
    } else {
      return GeoJSON.asFeature(newGeometry);
    }
  }

  static Map asFeature(geoJSON) {
    if (geoJSON.type == 'Feature') {
      return geoJSON;
    }

    return {
      'type': 'Feature',
      'properties': {},
      'geometry': geoJSON
    };
  }
}



multiToGeoJSON(type) {
  return (_this) {
    var coords = [];

    _eachLayer((layer) {
      coords.add(layer.toGeoJSON().geometry.coordinates);
    });

    return GeoJSON.getFeature(_this, {
      'type': type,
      'coordinates': coords
    });
  };
}

class MultiPolylineGeoJSON {
  var toGeoJSON = multiToGeoJSON('MultiLineString');
}

class MultiPolygonGeoJSON {
  var toGeoJSON = multiToGeoJSON('MultiPolygon');
}

class LayerGroupGeoJSON extends LayerGroup {

  LayerGroupGeoJSON() : super([]);
}