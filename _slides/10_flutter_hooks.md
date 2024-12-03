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
