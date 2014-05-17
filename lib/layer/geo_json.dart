part of leaflet.layer;

class GeoJSONOptions {
  // Function that will be used for creating layers for GeoJSON points (if not specified, simple markers will be created).
  // ( <GeoJSON> featureData, <LatLng> latlng )
  Function pointToLayer;

  // Function that will be used to get style options for vector layers created for GeoJSON features.
  // ( <GeoJSON> featureData )
  Function style;

  // Function that will be called on each created feature layer. Useful for attaching events and popups to features.
  // ( <GeoJSON> featureData, <ILayer> layer )
  Function onEachFeature;

  // Function that will be used to decide whether to show a feature or not.
  // ( <GeoJSON> featureData, <ILayer> layer )
  Function filter;

  // Function that will be used for converting GeoJSON coordinates to LatLng points (if not specified, coords will be assumed to be WGS84 — standard [longitude, latitude] values in degrees).
  // ( <Array> coords )
  Function coordsToLatLng;
}

// GeoJSON turns any GeoJSON data into a Leaflet layer.
class GeoJSON extends FeatureGroup {

  Map<String, Object> options;

  GeoJSON([geojson = null, Map<String, Object> options = null]) : super([]){
//    L.setOptions(this, options);
    this.options = options;

//    this._layers = {};

    if (geojson != null) {
      this.addData(geojson);
    }
  }

  addData(geojson) {
    var features = geojson is List ? geojson : geojson.features;
    var i, len, feature;

    if (features) {
      len = features.length;
      for (i = 0; i < len; i++) {
        // Only add this if geometry or geometries are set and not null
        feature = features[i];
        if (feature.geometries || feature.geometry || feature.features || feature.coordinates) {
          this.addData(features[i]);
        }
      }
      return this;
    }

    final options = this.options;

    if (options.containsKey('filter') && !options['filter'](geojson)) {
      return this;
    }

    var layer = GeoJSON.geometryToLayer(geojson, options['pointToLayer'], options['coordsToLatLng'], options);
    layer.feature = GeoJSON.asFeature(geojson);

    layer.defaultOptions = layer.options;
    this.resetStyle(layer);

    if (options.containsKey('onEachFeature')) {
      options['onEachFeature'](geojson, layer);
    }

    return this.addLayer(layer);
  }

  resetStyle(layer) {
    var style = this.options['style'];
    if (style != null) {
      // reset any custom styles
      layer.options.addAll(layer.defaultOptions);

      this._setLayerStyle(layer, style);
    }
  }

  setStyle(style) {
    this.eachLayer((layer) {
      this._setLayerStyle(layer, style);
    });
  }

  _setLayerStyle(layer, style) {
    if (style is Function) {
      style = style(layer.feature);
    }
    if (layer.setStyle) {
      layer.setStyle(style);
    }
  }
}

class GeoJSON2 extends GeoJSON {
  GeoJSON2() : super();

