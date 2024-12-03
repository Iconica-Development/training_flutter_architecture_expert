# Common packages

---
## UI State management

- Flutter Hooks

---
## State management

- Riverpod
- Flutter BLoC
- GetX
- Solidart

---
## dependency injection

- Provider
- Riverpod
- GetX

---
## Examples

---
# GetX

> GetX is an easy, practical, and scalable way to build high-performance applications with the Flutter SDK.

---
### What is GetX 
GetX is a package for 
- high-performance state management
- intelligent dependency injection
- route management 

GetX is quickly and practically.

---
### What is GetX 
GetX has 3 basic principles

- PERFORMANCE 
  - focused on performance and minimum consumption of resources
  - does not use Streams or ChangeNotifier

---
- PRODUCTIVITY
  - uses an easy and pleasant syntax
  - will save hours of development 
  - provide the maximum performance your application can deliver
  - resources are removed from memory when they are not used by default
  - dependency loading is also lazy by default.

---
- ORGANIZATION
  - decoupling of the View, presentation logic, business logic, dependency injection, and navigation
  - no need for context to navigate between routes
  - no inheritedWidget, so you completely decouple your presentation logic and business logic from your visualization layer
  - no MultiProviders
  

---
### What is GetX 
GetX has a huge ecosystem, a large community, a large number of collaborators, and will be maintained as long as the Flutter exists.

GetX too is capable of running with the same code on Android, iOS, Web, Mac, Linux, Windows, and on your server. 

---
### Other GetX tools
Get Server
  - reuse your code made on the frontend on your backend 
Get CLI
  - automate the entire development process can be completely 
  - extension to VSCode and the extension to Android Studio/Intellij

---
### Installing GetX 
Add Get to your pubspec.yaml file:
```
dependencies:
  get:
```
Import get in files that it will be used:
```
import 'package:get/get.dart';
```

---
### GetX - The Three pillars 
- State management
- Route management
- Dependency management

---
### GetX - State management

Get has two different state managers
- the simple state manager (we'll call it GetBuilder) 
- the reactive state manager (GetX/Obx)

---
### GetX - Reactive State Manager 
Reactive programming is said to be complicated. In GetX reactive programming is quite simple:

- You won't need to create StreamControllers.
- You won't need to create a StreamBuilder for each variable
- You will not need to create a class for each state.
- You will not need to create a get for an initial value.
- You will not need to use code generators

Reactive programming with Get is as easy as using setState.

---
### GetX - Reactive State Manager Example
Let's imagine that you have a name variable and want that every time you change it, all widgets that use it are automatically changed.
```
var name = 'John Gorter';
```
To make it observable, you just need to add ".obs" to the end of it:
```
var name = 'John Gorter'.obs;
```
And in the UI, when you want to show that value and update the screen whenever the values changes, simply do this:
```
Obx(() => Text("${controller.name}"));
```
That's all. It's that simple.

---
# Flutter BLoC

A package to use the bloc pattern

> dependencies:
>  flutter_bloc: ^8.1.3

---
### Defining a BLoC

```dart
/// Event being processed by [CounterBloc].
abstract class CounterEvent {}

/// Notifies bloc to increment state.
class CounterIncrementPressed extends CounterEvent {}

/// Notifies bloc to decrement state.
class CounterDecrementPressed extends CounterEvent {}

/// {@template counter_bloc}
/// A simple [Bloc] that manages an `int` as its state.
/// {@endtemplate}
class CounterBloc extends Bloc<CounterEvent, int> {
  /// {@macro counter_bloc}
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
    on<CounterDecrementPressed>((event, emit) => emit(state - 1));
  }
}
```

---
### Using a BLoC

```dart
    // providing a bloc
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: const CounterView(),
    );

    // listening to a bloc
    BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
            return Text(
                '$count',
                style: Theme.of(context).textTheme.displayLarge,
            );
        },
    ),
```

---
# Solidart

A simple statemanagement library inspired by solidjs

---
### What is Solidart

There are 4 main concepts you should be aware of:

- Signals
- Effects
- Resources
- Solid

---
### Solidart: Signals

Signals are the cornerstone of reactivity in solidart. They contain values that change over time; when you change a signal's value, it automatically updates anything that uses it.

```dart
final counter = createSignal(0);

// Retrieve the current counter value
print(counter.value); // prints 0
// Increment the counter value
counter.value++;
```

---
### Soldart: Effects
Signals are trackable values, but they are only one half of the equation. To complement those are observers that can be updated by those trackable values. An effect is one such observer; it runs a side effect that depends on signals.

```dart
createEffect(() {
    print("The count is now ${counter.value}");
}, signals: [counter]);
```

---
### Solidart: Resources

Resources are special Signals designed specifically to handle Async loading. Their purpose is wrap async values in a way that makes them easy to interact with.

```dart
final userId = createSignal(1);

// The fetcher
Future<String> fetchUser() async {
    final response = await http.get(
      Uri.parse('https://swapi.dev/api/people/${userId.value}/'),
    );
    return response.body;
}

// The resource
final user = createResource(fetcher: fetchUser, source: userId);
```

---
### Solidart: Solid

A Solid is a container that allows you to lookup your signals through your widget tree.

```dart
final themeMode = context.get<Signal<ThemeMode>>(SignalId.themeMode);
```

---
# Riverpod

Riverpod is similar to provider, but it allows for multiple providers for the same type.

It has a rich featureset for caching, dependency injection and state management.

---
### Using Riverpod

```dart
// create a provider
final counterProvider = StateProvider<int>((ref) => 0);

// use the provider
Widget build(BuildContext context, WidgetRef ref) {
    // watch causes a rebuild whenever the count changes
    var count = ref.watch(counterProvider);

    return ElevatedButton(child: Text('Count: $count'), onPressed: () {
        ref.read(counterProvider.notifier).state = count+1;
    });
}
```

---
### Provider Modifiers

Family
```dart
// this will give a unique provider for each unique string given as an argument
final familyProvider = StateProvider.family<int, String>((ref, arg) => Counter(0));
// and is read like this:
var counterA = ref.watch(familyProvider('A'));
var counterB = ref.watch(familyProvider('B'));
var counterC = ref.watch(familyProvider('A'));

assert(counterA == counterC);
assert(counterA != counterB);
```

Autodispose
```dart
// this will automatically dispose the provider as soon as it is no longer watched or listened to.
final autoDisposable = Provider.autoDispose<int>((ref) => 0);
```

---
<!-- .slide: data-background="url('images/lab2.jpg')" --> 
<!-- .slide: class="lab" -->
## Lab time!
