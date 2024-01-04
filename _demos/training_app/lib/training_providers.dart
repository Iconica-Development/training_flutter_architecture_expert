import 'package:flutter/material.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final trainingServiceProvider = Provider<TrainingService>((ref) {
  return TrainingService.withMockedData();
});

final _coursesFutureProvider = FutureProvider<CourseFilterResult>((ref) async {
  var service = ref.read(trainingServiceProvider);
  return await service.getPlannedCourses();
});

final initializationProvider = FutureProvider((ref) async {
  await ref.read(_coursesFutureProvider.future);
});

final studentsForCourseFutureProvider =
    FutureProvider.autoDispose.family<List<Student>, String>(
  (ref, args) => ref.read(trainingServiceProvider).getStudentsForCourse(args),
);

final coursesCachedStateProvider =
    StateNotifierProvider<CoursesStateNotifier, AsyncValue<CourseFilterResult>>(
  (ref) {
    ref.listen(_coursesFutureProvider, (previousValue, nextValue) {
      if (previousValue?.valueOrNull != nextValue.value) {
        ref.invalidateSelf();
      }
    });

    ref.onAddListener(() {
      ref.invalidate(_coursesFutureProvider);
    });

    return CoursesStateNotifier(
      initialState: ref.read(_coursesFutureProvider),
      trainingService: ref.read(trainingServiceProvider),
      onUpdate: () async {
        var future = ref.refresh(_coursesFutureProvider.future);
        await future;
      },
    );
  },
);

class CoursesStateNotifier
    extends StateNotifier<AsyncValue<CourseFilterResult>> {
  CoursesStateNotifier({
    required AsyncValue<CourseFilterResult> initialState,
    required this.trainingService,
    required this.onUpdate,
  }) : super(initialState);

  final TrainingService trainingService;

  final void Function() onUpdate;

  Future<void> changeDates(Course course, List<DateTime> dates) async {
    var newCourse = Course(
      id: course.id,
      training: course.training,
      dates: dates,
      trainer: course.trainer,
      language: course.language,
    );

    var previousState = state;
    state = state.map(
      data: (data) {
        var result = data.valueOrNull;

        if (result == null) {
          return data;
        }
        return AsyncData(
          CourseFilterResult(
            count: result.count,
            page: result.page,
            courses: [
              for (course in result.courses) ...[
                if (course.id == newCourse.id) ...[
                  newCourse,
                ] else ...[
                  course,
                ]
              ]
            ],
          ),
        );
      },
      error: (error) => error,
      loading: (loading) => loading,
    );

    try {
      await trainingService.planTraining(newCourse);

      onUpdate();
    } catch (e) {
      if (!mounted) {
        return;
      }

      state = previousState;
    }
  }
}

class CourseOverviewPage extends ConsumerWidget {
  const CourseOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var coursesSnapshot = ref.watch(coursesCachedStateProvider);

    return coursesSnapshot.when(
        data: (data) => ListView(),
        error: (e, s) => const SizedBox.shrink(),
        loading: () => const CircularProgressIndicator());
  }
}
