part of leaflet.layer.tile;

class CanvasOptions {
  /**
   * Indicates that tiles will be drawn asynchronously. tileDrawn method should be called for each tile after drawing completion.
   */
  bool async = false;
}

/**
 * Canvas is a class that you can use as a base for creating
 * dynamically drawn Canvas-based tile layers.
 */
abstract class Canvas extends TileLayer {

  CanvasOptions options;
  /*var options = {
    'async': false
  };*/

  Canvas(this.options, TileLayerOptions tileLayerOptions) : super("", tileLayerOptions);

  redraw() {
    if (this._map) {
      this._reset({'hard': true});
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

  /**
   * You need to define this method after creating the instance to draw tiles; canvas is the actual canvas tile on which you can draw, tilePoint represents the tile numbers, and zoom is the current zoom.
   */
  drawTile(/*CanvasElement tile, Point tilePoint, num zoom*/);
    // override with rendering code

  /**
   * If async option is defined, this function should be called for each tile after drawing completion. canvas is the same canvas element, that was passed to drawTile.
   */
  tileDrawn(CanvasElement tile) {
    this._tileOnLoad.call(tile);
  }
}