package nyro.input;

import nyro.events.Event;
import nyro.events.EventType;

/**
 * KeyboardEvent for sending keyboard input events.
 */
class KeyboardEvent extends Event {
  /**
   * Key up event type.
   */
  public static inline final KEY_UP: EventType<KeyboardEvent> = 'nyro_key_up';

  /**
   * Key down event type.
   */
  public static inline final KEY_DOWN: EventType<KeyboardEvent> = 'nyro_key_down';

  /**
   * Key press event type.
   */
  public static inline final KEY_PRESS: EventType<KeyboardEvent> = 'nyro_key_press';

  /**
   * The keycode that was pressed or released.
   */
  var key: KeyCode;

  /**
   * The actual code.
   */
  var code: String;
}
