package tools.src.packer;

/**
 * Packing options.
 */
enum abstract PackMethod(String) {
  /**
   * Basic orders the rectangle basic on name of the image and doesn't optimize the packing.
   */
  var BASIC = 'basic';

  /**
   * Optimal orders the rectangles based on their size and optimizes the packing.
   * This is the default method.
   * It will try to fit the rectangles in the smallest possible area.
   */
  var OPTIMAL = 'optimal';
}
