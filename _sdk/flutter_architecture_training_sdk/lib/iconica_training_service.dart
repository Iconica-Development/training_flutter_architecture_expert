import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_architecture_training_sdk/iconica_training_models.dart';
import 'package:uuid/uuid.dart';

class TrainingService {
  List<Course> courses = [];
  List<Student> students = [];
  List<CourseAttendee> attendees = [];

  final int pageSize = 5;

  final bool canFail;

  TrainingService({
    this.canFail = false,
  });

  TrainingService.withData({
    required this.courses,
    required this.students,
    required this.attendees,
    this.canFail = false,
  });

  factory TrainingService.withMockedData({
    bool canFail = false,
  }) {
    var uuid = const Uuid();

    var organisationId = uuid.v8();

    var students = List.generate(200, (index) {
      var id = uuid.v8();

      return Student(
        id: id,
        organisationId: organisationId,
        user: User(
          user: PublicUser(
            id: id,
            firstName: faker.person.firstName(),
            lastName: faker.person.lastName(),
          ),
          email: 'student$index@iconica.nl',
        ),
      );
    });

    var trainers = List.generate(
      5,
      (_) {
        var id = uuid.v8();
        return Trainer(
          id: id,
          user: User(
            user: PublicUser(
              id: id,
              firstName: faker.person.firstName(),
              lastName: faker.person.lastName(),
            ),
            email: 'test@iconica.nl',
          ),
        );
      },
    );

    var courses = List.generate(
      100,
      (i) => Course(
        id: uuid.v8(),
        training: Training(
          id: uuid.v8(),
          name: faker.company.position(),
          description: faker.lorem.sentence(),
          duration: faker.randomGenerator.integer(5, min: 1),
          cost: faker.randomGenerator.integer(6, min: 3) * 200,
          availableLanguages: const ['EN', 'NL'],
        ),
        dates: [
          faker.date.dateTimeBetween(
            DateTime(2024),
            DateTime(2026),
          ),
        ],
        trainer: trainers[i % trainers.length],
        language: 'EN',
      ),
    );

    var attendees = [
      for (var student in students) ...[
        CourseAttendee(
          id: uuid.v8(),
          course: courses[student.id.hashCode % courses.length],
          student: student,
        ),
        CourseAttendee(
          id: uuid.v8(),
          course:
              courses[student.user.user.firstName.hashCode % courses.length],
          student: student,
        ),
        CourseAttendee(
          id: uuid.v8(),
          course: courses[student.user.email.hashCode % courses.length],
          student: student,
        )
      ]
    ];

    return TrainingService.withData(
      courses: courses,
      students: students,
      attendees: attendees,
      canFail: canFail,
    );
  }

  Future<CourseFilterResult> getPlannedCourses({
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {
    await mockNetworkCall(canFail: canFail);
    var result = _applyFilterAndOrder(
      orderings: orderings,
      filter: filter,
      courses: courses,
    );

    return CourseFilterResult(
      count: result.length,
      page: page,
      courses: result.getPage(page, pageSize),
    );
  }

  Future<CourseFilterResult> getPlanneCoursesForStudent(
    Student student, {
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {
    await mockNetworkCall(canFail: canFail);
    var attendedCourses = attendees
        .where((attendee) => attendee.student.id == student.id)
        .map((attendee) => attendee.course)
        .toList();

    var result = _applyFilterAndOrder(
      orderings: orderings,
      filter: filter,
      courses: attendedCourses,
    );

    return CourseFilterResult(
      count: result.length,
      page: page,
      courses: result.getPage(page, pageSize),
    );
  }

  Future<CourseFilterResult> getPlannedCoursesForTrainer(
    Trainer trainer, {
    int page = 1,
    List<CourseOrder> orderings = const [],
    CourseFilter filter = const CourseFilter(),
  }) async {
    await mockNetworkCall(canFail: canFail);
    var result = _applyFilterAndOrder(
      orderings: orderings,
      filter: filter,
      courses: courses.where((course) => course.trainer.id == trainer.id),
    );

    return CourseFilterResult(
      count: result.length,
      page: page,
      courses: result.getPage(page, pageSize),
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
    await mockNetworkCall(canFail: canFail);
    return attendees
        .where((attendee) => attendee.course.id == courseId)
        .map((attendee) => attendee.student)
        .toList();
  }

  Future<void> planTraining(Course course) async {
    await mockNetworkCall();
    courses.add(course);
  }

  Future<void> attendCourse(Student student, Course course) async {
    await mockNetworkCall();
    attendees.add(
      CourseAttendee(
        id: const Uuid().v8(),
        course: course,
        student: student,
      ),
    );
  }
}

Future<void> mockNetworkCall({bool canFail = false}) async {
  var random = Random().nextDouble();

  await Future.delayed(const Duration(milliseconds: 100));

  if (random > 0.7) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  if (random > 0.8) {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  if (random > 0.97 && canFail) {
    TrainingOperationFailedException();
  }
}

class TrainingOperationFailedException implements Exception {}

extension Pagination<T> on List<T> {
  int getTotalPages(int pageSize) {
    return (length / pageSize).ceil();
  }

  List<T> getPage(int page, int pageSize) {
    var totalPages = getTotalPages(pageSize);
    if (page > totalPages) {
      return <T>[];
    }

    var start = (page - 1) * pageSize;

    return sublist(start, min(start + pageSize, length));
  }
}

class CourseFilterResult {
  final int count;
  final int page;
  final List<Course> courses;

  CourseFilterResult({
    required this.count,
    required this.page,
    required this.courses,
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
      filteredCourses = filteredCourses.where((course) =>
          course.training.name.contains(search!) ||
          course.training.description.contains(search!));
    }

    if (startDateAfter != null) {
      filteredCourses = filteredCourses
          .where((course) => course.dates.first.isAfter(startDateAfter!));
    } else if (startDateBefore != null) {
      filteredCourses = filteredCourses
          .where((course) => course.dates.first.isBefore(startDateAfter!));
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
