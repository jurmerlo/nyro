package nyro.core.di;

/**
 * Dependency injection services container class.
 */
class Services {
  /**
   * This container holds all services that have been added.
   */
  static final CONTAINER = new Map<String, Service>();

  /**
   * Add a new service. This will overwrite a service of the same type if it exists.
   * @param service The service to add.
   */
  public static inline function add(service: Service) {
    final classType = Type.getClass(service);
    final name = Type.getClassName(classType);

    CONTAINER.set(name, service);
  }

  /**
   * Get a service by class type.
   * @param classType The service class.
   * @return The service instance or null if it doesn't exist.
   */
  public static inline function get<T: Service>(classType: Class<T>): T {
    final name = Type.getClassName(classType);

    #if debug
    if (!CONTAINER.exists(name)) {
      trace('${name} does not exist in Services.');
    }
    #end

    return cast CONTAINER.get(name);
  }

  /**
   * Remove a service from the container.
   * @param classType The service class to remove.
   */
  public static inline function remove<T: Service>(classType: Class<T>) {
    final name = Type.getClassName(classType);
    CONTAINER.remove(name);
  }

  /**
   * Remove all services from the container.
   */
  public static inline function clear() {
    CONTAINER.clear();
  }
}
