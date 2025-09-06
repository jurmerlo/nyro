package platform.love2d.input;

import love.Love;
import love.joystick.GamepadAxis;
import love.joystick.GamepadButton;
import love.joystick.Joystick;
import love.keyboard.KeyConstant;
import love.keyboard.Scancode;

import nyro.input.GamepadEvent;
import nyro.input.KeyCode;
import nyro.input.KeyboardEvent;
import nyro.input.MouseEvent;
import nyro.input.TouchEvent;

class Love2dInput {
  final joysticks: Map<Joystick, Int>;

  var joystickIdCounter: Int;

  var freeJoysticks: Array<Int>;

  public function new() {
    joysticks = new Map();
    joystickIdCounter = 0;
    freeJoysticks = [];

    Love.keypressed = keyPressed;
    Love.keyreleased = keyReleased;
    Love.mousepressed = mousePressed;
    Love.mousereleased = mouseReleased;
    Love.mousemoved = mouseMoved;
    Love.wheelmoved = mouseWheel;
    Love.mousefocus = mouseFocus;
    Love.joystickadded = joystickAdded;
    Love.joystickremoved = joystickRemoved;
    Love.gamepadaxis = gamepadAxis;
    Love.gamepadpressed = gamepadPressed;
    Love.gamepadreleased = gamepadReleased;
  }

  function keyPressed(key: KeyConstant, scancode: Scancode, isRepeated: Bool) {
    KeyboardEvent.send(KeyboardEvent.KEY_DOWN, keyConstantToKeyCode(key), scancode);
  }

  function keyReleased(key: KeyConstant, scancode: Scancode) {
    KeyboardEvent.send(KeyboardEvent.KEY_UP, keyConstantToKeyCode(key), scancode);
  }

  @SuppressWarnings('checkstyle:ParameterNumber')
  function mousePressed(x: Float, y: Float, button: Float, isTouch: Bool, presses: Float) {
    MouseEvent.send(MouseEvent.MOUSE_DOWN, Std.int(button), x, y, -1, -1);
    if (isTouch) {
      TouchEvent.send(TouchEvent.TOUCH_START, 0, x, y, 1);
    }
  }

  @SuppressWarnings('checkstyle:ParameterNumber')
  function mouseReleased(x: Float, y: Float, button: Float, isTouch: Bool, presses: Float) {
    MouseEvent.send(MouseEvent.MOUSE_UP, Std.int(button), x, y, -1, -1);
    if (isTouch) {
      TouchEvent.send(TouchEvent.TOUCH_END, 0, x, y, 1);
    }
  }

  @SuppressWarnings('checkstyle:ParameterNumber')
  function mouseMoved(x: Float, y: Float, dx: Float, dy: Float, isTouch: Bool) {
    MouseEvent.send(MouseEvent.MOUSE_MOVE, -1, x, y, dx, dy);
    if (isTouch) {
      TouchEvent.send(TouchEvent.TOUCH_MOVE, -1, x, y, 1);
    }
  }

  function mouseWheel(x: Float, y: Float) {
    MouseEvent.send(MouseEvent.MOUSE_WHEEL, -1, -1, -1, x, y);
  }

  function mouseFocus(focus: Bool) {
    if (focus) {
      MouseEvent.send(MouseEvent.MOUSE_ENTER, -1, -1, -1, -1, -1);
    } else {
      MouseEvent.send(MouseEvent.MOUSE_LEAVE, -1, -1, -1, -1, -1);
    }
  }

  function joystickAdded(joystick: Joystick) {
    var nextId = -1;
    if (freeJoysticks.length == 0) {
      nextId = joystickIdCounter++;
    } else {
      nextId = freeJoysticks.shift();
    }
    joysticks.set(joystick, nextId);
    GamepadEvent.send(GamepadEvent.GAMEPAD_CONNECTED, nextId, '', -1);
  }

  function joystickRemoved(joystick: Joystick) {
    if (joysticks.exists(joystick)) {
      var id = joysticks.get(joystick);
      joysticks.remove(joystick);
      freeJoysticks.push(id);
      GamepadEvent.send(GamepadEvent.GAMEPAD_DISCONNECTED, id, '', -1);
    }
  }

  function gamepadAxis(joystick: Joystick, axis: GamepadAxis, value: Float) {
    if (joysticks.exists(joystick)) {
      var id = joysticks.get(joystick);
      GamepadEvent.send(GamepadEvent.GAMEPAD_AXIS, id, axis, value);
    }
  }

