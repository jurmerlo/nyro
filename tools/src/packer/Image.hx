package tools.src.packer;

import haxe.io.Bytes;

import sys.io.File;

/**
 * Parameters for the insertImage function.
 */
typedef InsertImageParams = {
  /**
   * The image to insert.
   */
  var srcImage: Image;

  /**
   * Where to start copying the source image in pixels.
   */
  var srcX: Int;

  /**
   * Where to start copying the source image in pixels.
   */
  var srcY: Int;

  /**
   * The width of the image to insert in pixels. If null, the original width is used.
   */
  var ?srcWidth: Int;

  /**
   * The height of the image to insert in pixels. If null, the original height is used.
   */
  var ?srcHeight: Int;

  /**
   * Where to start inserting the image in pixels. If null 0 is used.
   */
  var ?destX: Int;

  /**
   * Where to start inserting the image in pixels. If null 0 is used.
   */
  var ?destY: Int;
};

/**
 * This class holds image data and can manipulate it.
 */
class Image {
  /**
   * The width of the image in pixels.
   */
  public var width(default, null): Int;

  /**
   * The height of the image in pixels.
   */
  public var height(default, null): Int;

  /**
   * Should the empty border sprites be removed.
   */
  public var trimmed(default, null): Bool;

  /**
   * Trimmed x offset in pixels.
   */
  public var sourceX(default, null): Int = 0;

  /**
   * Trimmed y offset in pixels.
   */
  public var sourceY(default, null): Int = 0;

  /**
   * The original image width before trimming and extruding in pixels.
   */
  public var sourceWidth(default, null): Int;

  /**
   * The original image height before trimming and extruding in pixels.
   */
  public var sourceHeight(default, null): Int;

  /**
   * The amount of pixels the borders should be extruded by.
   */
  public final extrude: Int;

  /**
   * The image data.
   */
  var data: Bytes;

  /**
   * The amount of bytes per pixel.
   */
  final stride = 4;

  /**
   * Create an image from a file.
   * @param path The file path.
   * @param trim Trim or not.
   * @param extrude Amount to be extruded.
   * @return The created image.
   */
  public static function fromFile(path: String, trim: Bool, extrude: Int): Image {
    final file = File.read(path);
    final data = new format.png.Reader(file).read();
    final pixelData = format.png.Tools.extract32(data);
    format.png.Tools.reverseBytes(pixelData);
    final header = format.png.Tools.getHeader(data);

    return new Image({
      width: header.width,
      height: header.height
    }, pixelData, trim, extrude);
  }

  /**
   * Create a new Image instance.
   * @param size The width and height of the image in pixels.
   * @param data Optional image data. 
   * @param trim If true remove transparent borders.
   * @param extrude The amount of pixels to extrude from the edges.
   */
  public function new(size: Size, ?data: Bytes, trim = false, extrude = 0) {
    width = size.width;
    height = size.height;
    sourceWidth = width;
    sourceHeight = height;
    trimmed = trim;
    this.extrude = extrude;

    this.data = Bytes.alloc(width * height * stride);
    if (data == null) {
      this.data.fill(0, width * height * stride, 0);
    } else {
      this.data.blit(0, data, 0, data.length);
      if (trimmed) {
        trimTransparentPixels();
      }

      if (extrude > 0) {
        extrudeEdges(extrude);
      }
    }
  }

  /**
   * Insert an image into this image.
   * @param params The parameters for inserting the image.
   */
  public function insertImage(params: InsertImageParams) {
    params.srcWidth ??= params.srcImage.width;
    params.srcHeight ??= params.srcImage.height;
    params.destX ??= 0;
    params.destY ??= 0;

    // Copy the image pixel by pixel.
    var destOffsetX = 0;
    var destOffsetY = 0;
    for (y in params.srcY...(params.srcY + params.srcHeight)) {
      destOffsetX = 0;
      for (x in params.srcX...(params.srcX + params.srcWidth)) {
        setPixel(params.destX + destOffsetX, params.destY + destOffsetY, params.srcImage.getPixel(x, y));
        destOffsetX++;
      }
      destOffsetY++;
    }
  }

  /**
   * Return the image pixels in bytes.
   */
  public function getPixels(): Bytes {
    return data;
  }

