package tools.src.packer;

import haxe.Json;
import haxe.io.Path;

import sys.io.File;

/**
 * Save the atlas image to a png file.
 * @param name The name of the file.
 * @param image The image to save.
 * @param outputPath The folder to save to.
 */
function saveImage(name: String, image: Image, outputPath: String) {
  final bytes = image.getPixels();
  final saveData = format.png.Tools.build32ARGB(image.width, image.height, bytes);
  final path = Path.join([outputPath, '${name}.png']);
  final file = File.write(path);
  final writer = new format.png.Writer(file);
  writer.write(saveData);
  file.close();
}

/**
 * Save the json data to a file.
 * @param name The name of the file.
 * @param saveFolder The folder to save to.
 * @param atlas created atlas.
 */
function saveJsonData(name: String, saveFolder: String, atlas: Atlas) {
  final frames: Array<Frame> = [];

  // Use the atlas rectangles to construct the json data.
  for (rect in atlas.packedRectangles) {
    final image = atlas.images[rect.name];
    frames.push({
      filename: rect.name,
      frame: {
        x: rect.x + image.extrude,
        y: rect.y + image.extrude,
        width: rect.width - image.extrude * 2,
        height: rect.height - image.extrude * 2
      },
      trimmed: image.trimmed,
      source: {
        x: image.sourceX,
        y: image.sourceY,
        width: image.sourceWidth,
        height: image.sourceHeight
      },
    });
  }

  final path = Path.join([saveFolder, '${name}.json']);
  final content = Json.stringify({ frames: frames }, '  ');
  File.saveContent(path, content);
}
