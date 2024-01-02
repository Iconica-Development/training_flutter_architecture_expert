import 'package:flutter/foundation.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';

class TrainingService {
  List<Course> courses = [];
  List<Student> students = [];
  List<CourseAttendee> attendees = [];

  TrainingService();

  TrainingService.withDate({
    required this.courses,
    required this.students,
    required this.attendees,
  });

  Future<CourseFilterResult> getPlannedCourses({
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {}

  Future<CourseFilterResult> getPlanneCoursesForStudent(
    Student student, {
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {
    var result = _applyFilterAndOrder(
      orderings: orderings,
      filter: filter,
      courses: courses.where((element) => element == trainer.id),
    );
  }

  Future<CourseFilterResult> getPlannedCoursesForTrainer(
    Trainer trainer, {
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {
    var result = _applyFilterAndOrder(
      orderings: orderings,
      filter: filter,
      courses: courses.where((element) => element.trainer.id == trainer.id),
    );
  }

  List<Course> _applyFilterAndOrder({
    required List<CourseOrder> orderings,
    required CourseFilter filter,
    required Iterable<Course> courses,
  }) {
    var filteredOrders = filter.filter(courses);
    orderings.sortList(filteredOrders);
    return filteredOrders;
  }

  Future<List<Student>> getStudentsForCourse(String courseId) async {
    return attendees
        .where((element) => element.course.id == courseId)
        .map((e) => e.student)
        .toList();
  }
}

class CourseFilterResult {
  final int count;
  final int page;
  final List<Course> course;

  CourseFilterResult({
    required this.count,
    required this.page,
    required this.course,
  });
}

class CourseFilter {
  final String? search;
  final DateTime? startDateBefore;
  final DateTime? startDateAfter;

  const CourseFilter({
    this.search,
    this.startDateBefore,
    this.startDateAfter,
  });

  List<Course> filter(Iterable<Course> courses) {
    Iterable<Course> filteredCourses = courses;

    if (search != null) {
      filteredCourses = filteredCourses.where((element) =>
          element.training.name.contains(search!) ||
          element.training.description.contains(search!));
    }

    if (startDateAfter != null) {
      filteredCourses = filteredCourses
          .where((element) => element.dates.first.isAfter(startDateAfter!));
    } else if (startDateBefore != null) {
      filteredCourses = filteredCourses
          .where((element) => element.dates.first.isBefore(startDateAfter!));
    }
    return filteredCourses.toList();
  }
}

String fetchCourseName(Course course) {
  return course.training.name;
}

DateTime fetchCourseDate(Course course) {
  return course.dates.first;
}

enum CourseOrder<T extends Comparable> {
  nameAscending(
    direction: SortDirection.ascending,
    fetcher: fetchCourseName,
  ),
  nameDescending(
    direction: SortDirection.descending,
    fetcher: fetchCourseName,
  ),
  startDateAscending(
    direction: SortDirection.ascending,
    fetcher: fetchCourseDate,
  ),
  startDateDescending(
    direction: SortDirection.descending,
    fetcher: fetchCourseDate,
  );

  const CourseOrder({
    required this.direction,
    required this.fetcher,
  });

  final SortDirection direction;
  final T Function(Course) fetcher;

  int compareTo(Course a, Course b) {
    return direction.compareWithDirection(a, b, fetcher);
  }
}

extension SortCourses on List<CourseOrder> {
  void sortList(List<Course> courses) {
    courses.sort((a, b) {
      for (var order in this) {
        var comparison = order.compareTo(a, b);
        if (comparison != 0) {
          return comparison;
        }
      }
      return 0;
    });
  }
}

enum SortDirection {
  ascending,
  descending;

  int compareWithDirection<T extends Comparable, O>(
      O objectA, O objectB, T Function(O) fetcher) {
    var a = fetcher(objectA);
    var b = fetcher(objectB);

    return switch (this) {
      SortDirection.ascending => a.compareTo(b),
      SortDirection.descending => b.compareTo(a),
    };
  }
}
