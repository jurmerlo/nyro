package tools.src.packer;

import tools.src.utils.Config.throwMissingField;

/**
 * Configuration for tileset padding.
 */
typedef TilesetConfig = {
  /**
   * The output name of the tileset image.
   */
  var name: String;

  /**
   * The folder where the tileset image will be saved.
   */
  var outputPath: String;

  /**
   * The source image to use for the tileset.
   */
  var sourceImage: String;

  /**
   * The width of each tile in pixels.
   */
  var tileWidth: Int;

  /**
   * The height of each tile in pixels.
   */
  var tileHeight: Int;

  /**
   * The amount of padding to add around each tile in pixels.
   * This helps with rendering issues in tilemaps.
   * Defaults to 1 pixel.
   */
  var ?extrude: Int;
}

/**
 * Validate the tileset configuration.
 * @param config The configuration to validate.
 */
function validateTilesetConfig(config: TilesetConfig): Void {
  if (config.name == null || config.name == '') {
    throwMissingField('name', 'tileset config');
  }
  if (config.outputPath == null || config.outputPath == '') {
    throwMissingField('outputPath', 'tileset config');
  }
  if (config.sourceImage == null || config.sourceImage == '') {
    throwMissingField('sourceImage', 'tileset config');
  }
  if (config.tileWidth == null || config.tileWidth <= 0) {
    throwMissingField('tileWidth', 'tileset config');
  }
  if (config.tileHeight == null || config.tileHeight <= 0) {
    throwMissingField('tileHeight', 'tileset config');
  }

  config.extrude ??= 1;
}
