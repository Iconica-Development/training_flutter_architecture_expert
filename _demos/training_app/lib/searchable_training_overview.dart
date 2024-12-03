import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:training_app/training_providers.dart';

final searchProvider = StateProvider((ref) => '');

final courseProvider = FutureProvider.family<CourseFilterResult, int>(
  (ref, page) async {
    return ref.read(trainingServiceProvider).getPlannedCourses(
          filter: CourseFilter(
            search: ref.watch(searchProvider),
          ),
          page: page,
        );
  },
);

final asyncStudentListProvider =
    AsyncNotifierProvider.family<StudentListNotifier, List<Student>, String>(
        () => StudentListNotifier());

class StudentListNotifier extends FamilyAsyncNotifier<List<Student>, String> {
  StudentListNotifier();

  @override
  FutureOr<List<Student>> build(String arg) async {
    await ref.read(courseProvider(1).future);
    var trainingService = ref.read(trainingServiceProvider);
    return trainingService.getStudentsForCourse(arg);
  }

  void updateSomeValue(Student updatedStudent) {
    update((value) => [
          for (var student in value) ...[
            if (student.id == updatedStudent.id) updatedStudent else student
          ]
        ]);
  }
}

class TrainingOverviewScreen extends StatelessWidget {
  const TrainingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const UpdatingTimeField(),
        actions: const [
          _SearchField(),
        ],
      ),
      body: const _TrainingOverviewList(),
    );
  }
}

class UpdatingTimeField extends HookWidget {
  const UpdatingTimeField({super.key});

  @override
  Widget build(BuildContext context) {
    useTimer(interval: const Duration(seconds: 1));

    return Column(
      children: [
        Text(DateTime.now().toIso8601String().substring(0, 19)),
      ],
    );
  }
}

void useTimer({required Duration interval}) {
  use(TimerHook(duration: interval));
}

class TimerHook extends Hook<void> {
  final Duration duration;

  const TimerHook({
    required this.duration,
  });

  @override
  HookState<void, Hook<void>> createState() => TimerHookState();
}

class TimerHookState extends HookState<void, TimerHook> {
  late Timer timer;

  @override
  void initHook() {
    timer = Timer.periodic(hook.duration, (timer) {
      if (context.mounted) {
        setState(() {});
      }
    });
  }

  @override
  void build(BuildContext context) {}

  @override
  void dispose() {
    timer.cancel();
  }
}

class _SearchField extends HookConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = useTextEditingController(text: ref.read(searchProvider));

    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search',
        ),
        onChanged: (value) {
          ref.read(searchProvider.notifier).state = value;
        },
      ),
    );
  }
}

class _TrainingOverviewList extends HookConsumerWidget {
  const _TrainingOverviewList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var snapshot = ref.watch(courseProvider(1));

    return snapshot.when(
      data: (data) {
        return ListView(
          children: [
            for (var item in data.courses) ...[
              _TrainingListItem(course: item),
            ],
          ],
        );
      },
      error: (e, s) {
        return Center(
          child: Text('Something Went wrong: $e'),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _TrainingListItem extends StatelessWidget {
  const _TrainingListItem({
    required this.course,
  });

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(course.trainer.user.user.firstName),
          ),
          const Spacer(),
          Text(
            course.dates.first.toIso8601String().substring(0, 10),
          ),
          const Spacer(),
          _StudentCount(courseId: course.id),
        ],
      ),
    );
  }
}

class _StudentCount extends ConsumerWidget {
  const _StudentCount({
    required this.courseId,
  });

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var students = ref.watch(studentsForCourseFutureProvider(courseId));
    return Text(
      'Students: ${students.maybeWhen(orElse: () => 0, data: (data) => data.length)}',
    );
  }
}