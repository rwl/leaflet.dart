part of leaflet.layer;

typedef PointToLayerFunc(GeoJSON featureData, LatLng latlng);
typedef StyleFunc(GeoJSON featureData);
typedef FeatureFunc(sfs.Feature featureData, [Layer layer]);
typedef bool FilterFunc(sfs.Feature featureData, [Layer layer]);
typedef LatLng CoordsToLatLngFunc(List coords);

class GeoJSONOptions extends PathOptions {
  /// Function that will be used for creating layers for GeoJSON points
  /// (if not specified, simple markers will be created).
  PointToLayerFunc pointToLayer;

  /// Function that will be used to get style options for vector layers
  /// created for GeoJSON features.
  StyleFunc style;

  /// Function that will be called on each created feature layer. Useful
  /// for attaching events and popups to features.
  FeatureFunc onEachFeature;

  /// Function that will be used to decide whether to show a feature or not.
  FilterFunc filter;

  /// Function that will be used for converting GeoJSON coordinates to LatLng
  /// points (if not specified, coords will be assumed to be WGS84 — standard
  /// [longitude, latitude] values in degrees).
  CoordsToLatLngFunc coordsToLatLng;
}

/// GeoJSON turns any GeoJSON data into a Leaflet layer.
class GeoJSON extends FeatureGroup {

  GeoJSONOptions options;

  /// Creates a GeoJSON layer. Optionally accepts an object in GeoJSON format
  /// to display on the map (you can alternatively add it later with addFeature
  /// method) and an options object.
  GeoJSON([sfs.Feature geojson = null, this.options = null]) : super([]) {
    //_layers = {};

    if (geojson != null) {
      addFeature(geojson);
    }
  }

  /// Adds a GeoJSON feature to the layer.
  void addFeatures(sfs.FeatureCollection features) {
    //final features = geojson is List ? geojson : geojson.features;

    if (features != null) {
      //for (int i = 0; i < features.length; i++) {
      for (sfs.Feature feature in features) {
        // Only add this if geometry or geometries are set and not null
        //feature = features[i];
        //if (feature.geometries || feature.geometry || feature.features || feature.coordinates) {
        if (feature.geometry != null) {
          addFeature(feature);
        }
      }
      return;
    }
  }

  void addFeature(sfs.Feature feature) {
    if (options.filter != null && !options.filter(feature)) {
      return;
    }

    final layer = GeoJSON.geometryToLayer(feature, options.pointToLayer, options.coordsToLatLng, options);
    layer.feature = GeoJSON.asFeature(feature);

    layer.defaultOptions = layer.options;
    resetStyle(layer);

    if (options.onEachFeature != null) {
      options.onEachFeature(geojson, layer);
    }

    addLayer(layer);
  }

  /// Resets the given vector layer's style to the original GeoJSON style,
  /// useful for resetting style after hover events.
  void resetStyle(Path layer) {
    final style = options.style;
    if (style != null) {
      // reset any custom styles
      layer.options.addAll(layer.defaultOptions);

      _setLayerStyle(layer, style);
    }
  }

  /// Changes styles of GeoJSON vector layers with the given style function.
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