  geometryToLayer(geojson, pointToLayer, coordsToLatLng, vectorOptions) {
    var geometry = geojson.type == 'Feature' ? geojson.geometry : geojson,
        coords = geometry.coordinates,
        latlng, latlngs, i, len;
    List layers = [];

    coordsToLatLng = coordsToLatLng || this.coordsToLatLng;

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
      latlngs = this.coordsToLatLngs(coords, 0, coordsToLatLng);
      return new Polyline(latlngs, vectorOptions);

    case 'Polygon':
      if (coords.length == 2 && !coords[1].length) {
        throw new Exception('Invalid GeoJSON object.');
      }
      latlngs = this.coordsToLatLngs(coords, 1, coordsToLatLng);
      return new Polygon(latlngs, vectorOptions);

    case 'MultiLineString':
      latlngs = this.coordsToLatLngs(coords, 1, coordsToLatLng);
      return new MultiPolyline(latlngs, vectorOptions);

    case 'MultiPolygon':
      latlngs = this.coordsToLatLngs(coords, 2, coordsToLatLng);
      return new MultiPolygon(latlngs, vectorOptions);

    case 'GeometryCollection':
      len = geometry.geometries.length;
      for (i = 0; i < len; i++) {

        layers.push(this.geometryToLayer({
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

  coordsToLatLng(coords) { // (Array[, Boolean]) -> LatLng
    return new LatLng(coords[1], coords[0], coords[2]);
  }

  coordsToLatLngs(coords, [num levelsDeep = null, coordsToLatLng = null]) { // (Array[, Number, Function]) -> Array
    var latlng, i, len;
    List latlngs = [];

    len = coords.length;
    for (i = 0; i < len; i++) {
      latlng = levelsDeep != null ?
              this.coordsToLatLngs(coords[i], levelsDeep - 1, coordsToLatLng) :
              (coordsToLatLng != null ? coordsToLatLng : this.coordsToLatLng)(coords[i]);

      latlngs.add(latlng);
    }

    return latlngs;
  }

  latLngToCoords(latlng) {
    var coords = [latlng.lng, latlng.lat];

    if (latlng.alt != null) {
      coords.add(latlng.alt);
    }
    return coords;
  }

  latLngsToCoords(latLngs) {
    var coords = [];

    for (var i = 0, len = latLngs.length; i < len; i++) {
      coords.add(GeoJSON.latLngToCoords(latLngs[i]));
    }

    return coords;
  }

  Map getFeature(layer, newGeometry) {
    if (layer.feature != null) {
      final f = {};
      f.addAll(layer.feature);
      f['geometry'] =  newGeometry;
      return f;
    } else {
      return GeoJSON.asFeature(newGeometry);
    }
  }

  Map asFeature(geoJSON) {
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

var PointToGeoJSON = {
  'toGeoJSON': (_this) {
    return GeoJSON.getFeature(_this, {
      'type': 'Point',
      'coordinates': GeoJSON.latLngToCoords(_this.getLatLng())
    });
  }
};

//L.Marker.include(PointToGeoJSON);
//L.Circle.include(PointToGeoJSON);
//L.CircleMarker.include(PointToGeoJSON);

class PolylineGeoJSON {
  toGeoJSON() {
    return GeoJSON.getFeature(this, {
      'type': 'LineString',
      'coordinates': GeoJSON.latLngsToCoords(this.getLatLngs())
    });
  }
}

class PolygonGeoJSON {
  toGeoJSON() {
    List coords = [GeoJSON.latLngsToCoords(this.getLatLngs())];
    var i, len, hole;

    coords[0].push(coords[0][0]);

    if (this._holes) {
      len = this._holes.length;
      for (i = 0; i < len; i++) {
        hole = L.GeoJSON.latLngsToCoords(this._holes[i]);
        hole.add(hole[0]);
        coords.add(hole);
      }
    }

    return GeoJSON.getFeature(this, {
      'type': 'Polygon',
      'coordinates': coords
    });
  }
}

multiToGeoJSON(type) {
  return (_this) {
    var coords = [];

    _this.eachLayer((layer) {
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

  toGeoJSON() {

    var geometry = this.feature && this.feature.geometry;
    List jsons = [];
    var json;

    if (geometry && geometry.type == 'MultiPoint') {
      return multiToGeoJSON('MultiPoint').call(this);
    }

    var isGeometryCollection = geometry && geometry.type == 'GeometryCollection';

    this.eachLayer((layer) {
      if (layer.toGeoJSON) {
        json = layer.toGeoJSON();
        jsons.add(isGeometryCollection ? json.geometry : GeoJSON.asFeature(json));
      }
    });

    if (isGeometryCollection) {
      return GeoJSON.getFeature(this, {
        'geometries': jsons,
        'type': 'GeometryCollection'
      });
    }

    return {
      'type': 'FeatureCollection',
      'features': jsons
    };
  }
}