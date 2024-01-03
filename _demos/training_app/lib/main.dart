import 'package:create_state_management/create_state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: Scaffold(
      body: StateContainerProvider(
        registry: LazyStateContainerRegistry()
          ..registerDependency(
              (context) => TrainingServiceContainer(TrainingService()))
          ..registerDependency(
            (context) => TrainingDependencyProvider(
              initializer: () async =>
                  context.getState<TrainingService>().state.getPlannedCourses(),
            ),
            autoDispose: true,
          ),
        child: const MyConsumer(),
      ),
    ),
  ));
}

class TrainingServiceContainer extends StateContainer<TrainingService> {
  TrainingServiceContainer(super.state);
}

class TrainingDependencyProvider
    extends FutureStateContainer<CourseFilterResult> {
  TrainingDependencyProvider({required super.initializer});
}

class MyConsumer extends StateConsumer<TripleState<CourseFilterResult>> {
  const MyConsumer({super.key});

  @override
  Widget buildState(Object context, TripleState<CourseFilterResult> state) {
    return state.when(
      data: (data) => ListView(),
      error: (error, stackTrace) => Text('$error'),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