  /**
   * Get the color of a pixel.
   * @param x The x position in pixels.
   * @param y The y position in pixels.
   * @return The pixel color.
   */
  public function getPixel(x: Int, y: Int): Color {
    final start = (y * width + x) * stride;

    return return new Color(data.get(start), data.get(start + 1), data.get(start + 2), data.get(start + 3));
  }

  /**
   * Set a pixel in this image.
   * @param x The x position in pixels.
   * @param y The y position in pixels.
   * @param color The color to set.
   */
  public function setPixel(x: Int, y: Int, color: Color) {
    final start = (y * width + x) * stride;
    data.set(start, color.a);
    data.set(start + 1, color.r);
    data.set(start + 2, color.g);
    data.set(start + 3, color.b);
  }

  /**
   * Extrude the edges of the image.
   * @param amount The amount of pixels to extrude out.
   */
  public function extrudeEdges(amount: Int) {
    final original = new Image({ width: width, height: height }, data);

    // Total width and height adjusted by the amount to extrude on both sides.
    width += amount * 2;
    height += amount * 2;

    final size = width * height * stride;
    data = Bytes.alloc(size);
    data.fill(0, stride, 0);
    insertImage({
      srcImage: original,
      srcX: 0,
      srcY: 0,
      destX: amount,
      destY: amount
    });
    var color: Color;
    for (y in amount...original.height + amount) {
      // Extrude the left.
      color = getPixel(amount, y);
      for (x in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the right.
      color = getPixel(width - amount - 1, y);
      for (x in width - amount - 1...width) {
        setPixel(x, y, color);
      }
    }

    for (x in amount...original.width + amount) {
      // Extrude the top.
      color = getPixel(x, amount);
      for (y in 0...amount) {
        setPixel(x, y, color);
      }

      // Extrude the bottom.
      color = getPixel(x, height - amount - 1);
      for (y in height - amount - 1...height) {
        setPixel(x, y, color);
      }
    }
  }

  /**
   * Check if this image is empty (fully transparent).
   * @return True if the image only contains transparent pixels.
   */
  public function isEmpty(): Bool {
    for (y in 0...height) {
      if (!isRowEmpty(y)) {
        return false;
      }
    }

    return true;
  }

  /**
   * Remove transparent borders to make the image smaller in the atlas.
   * Moves in from each side until a non transparent pixel is found.
   */
  function trimTransparentPixels() {
    final temp = new Image({ width: width, height: height }, data);

    // From the left side in.
    var leftOffset = 0;
    for (x in 0...width) {
      if (!temp.isColumnEmpty(x)) {
        break;
      }
      leftOffset++;
    }

    // From the right side in.
    var rightOffset = 0;
    var x = width - 1;
    while (x >= 0) {
      if (!temp.isColumnEmpty(x)) {
        break;
      }
      rightOffset++;
      x--;
    }

    // From the top in.
    var topOffset = 0;
    for (y in 0...height) {
      if (!temp.isRowEmpty(y)) {
        break;
      }
      topOffset++;
    }

    // From the bottom in.
    var bottomOffset = 0;
    var y = height - 1;
    while (y >= 0) {
      if (!temp.isRowEmpty(y)) {
        break;
      }
      bottomOffset++;
      y--;
    }

    width = temp.width - leftOffset - rightOffset;
    height = temp.height - topOffset - bottomOffset;

    // allocate the image data with the new size.
    data = Bytes.alloc(width * height * stride);
    var pos = 0;
    var color: Color;

    // Update the bytes with the trimmed sprite.
    for (y in topOffset...topOffset + height) {
      for (x in leftOffset...leftOffset + width) {
        color = temp.getPixel(x, y);
        data.set(pos, color.a);
        data.set(pos + 1, color.r);
        data.set(pos + 2, color.g);
        data.set(pos + 3, color.b);
        pos += stride;
      }
    }
    sourceX = leftOffset;
    sourceY = topOffset;
  }

  /**
   * Check if a column of pixels in this image is empty.
   * @param column The column index to check.
   * @return True if the column only contains transparent pixels.
   */
  function isColumnEmpty(column: Int): Bool {
    for (y in 0...height) {
      if (getPixel(column, y).a != 0) {
        return false;
      }
    }

    return true;
  }

  /**
   * Check if a row of pixels in this image is empty.
   * @param row The row index to check.
   * @return True if the row only contains transparent pixels.
   */
  function isRowEmpty(row: Int): Bool {
    for (x in 0...width) {
      if (getPixel(x, row).a != 0) {
        return false;
      }
    }

    return true;
  }
}
