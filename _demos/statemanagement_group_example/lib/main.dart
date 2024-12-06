import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_ui.dart';
import 'package:statemanagement_group_example/providers.dart';
import 'package:statemanagement_group_example/state_management.dart';

void main(List<String> args) {
  final providerContainer = ProviderStateContainer();

  providerContainer.provide(SingletonProvider((StateContainer container) {
    return TrainingService.withMockedData();
  }));

  providerContainer.provide(
    FutureProvider<List<Course>>((StateContainer container) async {
      var trainingService = container.read<TrainingService>();

      return (await trainingService.getPlannedCourses()).courses;
    }),
  );

  runApp(StateContainerScope(
    stateContainer: providerContainer,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CourseOverviewScreen(),
    );
  }
}

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          _SearchField(),
        ],
      ),
      body: const CourseOverviewList(),
    );
  }
}

class CourseOverviewList extends ConsumerWidget {
  const CourseOverviewList({
    super.key,
  });

  @override
  Widget build(BuildContext context, StateContainer container) {
    TripleState<List<Course>> courses = container.read<AsyncCourses>();

    return CourseOverviewListLayout(
      courses: courses.when(
        data: (data) => data,
        error: (_, __) => [],
        loading: () => [],
      ),
    );
  }
}

class CourseOverviewListLayout extends StatelessWidget {
  const CourseOverviewListLayout({
    super.key,
    required this.courses,
  });

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var course in courses) ...[
          CourseOverviewItem(course: course),
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search',
        ),
        onChanged: (value) {},
      ),
    );
  }
}
