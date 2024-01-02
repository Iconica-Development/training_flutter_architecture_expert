// ignore_for_file: Generated using data class generator
import 'package:equatable/equatable.dart';

class Training extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> availableLanguages;
  final int duration;
  final int cost;

  const Training({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.cost,
    required this.availableLanguages,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        duration,
        cost,
        availableLanguages,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'availableLanguages': availableLanguages,
      'duration': duration,
      'cost': cost,
    };
  }

  factory Training.fromMap(Map<String, dynamic> map) {
    return Training(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      availableLanguages: List<String>.from(
          (map['availableLanguages'] ?? const <String>[]) as List<String>),
      duration: (map['duration'] ?? 0) as int,
      cost: (map['cost'] ?? 0) as int,
    );
  }
}

class CourseTask extends Equatable {
  final String id;
  final String task;
  final bool completed;
  final String courseId;

  const CourseTask({
    required this.id,
    required this.task,
    required this.completed,
    required this.courseId,
  });

  @override
  List<Object?> get props => [id, task, completed, courseId];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'task': task,
      'completed': completed,
      'courseId': courseId,
    };
  }

  factory CourseTask.fromMap(Map<String, dynamic> map) {
    return CourseTask(
      id: (map['id'] ?? '') as String,
      task: (map['task'] ?? '') as String,
      completed: (map['completed'] ?? false) as bool,
      courseId: (map['courseId'] ?? '') as String,
    );
  }
}

class Course extends Equatable {
  final String id;
  final Training training;
  final Trainer trainer;
  final String language;
  final List<DateTime> dates;

  const Course({
    required this.id,
    required this.training,
    required this.dates,
    required this.trainer,
    required this.language,
  });

  @override
  List<Object?> get props => [
        id,
        training,
        dates,
        trainer,
        language,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'training': training.toMap(),
      'trainer': trainer.toMap(),
      'language': language,
      'dates': dates.map((x) => x.millisecondsSinceEpoch).toList(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: (map['id'] ?? '') as String,
      training: Training.fromMap(map['training'] as Map<String, dynamic>),
      trainer: Trainer.fromMap(map['trainer'] as Map<String, dynamic>),
      language: (map['language'] ?? '') as String,
      dates: List<DateTime>.from(
        (map['dates'] as List).whereType<String>().map(
              (x) => DateTime.parse(x),
            ),
      ),
    );
  }
}

class Organisation extends Equatable {
  final String id;
  final String name;
  final User owner;

  const Organisation({
    required this.id,
    required this.name,
    required this.owner,
  });

  @override
  List<Object?> get props => [id, name];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'owner': owner.toMap(),
    };
  }

  factory Organisation.fromMap(Map<String, dynamic> map) {
    return Organisation(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      owner: User.fromMap(map['owner'] as Map<String, dynamic>),
    );
  }
}

class CourseAttendee extends Equatable {
  final String id;
  final Course course;
  final Student student;

  const CourseAttendee({
    required this.id,
    required this.course,
    required this.student,
  });

  @override
  List<Object?> get props => [
        id,
        course,
        student,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'course': course.toMap(),
      'student': student.toMap(),
    };
  }

  factory CourseAttendee.fromMap(Map<String, dynamic> map) {
    return CourseAttendee(
      id: (map['id'] ?? '') as String,
      course: Course.fromMap(map['course'] as Map<String, dynamic>),
      student: Student.fromMap(map['student'] as Map<String, dynamic>),
    );
  }
}

class Student extends Equatable {
  final String id;
  final String organisationId;
  final User user;

  const Student({
    required this.id,
    required this.organisationId,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        organisationId,
        user,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'organisationId': organisationId,
      'user': user.toMap(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: (map['id'] ?? '') as String,
      organisationId: (map['organisationId'] ?? '') as String,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}

class Trainer extends Equatable {
  final String id;
  final User user;
  const Trainer({
    required this.id,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        user,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user': user.toMap(),
    };
  }

  factory Trainer.fromMap(Map<String, dynamic> map) {
    return Trainer(
      id: (map['id'] ?? '') as String,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}

class PublicUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;

  const PublicUser({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        id,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  factory PublicUser.fromMap(Map<String, dynamic> map) {
    return PublicUser(
      id: (map['id'] ?? '') as String,
      firstName: (map['firstName'] ?? '') as String,
      lastName: (map['lastName'] ?? '') as String,
    );
  }
}

class User extends Equatable {
  final PublicUser user;
  final String email;
  const User({
    required this.user,
    required this.email,
  });

  @override
  List<Object?> get props => [
        user,
        email,
      ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...user.toMap(),
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      user: PublicUser.fromMap(map),
      email: (map['email'] ?? '') as String,
    );
  }
}
