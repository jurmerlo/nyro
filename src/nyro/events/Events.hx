package nyro.events;

import nyro.di.Service;

using nyro.utils.Destructure;

/**
 * The events class handles events in the engine.
 */
class Events implements Service {
  /**
   * All listeners added to the emitter.
   */
  final listeners = new Map<String, Array<EventListener>>();

  /**
   * Create a new Events manager.
   */
  public function new() {}

  /**
   * Add an event listener.
   */
  public function addListener<T: Event>(type: EventType<T>, callback: (T)->Void, ?filter: (T)->Bool): EventListener {
    final listener = new EventListener(type, callback, filter);

    if (listeners[type] == null) {
      listeners[type] = [listener];
    } else {
      listeners[type].unshift(listener);
    }

    setPriority(listener, 0);

    return listener;
  }

  public function setPriority(listener: EventListener, priority: Int) {
    if (listeners.exists(listener.eventType)) {
      final list = listeners[listener.eventType];
      if (list.contains(listener)) {
        listener.priority = priority;
        list.sort((a, b) -> {
          if (a.priority < b.priority) {
            return 1;
          } else if (a.priority > b.priority) {
            return -1;
          }

          return 0;
        });
      }
    }
  }

  /**
   * Remove an event listener.
   * @param listener The event listener to remove.
   */
  public function removeListener(listener: EventListener) {
    if (listeners.exists(listener.eventType)) {
      listeners[listener.eventType].remove(listener);
    }
  }

  /**
   * Check if an event type or listener exists in the event emitter.
   * @param type The event type to check.
   * @param listener The optional listener to check.
   * @return True if the type or listener exists.
   */
  public function hasListener<T>(type: EventType<T>, ?listener: EventListener): Bool {
    if (listener != null) {
      final list = listeners[type];
      if (list == null) {
        return false;
      }

      return list.contains(listener);
    } else {
      return listeners.exists(type);
    }
  }

  /**
   * Send an event to all listeners it has. Events get put back into the pool automatically after the emit.
   * @param event The event to emit.
   */
  public function sendEvent(event: Event) {
    // Global listeners are always triggered first.
    var list = listeners[event.type];
    if (list != null) {
      processEvent(event, list);
    }

    event.put();
  }

  /**
   * Clear all events.
   */
  public function clearEventsListeners() {
    for (key in listeners.keys()) {
      final list = listeners[key];
      var index = list.length - 1;
      while (index >= 0) {
        final listener = list[index];
        list.remove(listener);
      }
    }
  }

  /**
   * Process the event with all callbacks.
   * @param event The event to process.
   * @param listeners The callbacks to check.
   */
  function processEvent(event: Event, listeners: Array<EventListener>) {
    for (listener in listeners) {
      if (listener.active && listener.callback != null) {
        if (listener.filter == null || listener.filter(event)) {
          listener.callback(event);
        }
      }

      // Check if this handler can cancel an event. Stop the loop if it can.
      if (event.canceled) {
        break;
      }
    }
  }
}
