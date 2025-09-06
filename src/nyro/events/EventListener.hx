package nyro.events;

/**
 * An event listener is used to store callbacks to call when the event is triggered. 
 */
class EventListener {
  /**
   * Only active listeners get called.
   */
  public var active: Bool;

  /**
   * The event type this listener is for.
   */
  public final eventType: String;

  /**
   * The function to call when the event is triggered.
   */
  public final callback: (Dynamic)->Void;

  /**
   * The priority of the callback. Higher is called first.
   */
  public var priority: Int;

  /**
   * Extra filter before receiving an event.
   */
  public final filter: (Dynamic)->Bool;

  /**
   * Create a new EventListener instance.
   * @param params The listener input params.
   */
  @SuppressWarnings('checkstyle:ParameterNumber')
  public function new(eventType: String, callback: (Dynamic)->Void, ?filter: (Dynamic)->Bool) {
    active = true;
    this.eventType = eventType;
    this.callback = callback;
    this.priority = 0;
    this.filter = filter;
  }
}
