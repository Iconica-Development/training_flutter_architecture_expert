// ignore_for_file: Generated using data class generator
import 'package:dependency_injection_demo/solution.dart';
import 'package:flutter/material.dart';

class TrainingService {
  final UserService service;

  TrainingService({required this.service});

  @override
  String toString() => 'TrainingService(service: $service)';
}

class UserService {
  @override
  String toString() => 'UserService()';
}

void main(List<String> args) {
  runApp(MaterialApp(
    home: Scaffold(
      body: CounterServiceProvider(
        service: ProperCounter(),
        child: DependencyProvider(
          lazyDependencyContainer: LazyDependencyContainer()
            ..registerDependency((context) {
              return UserService();
            })
            ..registerDependency((context) {
              return TrainingService(
                service: DependencyProvider.of<UserService>(context)!,
              );
            }),
          child: Column(
            children: [
              const Expanded(
                child: CounterScreen(),
              ),
              Expanded(
                child: CounterServiceProvider(
                  service: MyCounter(),
                  child: const CounterScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}

class DependencyContainer {
  // standard structure for a singleton
  factory DependencyContainer.instance() {
    return DependencyContainer._instance ??= DependencyContainer._();
  }
  DependencyContainer._();
  static DependencyContainer? _instance;

  // a simple registry for dependencies
  final Map<Type, dynamic> _dependencies = {};

  void registerDependency<T>(T dependency) {
    _dependencies[T] = dependency;
  }

  T? getDependency<T>() {
    return _dependencies[T];
  }
}

abstract interface class CounterService implements ChangeNotifier {
  void countUp();

  int getCount();
}

class ProperCounter with ChangeNotifier implements CounterService {
  int count = 0;

  @override
  void countUp() {
    count++;
    notifyListeners();
  }

  @override
  int getCount() {
    return count;
  }
}

class MyCounter with ChangeNotifier implements CounterService {
  int count = 1;
  @override
  void countUp() {
    count += count % 3;
    notifyListeners();
  }

  @override
  int getCount() {
    return count + 10;
  }
}

class CounterServiceProvider extends InheritedWidget {
  final CounterService service;

  const CounterServiceProvider({
    required this.service,
    required super.child,
    super.key,
  });

  static CounterService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CounterServiceProvider>()!
        .service;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var service = CounterServiceProvider.of(context);

    var trainingService = DependencyProvider.of<TrainingService>(context);

    return _CounterScreen(
      counterService: service,
      trainingService: trainingService!,
    );
  }
}

class _CounterScreen extends StatelessWidget {
  const _CounterScreen({
    required this.counterService,
    required this.trainingService,
  });

  final CounterService counterService;
  final TrainingService trainingService;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: LiveCount(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(trainingService.toString()),
        ),
        Center(
          child: FilledButton(
            onPressed: () {
              counterService.countUp();
            },
            child: const Text('Count up'),
          ),
        )
      ],
    );
  }
}

class LiveCount extends StatelessWidget {
  const LiveCount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var service = CounterServiceProvider.of(context);

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Text('Count is: ${service.getCount()}');
      },
    );
  }
}
