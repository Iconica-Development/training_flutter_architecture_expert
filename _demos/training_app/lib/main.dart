import 'package:create_state_management/create_state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
void main(List<String> args) {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: Scaffold(),
      ),
    ),
  );
}

class TrainingServiceContainer extends StateContainer<TrainingService> {
  TrainingServiceContainer(super.state);
}

class TrainingDependencyProvider
    extends FutureStateContainer<CourseFilterResult> {
  TrainingDependencyProvider({required super.initializer});
}

class StudentListProvider extends FutureStateContainer<List<Student>> {
  StudentListProvider({required super.initializer});
}

class MyConsumer extends StateConsumer<TripleState<CourseFilterResult>> {
  const MyConsumer({super.key});

  @override
  Widget buildState(Object context, TripleState<CourseFilterResult> state) {
    return Center(
      child: state.when(
        data: (data) => ListView(
          children: [
            for (var course in data.courses) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.training.name,
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                course.training.description,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(course.trainer.user.user.firstName),
                      ),
                      const Spacer(),
                      Text(course.dates.first
                          .toIso8601String()
                          .substring(0, 10)),
                      const Spacer(),
                      TotalPageConsumer(argument: course.id),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        error: (error, stackTrace) => Text('$error'),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}

class TotalPageConsumer
    extends StateConsumerFamily<TripleState<List<Student>>, String> {
  const TotalPageConsumer({
    required super.argument,
    super.key,
  });

  @override
  Widget buildState(BuildContext context, TripleState<List<Student>> state) {
    return SizedBox(
      width: 40,
      child: state.when(
        data: (data) => Text('${data.length}'),
        error: (e, s) => const Text('Error'),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}
