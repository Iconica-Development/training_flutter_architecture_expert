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
# Flutter Hooks
A Flutter implementation of React hooks: https://medium.com/@dan_abramov/making-sense-of-react-hooks-fdbde8803889


---
### What are hooks
Hooks are a new kind of object that manage a Widget life-cycles. 

They exist for one reason
- increase the code-sharing between widgets by removing duplicates.

---
### Motivation
StatefulWidget suffers from a big problem
- it is very difficult to reuse the logic of say initState or dispose

---
An obvious example is AnimationController:
```
class Example extends StatefulWidget {
  final Duration duration;

  const Example({Key key, required this.duration})
      : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(Example oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller!.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

All widgets that desire to use an AnimationController will have to reimplement almost all of this from scratch, which is of course undesired.

---
### Mixins
Dart mixins can partially solve this issue, but they suffer from other problems
- a given mixin can only be used once per class
- mixins and the class shares the same object.
    - this means that if two mixins define a variable under the same name, the result may vary between compilation fails to unknown behavior.


---
### Hooks 
Hooks proposes a third solution
```
class Example extends HookWidget {
  const Example({Key key, required this.duration})
      : super(key: key);

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);
    return Container();
  }
}
```

---
### Hooks
This code is strictly equivalent to the previous example

Where did all the logic go? That logic moved into useAnimationController, a function included directly in this library

- It is what we call a Hook

---
### Hooks
Hooks are a new kind of objects 
- can only be used in the build method of a widget that mix-in Hooks
- is reusable an infinite number of times 

The following code defines two independent AnimationController
```
Widget build(BuildContext context) {
  final controller = useAnimationController();
  final controller2 = useAnimationController();
  return Container();
}
```
---
### Hooks Principle
Similarly to State, hooks are stored on the Element of a Widget. 

But instead of having one State, the Element stores a List<Hook>.

To use a Hook, one must call Hook.use

The hook returned by use is based on the number of times it has been called. The first call returns the first hook; the second call returns the second hook, the third returns the third hook....

---
### Hooks Principle
If this is still unclear, a naive implementation of hooks is the following:
```
class HookElement extends Element {
  List<HookState> _hooks;
  int _hookIndex;

  T use<T>(Hook<T> hook) => _hooks[_hookIndex++].build(this);

  @override
  performRebuild() {
    _hookIndex = 0;
    super.performRebuild();
  }
}
```

For more explanation of how they are implemented, here's a great article about how they did it in React: https://medium.com/@ryardley/react-hooks-not-magic-just-arrays-cd4f1857236e

---
## Hook Rules
Due to hooks being obtained from their index, some rules must be respected:

- DO always prefix your hooks with use
```
Widget build(BuildContext context) {
  // starts with `use`, good name
  useMyHook();
  // doesn't start with `use`, could confuse people into thinking that this isn't a hook
  myHook();
  // ....
}
```
- DO call hooks unconditionally
```
Widget build(BuildContext context) {
  useMyHook();
  // ....
}
```

---
- DON'T wrap use into a condition
```
Widget build(BuildContext context) {
  if (condition) {
    useMyHook();
  }
  // ....
}
```

---
### How to create hooks
There are two ways to create a hook:

- A function
```
ValueNotifier<T> useLoggedState<T>(BuildContext context, [T initialData]) {
  final result = useState<T>(initialData);
  useValueChanged(result.value, (_, __) {
    print(result.value);
  });
  return result;
}
```

---
- A class

```
class _TimeAlive extends Hook<void> {
  const _TimeAlive();

  @override
  _TimeAliveState createState() => _TimeAliveState();
}

class _TimeAliveState extends HookState<void, _TimeAlive> {
  DateTime start;

  @override
  void initHook() {
    super.initHook();
    start = DateTime.now();
  }

  @override
  void build(BuildContext context) {}

  @override
  void dispose() {
    print(DateTime.now().difference(start));
    super.dispose();
  }
}
```

---
### Existing hooks
Flutter_hooks comes with a list of reusable hooks already provided.

They are divided into different kinds:

- Primitives
- Object binding
- dart:async 
- Listenable
- Animation
- Misc

---
### Primitives
A set of low-level hooks that interacts with the different life-cycles of a widget

- useEffect	Useful for side-effects and optionally canceling them.
- useState	Create variable and subscribes to it.
- useMemoized	Cache the instance of a complex object.
- useRef	Creates an object that contains a single mutable property.
- useCallback	Cache a function instance.
- useContext	Obtain the BuildContext of the building HookWidget.
- useValueChanged	Watches a value and calls a callback whenever the value changed.


---
### Object binding
This category of hooks allows manipulating existing Flutter/Dart objects with hooks. They will take care of creating/updating/disposing an object.

---
### dart:async 

- useStream	Subscribes to a Stream and return its current state in an AsyncSnapshot.
- useStreamController	Creates a StreamController automatically disposed.
- useFuture	Subscribes to a Future and return its current state in an AsyncSnapshot.

---
### Animation related

- useSingleTickerProvider	Creates a single usage TickerProvider.
- useAnimationController	Creates an AnimationController automatically disposed.
- useAnimation	Subscribes to an Animation and return its value.

---
### Listenable related

- useListenable	Subscribes to a Listenable and mark the widget as needing build whenever the listener is called.
- useValueNotifier	Creates a ValueNotifier automatically disposed.
- useValueListenable	Subscribes to a ValueListenable and return its value.

---
### Misc
A series of hooks with no particular theme.

- useReducer	An alternative to useState for more complex states.
- usePrevious	Returns the previous argument called to [usePrevious].
- useTextEditingController	Create a TextEditingController
- useFocusNode	Create a FocusNode
- useTabController	Creates and disposes a TabController.
- useScrollController	Creates and disposes a ScrollController.
- usePageController	Creates and disposes a PageController.
- useIsMounted	An equivalent to State.mounted for hooks

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