  /// Creates a layer from a given GeoJSON feature.
  static Layer geometryToLayer(sfs.Feature geojson, Function pointToLayer, Function coordsToLatLng, var vectorOptions) {
    final geometry = geojson.geometry;//geojson.type == 'Feature' ? geojson.geometry : geojson,
        //coords = geometry.coordinates;
    List<Layer> layers = [];

    coordsToLatLng = coordsToLatLng == null ? GeoJSON.coordsToLatLng : coordsToLatLng;

    if (geometry is sfs.Point) {
      //final latlng = coordsToLatLng(coords);
      final latlng = new LatLng(geometry.x, geometry.y, geometry.z);
      return pointToLayer != null ? pointToLayer(geojson, latlng) : new Marker(latlng);

    } else if (geometry is sfs.MultiPoint) {
      //for (int i = 0; i < coords.length; i++) {
      for (sfs.Point point in geometry) {
        //final latlng = coordsToLatLng(coords[i]);
        final latlng = new LatLng(point.x, point.y, point.z);
        layers.add(pointToLayer != null ? pointToLayer(geojson, latlng) : new Marker(latlng));
      }
      return new FeatureGroup(layers);

    } else if (geometry is sfs.LineString) {
      final latlngs = coordsToLatLngs(geometry.toList(), 0, coordsToLatLng);
      return new Polyline(latlngs, vectorOptions);

    } else if (geometry is sfs.Polygon) {
      if (coords.length == 2 && coords[1].length == 0) {
        throw new Exception('Invalid GeoJSON object.');
      }
      final latlngs = coordsToLatLngs(coords, 1, coordsToLatLng);
      return new Polygon(latlngs, vectorOptions);

    } else if (geometry is sfs.MultiLineString) {
      final latlngs = coordsToLatLngs(coords, 1, coordsToLatLng);
      return new MultiPolyline(latlngs, vectorOptions);

    } else if (geometry is sfs.MultiPolygon) {
      final latlngs = coordsToLatLngs(coords, 2, coordsToLatLng);
      return new MultiPolygon(latlngs, vectorOptions);

    } else if (geometry is sfs.GeometryCollection) {
      for (int i = 0; i < geometry.length; i++) {
        layers.add(geometryToLayer(new sfs.Feature(geometry[i], geojson.properties),
            pointToLayer, coordsToLatLng, vectorOptions));
      }
      return new FeatureGroup(layers);
    } else {
      throw new Exception('Invalid GeoJSON object.');
    }
  }

  /// Creates a LatLng object from an array of 2 numbers (latitude, longitude)
  /// used in GeoJSON for points. If reverse is set to true, the numbers will
  /// be interpreted as (longitude, latitude).
  static LatLng coordsToLatLng(List coords) {
    return new LatLng(coords[1], coords[0], coords[2]);
  }

  /// Creates a multidimensional array of LatLng objects from a GeoJSON
  /// coordinates array. levelsDeep specifies the nesting level (0 is for
  /// an array of points, 1 for an array of arrays of points, etc., 0 by
  /// default). If reverse is set to true, the numbers will be interpreted
  /// as (longitude, latitude).
  static List<LatLng> coordsToLatLngs(List<sfs.Point> coords, [num levelsDeep = null, CoordsToLatLngFunc coordsToLatLng = null]) {
    List<LatLng> latlngs = [];

    for (int i = 0; i < coords.length; i++) {
      final latlng = levelsDeep != null ?
              coordsToLatLngs([coords[i]], levelsDeep - 1, coordsToLatLng) :
              (coordsToLatLng != null ? coordsToLatLng : GeoJSON.coordsToLatLng)(coords[i]);

      latlngs.add(latlng);
    }

    return latlngs;
  }

  static List<sfs.Point> latLngToCoords(LatLng latlng) {
    final coords = [latlng.lng, latlng.lat];

    if (latlng.alt != null) {
      coords.add(latlng.alt);
    }
    return coords;
  }

  static List latLngsToCoords(List<LatLng> latLngs) {
    List coords = [];

    for (int i = 0, len = latLngs.length; i < len; i++) {
      coords.add(GeoJSON.latLngToCoords(latLngs[i]));
    }

    return coords;
  }

  static sfs.Feature getFeature(Layer layer, sfs.Geometry newGeometry) {
    if (_layerFeatures[layer] != null) {
      return new sfs.Feature(newGeometry, _layerFeatures[layer].properties);
    } else {
      //return GeoJSON.asFeature(newGeometry);
      return new sfs.Feature(newGeometry);
    }
  }

  /*static sfs.Feature asFeature(geoJSON) {
    if (geoJSON is sfs.Feature) {
      return geoJSON;
    }

    return new sfs.Feature(geoJSON);
  }*/
}

final _layerFeatures = new Expando<sfs.Feature>();

/*
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
*/
