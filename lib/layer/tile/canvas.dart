part of leaflet.layer.tile;

class CanvasOptions extends TileLayerOptions {
  /**
   * Indicates that tiles will be drawn asynchronously. tileDrawn method
   * should be called for each tile after drawing completion.
   */
  bool async = false;
}

/**
 * Canvas is a class that you can use as a base for creating
 * dynamically drawn Canvas-based tile layers.
 */
abstract class Canvas extends TileLayer {

  CanvasOptions get canvasOptions => options as CanvasOptions;
  /*var options = {
    'async': false
  };*/

  Canvas([CanvasOptions options=null]) : super("", options) {
    if (options == null) {
      options = new CanvasOptions();
    }
  }

  redraw() {
    if (_map != null) {
      _reset({'hard': true});
      _update();
    }

    for (var i in _tiles) {
      _redrawTile(_tiles[i]);
    }
    return this;
  }

  _redrawTile(Element tile) {
    drawTile(tile, tile._tilePoint, _map.getZoom());
  }

  _createTile() {
    var tile = dom.create('canvas', 'leaflet-tile');
    tile.width = tile.height = options.tileSize;
    tile.onselectstart = tile.onmousemove = core.falseFn;
    return tile;
  }

  _loadTile(tile, tilePoint) {
    tile._layer = this;
    tile._tilePoint = tilePoint;

    _redrawTile(tile);

    if (!canvasOptions.async) {
      tileDrawn(tile);
    }
  }

  /**
   * You need to define this method after creating the instance to draw
   * tiles; canvas is the actual canvas tile on which you can draw,
   * tilePoint represents the tile numbers, and zoom is the current zoom.
   */
  drawTile([CanvasElement tile, Point2D tilePoint, num zoom]);
    // override with rendering code

  /**
   * If async option is defined, this function should be called for each
   * tile after drawing completion. canvas is the same canvas element,
   * that was passed to drawTile.
   */
  tileDrawn(/*Canvas*/Element tile) {
    _tileOnLoad.call(tile);
  }
}