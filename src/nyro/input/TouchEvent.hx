package nyro.input;

import nyro.events.Event;
import nyro.events.EventType;

/**
 * TouchEvent for sending touch input events.
 */
class TouchEvent extends Event {
  /**
   * Touch start event type.
   */
  public static inline final TOUCH_START: EventType<TouchEvent> = 'nyro_touch_start';

  /**
   * Touch end event type.
   */
  public static inline final TOUCH_END: EventType<TouchEvent> = 'nyro_touch_end';

  /**
   * Touch move event type.
   */
  public static inline final TOUCH_MOVE: EventType<TouchEvent> = 'nyro_touch_move';

  /**
   * The touch id used.
   */
  var id: Int;

  /**
   * The x position of the touch in screen pixels.
   */
  var x: Float;

  /**
   * The y position of the touch in screen pixels.
   */
  var y: Float;

  /**
   * The amount of touches on screen.
   */
  var touchCount: Int;
}
