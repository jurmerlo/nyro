package tools.src.packer;

/**
 * Rect representing the position and size inside the sprite atlas in pixels.
 */
private typedef Rect = {
  /**
   * The x position of the rectangle in pixels.
   */
  var x: Int;

  /**
   * The y position of the rectangle in pixels.
   */
  var y: Int;

  /**
   * The width of the rectangle in pixels.
   */
  var width: Int;

  /**
   * The height of the rectangle in pixels.
   */
  var height: Int;
}

/**
 * Frame representing a single frame in a sprite atlas.
 */
typedef Frame = {
  /**
   * The filename without the extension of the image this frame belongs to.
   */
  var filename: String;

  /**
   * The frame rectangle in pixels inside the atlas.
   */
  var frame: Rect;

  /**
   * The source size and offset of the original image in pixels.
   */
  var source: Rect;

  /**
   * Whether the frame is trimmed or not. Trimmed means that the image has been cropped to remove transparent
   * pixels around the edges.
   */
  var trimmed: Bool;
}
