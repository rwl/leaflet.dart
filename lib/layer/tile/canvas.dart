part of leaflet.layer.tile;

class CanvasOptions {
  // Indicates that tiles will be drawn asynchronously. tileDrawn method should be called for each tile after drawing completion.
  bool async = false;
}

// Canvas is a class that you can use as a base for creating
// dynamically drawn Canvas-based tile layers.
class Canvas extends TileLayer {
  var options = {
    'async': false
  };

  Canvas(options) {
    L.setOptions(this, options);
  }

  redraw() {
    if (this._map) {
      this._reset({hard: true});
      this._update();
    }

    for (var i in this._tiles) {
      this._redrawTile(this._tiles[i]);
    }
    return this;
  }

  _redrawTile(tile) {
    this.drawTile(tile, tile._tilePoint, this._map._zoom);
  }

  _createTile() {
    var tile = L.DomUtil.create('canvas', 'leaflet-tile');
    tile.width = tile.height = this.options.tileSize;
    tile.onselectstart = tile.onmousemove = L.Util.falseFn;
    return tile;
  }

  _loadTile(tile, tilePoint) {
    tile._layer = this;
    tile._tilePoint = tilePoint;

    this._redrawTile(tile);

    if (!this.options.async) {
      this.tileDrawn(tile);
    }
  }

  drawTile(/*tile, tilePoint*/) {
    // override with rendering code
  }

  tileDrawn(tile) {
    this._tileOnLoad.call(tile);
  }
}