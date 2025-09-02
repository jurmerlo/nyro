package tools.src.packer;

import tools.src.utils.Config.throwMissingField;

/**
 * The configuration for the atlas packer.
 */
typedef AtlasConfig = {
  /**
   * The name of the image and data files.
   */
  var name: String;

  /**
   * The folder to store the atlas in relative to the config file.
   */
  var outputPath: String;

  /**
   * A list of folders with images you want to add to the atlas relative to the config file. Not recursive.
   */
  var ?folders: Array<String>;

  /**
   * A list of image files you want to add to the atlas relative to the config file.
   */
  var ?files: Array<String>;

  /**
   * Should the transparent pixels around the images be removed where possible to save space in the atlas.
   * Defaults to true.
   */
  var ?trimmed: Bool;

  /**
   * The amount of pixels to extrude out from the edge of the images. This helps with flickering on the edge of sprites.
   * Especially in tilemaps.
   * Defaults to 1 pixel.
   */
  var ?extrude: Int;

  /**
   * The method to use for packing the sprites.
   * Options:
   * - optimal - The smallest atlas possible.
   * - basic - Sort alphabetically and just add them in the fastest way.
   * Defaults to optimal.
   */
  var ?packMethod: PackMethod;

  /**
   * Should the folder name be included in the name of the sprite in the data file.
   * For when you use duplicate names in separate folders.
   * Defaults to false.
   */
  var ?folderInName: Bool;

  /**
   * The maximum width of the atlas image in pixels.
   * Defaults to 4096 pixels.
   */
  var ?maxWidth: Int;

  /**
   * The maximum height of the atlas image in pixels.
   * Defaults to 4096 pixels.
   */
  var ?maxHeight: Int;

  /**
   * Export only the image file.
   * Defaults to false.
   */
  var ?noData: Bool;
}

/**
 * Set default values for each config for the optional fields if they are null.
 * @param config The config to modify.
 */
function setDefaultConfigValues(config: AtlasConfig) {
  if (config.folders == null) {
    config.folders = [];
  }

  if (config.files == null) {
    config.files = [];
  }

  if (config.trimmed == null) {
    config.trimmed = true;
  }

  if (config.extrude == null) {
    config.extrude = 1;
  }

  if (config.packMethod == null) {
    config.packMethod = OPTIMAL;
  }

  if (config.folderInName == null) {
    config.folderInName = false;
  }

  if (config.maxWidth == null) {
    config.maxWidth = 4096;
  }

  if (config.maxHeight == null) {
    config.maxHeight = 4096;
  }

  if (config.noData == null) {
    config.noData = false;
  }
}

function validateAtlasConfig(config: AtlasConfig) {
  setDefaultConfigValues(config);

  if (config.name == null || config.name == '') {
    throwMissingField('name', 'atlas config');
  }

  if (config.outputPath == null || config.outputPath == '') {
    throwMissingField('outputPath', 'atlas config');
  }

  if (config.folders.length == 0 && config.files.length == 0) {
    throw 'No folders or files specified in the atlas config.';
  }

  if (config.packMethod != OPTIMAL && config.packMethod != BASIC) {
    throw 'Invalid pack method specified in the atlas config. Use "optimal" or "basic".';
  }

  if (config.extrude < 0) {
    throw 'Extrude value must be greater than or equal to zero in the atlas config.';
  }

  if (config.maxWidth <= 0 || config.maxHeight <= 0) {
    throw 'Max width and height must be greater than zero in the atlas config.';
  }
}
