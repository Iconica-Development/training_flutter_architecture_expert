import 'dart:async';

import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:statemanagement_group_example/state_management.dart';

typedef AsyncCourses = TripleState<List<Course>>;

class Provider<T> {
  Provider(this.initializer);

  final T Function(StateContainer) initializer;

  Map<StateContainer, T> cache = {};

  T read(StateContainer container) {
    return cache[container] ??= initializer(container);
  }
}

class SingletonProvider<T> extends Provider<T> {
  SingletonProvider(super.initializer);
}

class FutureProvider<T> extends Provider<TripleState<T>> {
  FutureProvider(
    this.futureInitializer,
  ) : super((container) {
          unawaited(futureInitializer(container));

          return TripleState.loading();
        });

  final Future<T> Function(StateContainer) futureInitializer;
}
