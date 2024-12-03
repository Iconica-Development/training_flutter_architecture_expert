import 'package:flutter_architecture_training_sdk/iconica_training_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display all students', () async {
    var service = TrainingService.withMockedData();

    var courses = await service.getPlannedCourses(page: 2);

    print(courses.count);

    print(courses.courses.length);

    for (var course in courses.courses) {
      print('${course.id}: ${course.dates.first} ${course.training.name}');
      var students = await service.getStudentsForCourse(course.id);

      for (var student in students) {
        print('${student.user.user.firstName} ${student.user.user.lastName}');
      }
      print('======');
    }
  });
}
