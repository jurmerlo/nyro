package nyro.input;

import nyro.events.Event;
import nyro.events.EventType;

/**
 * GamepadEvent for sending gamepad input events.
 */
class GamepadEvent extends Event {
  /**
   * Gamepad connected event type.
   */
  public static inline final GAMEPAD_CONNECTED: EventType<GamepadEvent> = 'nyro_gamepad_connected';

  /**
   * Gamepad disconnected event type.
   */
  public static inline final GAMEPAD_DISCONNECTED: EventType<GamepadEvent> = 'nyro_gamepad_disconnected';

  /**
   * Gamepad axis event type.
   */
  public static inline final GAMEPAD_AXIS: EventType<GamepadEvent> = 'nyro_gamepad_axis';

  /**
   * Gamepad button event type.
   */
  public static inline final GAMEPAD_BUTTON: EventType<GamepadEvent> = 'nyro_gamepad_button';

  /**
   * The controller id.
   */
  var controllerId: Int;

  /**
   * The button or axis that was triggered.
   */
  var buttonId: String;

  /**
   * The value of the axis or button..
   */
  var value: Float;
}
