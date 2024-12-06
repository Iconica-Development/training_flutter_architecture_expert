import 'package:flutter/widgets.dart';
import 'package:statemanagement_group_example/providers.dart';

abstract class StateContainer {
  T read<T>();

  void registerListener(Type type, VoidCallback listener);

  void unregisterListener(Type type, VoidCallback listener);
}

class ProviderStateContainer implements StateContainer {
  final Map<Type, Provider> _providers = {};

  void provide<T>(Provider<T> provider) {
    _providers[T] = provider;
  }

  @override
  T read<T>() {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  void registerListener(Type type, VoidCallback listener) {
    // TODO: implement registerListener
  }

  @override
  void unregisterListener(Type type, VoidCallback listener) {
    // TODO: implement unregisterListener
  }
}

class _WidgetStateContainer implements StateContainer {
  final _ConsumerWidgetState currentState;
  final StateContainer innerContainer;

  _WidgetStateContainer({
    required this.currentState,
    required this.innerContainer,
  });

  Map<Type, VoidCallback> valueListeners = {};

  @override
  T read<T>() {
    var result = innerContainer.read<T>();

    var listener = valueListeners[T];

    if (listener == null) {
      innerContainer.registerListener(
        T,
        valueListeners[T] = currentState.update,
      );
    }

    return result;
  }

  void dispose() {
    for (var listenerEntry in valueListeners.entries) {
      innerContainer.unregisterListener(listenerEntry.key, listenerEntry.value);
    }
  }

  @override
  void registerListener(Type type, VoidCallback listener) {
    innerContainer.registerListener(type, listener);
  }

  @override
  void unregisterListener(Type type, VoidCallback listener) {
    innerContainer.unregisterListener(type, listener);
  }
}

class StateContainerScope extends InheritedWidget {
  const StateContainerScope({
    required this.stateContainer,
    required super.child,
    super.key,
  });

  final StateContainer stateContainer;

  static StateContainer of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StateContainerScope>()!
        .stateContainer;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    throw UnimplementedError();
  }
}

abstract class ConsumerWidget extends StatefulWidget {
  const ConsumerWidget({super.key});

  Widget build(BuildContext context, StateContainer container);

  @override
  State<StatefulWidget> createState() => _ConsumerWidgetState();
}

class _ConsumerWidgetState extends State<ConsumerWidget> {
  _WidgetStateContainer? container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    container?.dispose();

    var innerContainer = StateContainerScope.of(context);

    container = _WidgetStateContainer(
      currentState: this,
      innerContainer: innerContainer,
    );
  }

  @override
  void dispose() {
    container?.dispose();
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, container!);
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
    required TripleState<R> Function(TripleState<T> dataState) data,
    required TripleState<R> Function(TripleState<T> errorState) error,
    required TripleState<R> Function(TripleState<T> loadingState) loading,
  }) {
    if (isLoading) return loading(this);
    if (hasError) return error(this);
    return data(this);
  }

  R when<R>({
    required R Function(T data) data,
    required R Function(Object error, StackTrace stackTrace) error,
    required R Function() loading,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(this.error!, stackTrace!);
    return data((this.data ?? this.previousData) as T);
  }
}
