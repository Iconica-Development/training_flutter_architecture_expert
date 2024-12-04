import 'package:flutter/material.dart';

class TrainingService {}

class OtherTrainingService implements TrainingService {}

class TrainerService {
  TrainerService({required this.trainingService});
  final TrainingService trainingService;
}

class StudentService {
  StudentService({required this.trainingService});
  final TrainingService trainingService;
}

class ActiveTrainingService {
  ActiveTrainingService({required this.studentService});
  final TrainerService studentService;
}

typedef DependencyRegistration<T> = T Function(DependencyContainer container);

class DependencyContainer {
  DependencyContainer({
    this.parent,
  });

  final DependencyContainer? parent;
  final Map<Type, dynamic> registeredDependencies = {};

  final Map<Type, DependencyRegistration> registrations = {};

  void registerDependency<T>(DependencyRegistration register) {
    registrations[T] = (container) {
      print("Creating dependency $T");
      var result = register(container);
      print(result.runtimeType);
      return result;
    };
  }

  T? getDependency<T>({DependencyContainer? scope}) {
    print("Getting dependency $T");
    var currentScope = scope ?? this;
    return (currentScope.registeredDependencies[T] ??=
            registrations[T]?.call(currentScope)) ??
        parent?.getDependency<T>(scope: currentScope);
  }
}

class DependencyProvider extends InheritedWidget {
  const DependencyProvider({
    required this.dependencyContainer,
    required super.child,
    super.key,
  });

  final DependencyContainer dependencyContainer;

  static DependencyContainer of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DependencyProvider>()!
        .dependencyContainer;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

void main() {
  runApp(
    DependencyProvider(
      dependencyContainer: DependencyContainer()
        ..registerDependency<TrainingService>((container) => TrainingService())
        ..registerDependency<StudentService>(
          (container) => StudentService(
            trainingService: container.getDependency<TrainingService>()!,
          ),
        ),
      child: const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SurfaceChild(),
              NestedDependency(),
              SurfaceChild(),
            ],
          ),
        ),
      ),
    ),
  );
}

class NestedDependency extends StatelessWidget {
  const NestedDependency({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DependencyProvider(
      dependencyContainer: DependencyContainer(
        parent: DependencyProvider.of(context),
      )
        ..registerDependency<TrainingService>(
            (container) => OtherTrainingService())
        ..registerDependency<TrainerService>(
          (container) => TrainerService(
            trainingService: container.getDependency<TrainingService>()!,
          ),
        ),
      child: const SurfaceChild(),
    );
  }
}

class SurfaceChild extends StatelessWidget {
  const SurfaceChild({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var trainerService =
        DependencyProvider.of(context).getDependency<TrainerService>();

    var trainingService =
        DependencyProvider.of(context).getDependency<TrainingService>();

    var studentService =
        DependencyProvider.of(context).getDependency<StudentService>();
    return Text(
      "${trainerService.runtimeType} ${trainingService.runtimeType} ${studentService?.trainingService.runtimeType}",
    );
  }
}
