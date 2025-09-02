package tools.src.packer;

import haxe.Json;
import haxe.io.Path;

import sys.io.File;

import tools.src.packer.Save.saveImage;
import tools.src.packer.TilesetConfig.validateTilesetConfig;

private typedef TilesetList = {
  var tilesets: Array<TilesetConfig>;
}

class Tileset {
  public var image: Image;

  /**
   * Create the tilesets from the given json file.
   * @param path The path to the json file.
   */
  public static function fromJson(path: String) {
    final content = File.getContent(path);
    final currentDir = Sys.getCwd();

    Sys.setCwd(Path.directory(path));

    final tilesetList: TilesetList = Json.parse(content);

    if (tilesetList.tilesets == null) {
      Sys.println('no tilesets found');
      return;
    }
    for (config in tilesetList.tilesets) {
      final tileset = new Tileset(config);
      if (tileset.image == null) {
        Sys.println('Error creating tileset from config: ${config.sourceImage}');
        continue;
      }

      // Save the tileset image to the output folder.
      final outputPath = Path.join([Sys.getCwd(), config.outputPath]);
      if (!sys.FileSystem.exists(outputPath)) {
        sys.FileSystem.createDirectory(outputPath);
      }
      saveImage(config.name, tileset.image, outputPath);
      #if !unit_testing
      Sys.println('Tileset "${config.name}" has been created.');
      #end
    }
    Sys.setCwd(currentDir);
  }

  /**
   * Create a new Tileset from the given configuration.
   * @param config The tileset configuration.
   */
  public function new(config: TilesetConfig) {
    validateTilesetConfig(config);

    final imagePath = Path.join([Sys.getCwd(), config.sourceImage]);
    final sourceImage = Image.fromFile(imagePath, false, 0);

    final tiles = extractTiles(sourceImage, config);
    var horizontalTileCount = 0;
    for (row in tiles) {
      // Remove trailing empty tiles
      var length = row.length - 1;
      while (length >= 0) {
        if (row[length].isEmpty()) {
          // row.pop();
        } else {
          break;
        }
        length--;
      }
      if (row.length > horizontalTileCount) {
        horizontalTileCount = row.length;
      }
    }

    var length = tiles.length - 1;
    while (length >= 0) {
      if (tiles[length].length == 0) {
        // tiles.pop();
      } else {
        break;
      }
      length--;
    }

    final verticalTileCount = tiles.length;
    final extrude = (config.extrude) * 2;

    final imageWidth = horizontalTileCount * (config.tileWidth + extrude);
    final imageHeight = verticalTileCount * (config.tileHeight + extrude);

    image = createTilesImage(imageWidth, imageHeight, tiles);
  }

  /**
   * Extract the tile images from the source image.
   * @param image The source image.
   * @param config The tileset configuration.
   * @return A 2D array of tile images.
   */
  function extractTiles(image: Image, config: TilesetConfig): Array<Array<Image>> {
    final horizontalTiles = Math.floor(image.width / config.tileWidth);
    final verticalTiles = Math.floor(image.height / config.tileHeight);

    final tiles: Array<Array<Image>> = [];
    for (y in 0...verticalTiles) {
      final row: Array<Image> = [];
      for (x in 0...horizontalTiles) {
        final tileX = x * config.tileWidth;
        final tileY = y * config.tileHeight;
        final tileImage = new Image({ width: config.tileWidth, height: config.tileHeight });
        tileImage.insertImage({
          srcImage: image,
          srcX: tileX,
          srcY: tileY,
          srcWidth: config.tileWidth,
          srcHeight: config.tileHeight
        });
        tileImage.extrudeEdges(config.extrude);
        row.push(tileImage);
      }

      if (row.length > 0) {
        tiles.push(row);
      }
    }

    return tiles;
  }

  /**
   * Create an image from the given tiles.
   * @param width The width of the image in pixels.
   * @param height The height of the image in pixels.
   * @param tiles The tiles to include in the image.
   * @return The created image.
   */
  function createTilesImage(width: Int, height: Int, tiles: Array<Array<Image>>): Image {
    final image = new Image({ width: width, height: height });

    for (y in 0...tiles.length) {
      for (x in 0...tiles[y].length) {
        {
          final tileImage = tiles[y][x];
          final destX = x * tileImage.width;
          final destY = y * tileImage.height;
          image.insertImage({
            srcImage: tileImage,
            srcX: 0,
            srcY: 0,
            srcWidth: tileImage.width,
            srcHeight: tileImage.height,
            destX: destX,
            destY: destY,
          });
        }
      }
    }

    return image;
  }
}
