package tools.src.packer;

typedef RectangleParams = {
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

  /**
   * Optional filename of the image this rectangle belongs to.
   */
  var ?name: String;
};

/**
 * Rectangle class.
 */
class Rectangle {
  /**
   * Filename of the image this rectangle belongs to.
   */
  public final name: String;

  /**
   * The x position of the rectangle in pixels.
   */
  public var x: Int;

  /**
   * The y position of the rectangle in pixels.
   */
  public var y: Int;

  /**
   * The width of the rectangle in pixels.
   */
  public var width: Int;

  /**
   * The height of the rectangle in pixels.
   */
  public var height: Int;

  /**
   * Constructor.
   * @param params The parameters for the rectangle.
   */
  public function new(params: RectangleParams) {
    this.x = params.x;
    this.y = params.y;
    this.width = params.width;
    this.height = params.height;
    this.name = params.name ?? '';
  }

  /**
   * Clone this rectangle into a new one.
   * @return The new rectangle.
   */
  public function clone(): Rectangle {
    return new Rectangle({
      x: x,
      y: y,
      width: width,
      height: height,
      name: name
    });
  }

  /**
   * Calculate the area of this rectangle.
   * @return The area in pixels.
   */
  public function area(): Int {
    return width * height;
  }
}
