import 'package:flutter/widgets.dart';

class LazyDependencyContainer {
  // a simple registry for dependencies
  final Map<Type, dynamic Function(BuildContext context)> _dependencies = {};

  final Map<Type, dynamic> _dependencyCache = {};

  void registerDependency<T>(
    T Function(BuildContext context) dependencyCreator,
  ) {
    _dependencies[T] = dependencyCreator;
  }

  T? getDependency<T>(BuildContext context) {
    return _dependencyCache[T] ??= _dependencies[T]?.call(context);
  }
}

class DependencyProvider extends InheritedWidget {
  const DependencyProvider({
    required LazyDependencyContainer lazyDependencyContainer,
    required super.child,
    super.key,
  }) : _dependencyContainer = lazyDependencyContainer;

  final LazyDependencyContainer _dependencyContainer;

  static T? of<T>(BuildContext context) {
    var widget =
        context.dependOnInheritedWidgetOfExactType<DependencyProvider>();
    return widget?._dependencyContainer.getDependency<T>(context);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
