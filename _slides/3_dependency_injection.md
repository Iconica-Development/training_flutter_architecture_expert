# Dependency Injection

---
## Dependency Injection 

- Inverse the dependencies
- Provide dependencies through a constructor or retrieving from a container/context
- Make dependencies explicit

---
## Dependency Injection in Flutter

- Through inherited widgets
- Using a singleton dependency container
- Using third party libraries with built-in dependency injection

---
### Dependency Injection through inherited widgets

```dart
// define a inherited widget
class InheritedServiceWidget extends InheritedWidget {
    final Service service;

    static Service of(BuildContext context) {
        return context.dependOnInheritedWidgetOfExactType<InheritedServiceWidget>().service;
    }
}
// use it in your code
Widget build(BuildContext context) {
    var service = Service.of(context);
    return Text('${service.count}');
}
```

Often best used in combination with a changeNotifier.

---
### Dependency Injection through a Singleton dependency Container

First, create a container to contain your dependencies

```dart
class DependencyContainer {
    // standard structure for a singleton
    factory DependencyContainer.instance() {
        return DependencyContainer._instance ??= DependencyContainer._();
    }
    DependencyContainer._();
    static DependencyContainer? _instance;

    // a simple registry for dependencies
    Map<Type, dynamic> _dependencies;

    void registerDependency<T>(T dependency) {
        _dependencies[T] = dependency;
    }

    T? getDependency<T>() {
        return _dependencies[T];
    }
}
```
---
### Dependency Injection through a Singleton dependency Container

Then set up your container in your main

```dart
abstract interface class MyService {}

class MyServiceImplementation implements MyService {}

main() {
    var container = DependencyContainer.instance();
    container.registerDependency<MyService>(MyServiceImplementation());
}
```
And then, you can retrieve your dependencies later
```dart
var service = DependencyContainer.instance().getDependency<MyService>();
```

> this is a simple example allowing only singleton dependencies, 
> it is better to use a third party package that solves this issue:
> Like provider, injector or riverpod

---
## Widget structure

Seperate Control and Layout with widgets.

This is to keep each widget as simple as possible and to improve testability.

```dart
class MyWidget extends StatelessWidget {
    Widget build(BuildContext context) {
        // define state and context loading in this widget
        var someService = Service.of(context);

        // current is an animatedWidget in this case
        var current = someService.getCurrent();

        return AnimatedBuilder(
            animation: current,
            builder: (context, child) {
                // provide the state to the current widget, making the
                // layout oblivious about the injection method
                return MyLayoutWidget(current);
            } 
        );
    }
}
```

