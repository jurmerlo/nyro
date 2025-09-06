package nyro.input;

import nyro.events.Event;
import nyro.events.EventType;

/**
 * MouseEvent for sending mouse input events.
 */
class MouseEvent extends Event {
  /**
   * Mouse down event type.
   */
  public static inline final MOUSE_DOWN: EventType<MouseEvent> = 'nyro_mouse_down';

  /**
   * Mouse up event type.
   */
  public static inline final MOUSE_UP: EventType<MouseEvent> = 'nyro_mouse_up';

  /**
   * Mouse move event type.
   */
  public static inline final MOUSE_MOVE: EventType<MouseEvent> = 'nyro_mouse_move';

  /**
   * Mouse scroll wheel event type.
   */
  public static inline final MOUSE_WHEEL: EventType<MouseEvent> = 'nyro_mouse_wheel';

  /**
   * Mouse enter event type.
   */
  public static inline final MOUSE_ENTER: EventType<MouseEvent> = 'nyro_mouse_enter';

  /**
   * Mouse leave event type.
   */
  public static inline final MOUSE_LEAVE: EventType<MouseEvent> = 'nyro_mouse_leave';

  /**
   * The button pressed.
   */
  var button: Int;

  /**
   * The x position of the mouse in window pixels.
   */
  var x: Float;

  /**
   * The y position of the mouse in window pixels.
   */
  var y: Float;

  /**
   * The amount moved on the x axis since the last event in window pixels.
   */
  var deltaX: Float;

  /**
   * The amount moved on the y axis since the last even in window pixels.
   */
  var deltaY: Float;
}
