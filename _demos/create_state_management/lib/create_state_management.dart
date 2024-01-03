library create_state_management;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class StateContainerCreator<T> {
  final StateContainer<T> Function(BuildContext context) dependencyCreator;
  final bool autoDispose;

  StateContainerCreator({
    required this.dependencyCreator,
    this.autoDispose = false,
  });
}

class LazyStateContainerRegistry {
  // a simple registry for dependencies
  final Map<Type, StateContainerCreator> _dependencies = {};

  final Map<Type, dynamic> _dependencyCache = {};

  void registerDependency<T>(
    StateContainer<T> Function(BuildContext context) dependencyCreator, {
    bool autoDispose = false,
  }) {
    _dependencies[T] = StateContainerCreator(
      dependencyCreator: dependencyCreator,
      autoDispose: autoDispose,
    );
  }

  StateContainer<T>? resolveDependency<T>(BuildContext context) {
    StateContainerCreator? creator = _dependencies[T];
    if (creator == null) {
      return null;
    }
    var dependency =
        creator.dependencyCreator.call(context) as StateContainer<T>?;

    if (dependency != null && creator.autoDispose) {
      void disposeOnLastRemovedListener() {
        if (dependency.listeners.isEmpty) {
          dependency.dispose();
          _dependencyCache.remove(T);
        }
      }

      dependency.onRemoveListener(disposeOnLastRemovedListener);
    }
    return dependency;
  }

  void dispose() {
    for (var element in _dependencyCache.values) {
      element as StateContainer;
      element.dispose();
    }
    _dependencyCache.clear();
  }

  StateContainer<T>? getDependency<T>(BuildContext context) {
    return _dependencyCache[T] ??= resolveDependency(context);
  }
}

class StateContainerProvider extends InheritedWidget {
  const StateContainerProvider({
    required LazyStateContainerRegistry registry,
    required super.child,
    super.key,
  }) : _registry = registry;

  final LazyStateContainerRegistry _registry;

  static StateContainer<T>? of<T>(BuildContext context) {
    var widget =
        context.dependOnInheritedWidgetOfExactType<StateContainerProvider>();
    return widget?._registry.getDependency<T>(context);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class TripleState<T> {
  final T? data;
  final T? previousData;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isLoading;

  TripleState({
    this.data,
    this.previousData,
    this.error,
    this.stackTrace,
    this.isLoading = false,
  });

  TripleState.loading()
      : data = null,
        previousData = null,
        error = null,
        stackTrace = null,
        isLoading = true;

  TripleState.error({
    required this.error,
    required this.stackTrace,
  })  : isLoading = false,
        data = null,
        previousData = null;

  TripleState.data({
    required this.data,
  })  : previousData = null,
        error = null,
        stackTrace = null,
        isLoading = false;

  TripleState<T> moveToState(TripleState<T> newState) {
    return TripleState<T>(
      previousData: data ?? previousData,
      data: newState.data,
      isLoading: newState.isLoading,
      error: newState.error,
      stackTrace: newState.stackTrace,
    );
  }

  bool get hasData => data != null || previousData != null;

  bool get hasError => error != null;

  TripleState<R> map<R>({
    required TripleState<R> Function(T data) data,
    required TripleState<R> Function(Object error, StackTrace stackTrace) error,
    required TripleState<R> Function() loading,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(error, stackTrace!);
    return data((this.data ?? this.previousData) as T);
  }

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(error, stackTrace!);
    return data((this.data ?? this.previousData) as T);
  }
}

class FutureStateContainer<T> extends StateContainer<TripleState<T>> {
  FutureStateContainer({
    required Future<T> Function() initializer,
  })  : _initializer = initializer,
        super(TripleState<T>.loading()) {
    unawaited(_evaluateFuture());
  }

  final Future<T> Function() _initializer;

  Future<void> _evaluateFuture() async {
    try {
      var data = await _initializer();
      state = state.moveToState(TripleState.data(data: data));
    } catch (e, s) {
      state = state.moveToState(TripleState.error(error: e, stackTrace: s));
    }
  }

  void refresh() {
    state = state.moveToState(TripleState.loading());
    _evaluateFuture();
  }
}

abstract class StateContainer<T> {
  T _state;

  StateContainer(this._state);

  final List<Listener<T>> listeners = [];
  final List<void Function()> _listenerRemoveCallbacks = [];
  final List<void Function()> _listenerAddCallbacks = [];

  void onAddListener(void Function() onAdd) {
    _listenerRemoveCallbacks.add(onAdd);
  }

  void onRemoveListener(void Function() onRemove) {
    _listenerRemoveCallbacks.add(onRemove);
  }

  void dispose() {
    listeners.clear();
    _listenerAddCallbacks.clear();
    _listenerAddCallbacks.clear();
  }

  set state(T state) {
    if (_state == state) {
      return;
    }

    var oldState = state;
    _state = state;
    _callListeners(oldState, _state);
  }

  void _callListeners(T oldState, T newState) {
    for (var listener in listeners) {
      listener(oldState, newState);
    }
  }

  T get state => _state;

  void addListener(Listener<T> listener) {
    listeners.add(listener);
    for (var element in _listenerAddCallbacks) {
      element.call();
    }
  }

  void removeListener(Listener<T> listener) {
    listeners.remove(listener);

    for (var element in _listenerRemoveCallbacks) {
      element.call();
    }
  }
}

typedef Listener<T> = void Function(T previousValue, T nextValue);

extension GetStateContainer on BuildContext {
  StateContainer<T> getState<T>() {
    return StateContainerProvider.of<T>(this)!;
  }
}

abstract class StateConsumer<T> extends StatelessWidget {
  const StateConsumer({super.key});

  Widget buildState(BuildContext context, T state);

  @override
  Widget build(BuildContext context) {
    var state = context.getState<T>();
    return StateBuilder<T>(stateContainer: state, builder: buildState);
  }
}

class StateBuilder<T> extends StatefulWidget {
  const StateBuilder({
    super.key,
    required this.stateContainer,
    required this.builder,
  });

  final Widget Function(BuildContext buildContext, T value) builder;

  final StateContainer<T> stateContainer;

  @override
  State<StateBuilder> createState() => _StateBuilderState();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  late T state = widget.stateContainer.state;

  @override
  void initState() {
    super.initState();
    widget.stateContainer.addListener(_listen);
  }

  void _listen(T oldState, T newState) {
    setState(() {
      state = oldState;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.stateContainer.removeListener(_listen);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.stateContainer.state);
  }
}