  function gamepadPressed(joystick: Joystick, button: GamepadButton) {
    if (joysticks.exists(joystick)) {
      var id = joysticks.get(joystick);
      GamepadEvent.send(GamepadEvent.GAMEPAD_BUTTON, id, button, 1);
    }
  }

  function gamepadReleased(joystick: Joystick, button: GamepadButton) {
    if (joysticks.exists(joystick)) {
      var id = joysticks.get(joystick);
      GamepadEvent.send(GamepadEvent.GAMEPAD_BUTTON, id, button, 0);
    }
  }

  function keyConstantToKeyCode(key: KeyConstant): KeyCode {
    switch (key) {
      // Letters
      case KeyConstant.A:
        return KeyCode.A;

      case KeyConstant.B:
        return KeyCode.B;

      case KeyConstant.C:
        return KeyCode.C;

      case KeyConstant.D:
        return KeyCode.D;

      case KeyConstant.E:
        return KeyCode.E;

      case KeyConstant.F:
        return KeyCode.F;

      case KeyConstant.G:
        return KeyCode.G;

      case KeyConstant.H:
        return KeyCode.H;

      case KeyConstant.I:
        return KeyCode.I;

      case KeyConstant.J:
        return KeyCode.J;

      case KeyConstant.K:
        return KeyCode.K;

      case KeyConstant.L:
        return KeyCode.L;

      case KeyConstant.M:
        return KeyCode.M;

      case KeyConstant.N:
        return KeyCode.N;

      case KeyConstant.O:
        return KeyCode.O;

      case KeyConstant.P:
        return KeyCode.P;

      case KeyConstant.Q:
        return KeyCode.Q;

      case KeyConstant.R:
        return KeyCode.R;

      case KeyConstant.S:
        return KeyCode.S;

      case KeyConstant.T:
        return KeyCode.T;

      case KeyConstant.U:
        return KeyCode.U;

      case KeyConstant.V:
        return KeyCode.V;

      case KeyConstant.W:
        return KeyCode.W;

      case KeyConstant.X:
        return KeyCode.X;

      case KeyConstant.Y:
        return KeyCode.Y;

      case KeyConstant.Z:
        return KeyCode.Z;

      // Numbers
      case KeyConstant.Zero:
        return KeyCode.ZERO;

      case KeyConstant.One:
        return KeyCode.ONE;

      case KeyConstant.Two:
        return KeyCode.TWO;

      case KeyConstant.Three:
        return KeyCode.THREE;

      case KeyConstant.Four:
        return KeyCode.FOUR;

      case KeyConstant.Five:
        return KeyCode.FIVE;

      case KeyConstant.Six:
        return KeyCode.SIX;

      case KeyConstant.Seven:
        return KeyCode.SEVEN;

      case KeyConstant.Eight:
        return KeyCode.EIGHT;

      case KeyConstant.Nine:
        return KeyCode.NINE;

      // Function keys
      case KeyConstant.F1:
        return KeyCode.F1;

      case KeyConstant.F2:
        return KeyCode.F2;

      case KeyConstant.F3:
        return KeyCode.F3;

      case KeyConstant.F4:
        return KeyCode.F4;

      case KeyConstant.F5:
        return KeyCode.F5;

      case KeyConstant.F6:
        return KeyCode.F6;

      case KeyConstant.F7:
        return KeyCode.F7;

      case KeyConstant.F8:
        return KeyCode.F8;

      case KeyConstant.F9:
        return KeyCode.F9;

      case KeyConstant.F10:
        return KeyCode.F10;

      case KeyConstant.F11:
        return KeyCode.F11;

      case KeyConstant.F12:
        return KeyCode.F12;

      case KeyConstant.F13:
        return KeyCode.F13;

      case KeyConstant.F14:
        return KeyCode.F14;

      case KeyConstant.F15:
        return KeyCode.F15;

      // Numpad
      case KeyConstant.Kp0:
        return KeyCode.NUM_0;

      case KeyConstant.Kp1:
        return KeyCode.NUM_1;

      case KeyConstant.Kp2:
        return KeyCode.NUM_2;

      case KeyConstant.Kp3:
        return KeyCode.NUM_3;

      case KeyConstant.Kp4:
        return KeyCode.NUM_4;

      case KeyConstant.Kp5:
        return KeyCode.NUM_5;

      case KeyConstant.Kp6:
        return KeyCode.NUM_6;

      case KeyConstant.Kp7:
        return KeyCode.NUM_7;

      case KeyConstant.Kp8:
        return KeyCode.NUM_8;

      case KeyConstant.Kp9:
        return KeyCode.NUM_9;

      case KeyConstant.KpAsterisk:
        return KeyCode.NUM_MULTIPLY;

      case KeyConstant.KpPlus:
        return KeyCode.NUM_ADD;

      case KeyConstant.KpMinus:
        return KeyCode.NUM_SUBTRACT;

      case KeyConstant.KpPeriod:
        return KeyCode.NUM_DECIMAL;

      case KeyConstant.KpDivision:
        return KeyCode.NUM_DIVIDE;

      case KeyConstant.Kpenter:
        return KeyCode.NUM_ENTER;

      case KeyConstant.KpEqual:
        return KeyCode.NUM_CLEAR;

      // Modifiers (only those with direct KeyCode match)
      case KeyConstant.Lshift:
        return KeyCode.SHIFT_LEFT;

      case KeyConstant.Rshift:
        return KeyCode.SHIFT_RIGHT;

      case KeyConstant.Lctrl:
        return KeyCode.CONTROL_LEFT;

      case KeyConstant.Rctrl:
        return KeyCode.CONTROL_RIGHT;

      case KeyConstant.Lalt:
        return KeyCode.ALT_LEFT;

      case KeyConstant.Ralt:
        return KeyCode.ALT_RIGHT;

      case KeyConstant.Lmeta:
        return KeyCode.META_LEFT;

      case KeyConstant.Rmeta:
        return KeyCode.META_RIGHT;

      case KeyConstant.Lsuper, 'lgui':
        return KeyCode.OS_LEFT;

      case KeyConstant.Rsuper, 'rgui':
        return KeyCode.OS_RIGHT;

      // Other common keys
      case KeyConstant.Space:
        return KeyCode.SPACE;

      case KeyConstant.Escape:
        return KeyCode.ESCAPE;

      case KeyConstant.Tab:
        return KeyCode.TAB;

      case KeyConstant.Capslock:
        return KeyCode.CAPS_LOCK;

      case KeyConstant.Backspace:
        return KeyCode.BACKSPACE;

      case KeyConstant.Return:
        return KeyCode.ENTER;

      case KeyConstant.Pause:
        return KeyCode.PAUSE;

      case KeyConstant.Insert:
        return KeyCode.INSERT;

      case KeyConstant.Delete:
        return KeyCode.DELETE;

      case KeyConstant.Home:
        return KeyCode.HOME;

      case KeyConstant.End:
        return KeyCode.END;

      case KeyConstant.Pageup:
        return KeyCode.PAGE_UP;

      case KeyConstant.Pagedown:
        return KeyCode.PAGE_DOWN;

      case KeyConstant.Print:
        return KeyCode.PRINT_SCREEN;

      case KeyConstant.Scrollock:
        return KeyCode.SCROLL_LOCK;

      case KeyConstant.Numlock:
        return KeyCode.NUM_LOCK;

      // Arrows
      case KeyConstant.Up:
        return KeyCode.ARROW_UP;

      case KeyConstant.Down:
        return KeyCode.ARROW_DOWN;

      case KeyConstant.Left:
        return KeyCode.ARROW_LEFT;

      case KeyConstant.Right:
        return KeyCode.ARROW_RIGHT;

      // Symbols
      case KeyConstant.Minus:
        return KeyCode.MINUS;

      case KeyConstant.Equal:
        return KeyCode.EQUAL;

      case KeyConstant.LeftBracket:
        return KeyCode.BRACKET_LEFT;

      case KeyConstant.RightBracket:
        return KeyCode.BRACKET_RIGHT;

      case KeyConstant.Backslash:
        return KeyCode.BACKSLASH;

      case KeyConstant.Semicolon:
        return KeyCode.SEMICOLON;

      case KeyConstant.SingleQuote:
        return KeyCode.QUOTE;

      case KeyConstant.Backtick:
        return KeyCode.BACKQUOTE;

      case KeyConstant.Comma:
        return KeyCode.COMMA;

      case KeyConstant.Period:
        return KeyCode.PERIOD;

      case KeyConstant.Slash:
        return KeyCode.SLASH;

      default:
        trace('Unknown key: $key');
        return KeyCode.UNKNOWN;
    }
  }
}
