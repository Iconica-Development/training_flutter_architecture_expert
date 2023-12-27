# State mangement

---
## State management in flutter

As you explore Flutter, there comes a time when you need to share application state between screens, across your app. There are many approaches you can take, and many questions to think about.

> Flutter is declarative. This means that Flutter builds its user interface to reflect the current state of your app.

---
## Declarative approach to state

When the state of your app changes (for example, the user flips a switch in the settings screen), you change the state, and that triggers a redraw of the user interface. There is no imperative changing of the UI itself (like widget.setText)—you change the state, and the UI rebuilds from scratch.

---
## setState

Simplest form of state management. Used for Ephemeral state (Or UI State). Contains state within a single widget.

> setState can only be used whenever the knowledge of the state is contained within the widget.

> A good package to simplify widget/ui state is Flutter Hooks.

---
# Provider with ChangeNotifier

---
###  What is provider

Provider is a package that works with the low-level widgets but is simple to use. 

---
###  How to use provider
Before working with provider, don’t forget to add the dependency on it to your pubspec.yaml.

```
content_copy
name: my_name
description: Blah blah blah.

# ...

dependencies:
  flutter:
    sdk: flutter

  provider: ^5.0.0

dev_dependencies:
  # ...

```
Now you can import 'package:provider/provider.dart'; and start building.

---
###  How to use provider
With provider, you don’t need to worry about callbacks or InheritedWidgets. But you do need to understand 3 concepts:

- ChangeNotifier
- ChangeNotifierProvider
- Consumer


---
### ChangeNotifier
ChangeNotifier is a simple class included in the Flutter SDK which provides change notification to its listeners. In other words, if something is a ChangeNotifier, you can subscribe to its changes. 

It is a form of Observable, for those familiar with the term.

---
### ChangeNotifier
In our shopping app example, we want to manage the state of the cart in a ChangeNotifier. We create a new class that extends it, like so:

```
class CartModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  final List<Item> _items = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  /// The current total price of all items (assuming all items cost $42).
  int get totalPrice => _items.length * 42;

  /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(Item item) {
    _items.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
```

---
### ChangeNotifier

The only code that is specific to ChangeNotifier is the call to notifyListeners(). 

Call this method any time the model changes in a way that might change your app’s UI. Everything else in CartModel is the model itself and its business logic.

---
### ChangeNotifier and unit testing

ChangeNotifier is part of flutter:foundation and doesn’t depend on any higher-level classes in Flutter. It’s easily testable (you don’t even need to use widget testing for it). For example, here’s a simple unit test of CartModel:

```
test('adding item increases total cost', () {
  final cart = CartModel();
  final startingPrice = cart.totalPrice;
  cart.addListener(() {
    expect(cart.totalPrice, greaterThan(startingPrice));
  });
  cart.add(Item('Dash'));
});
```

---
### ChangeNotifierProvider
ChangeNotifierProvider is the widget that provides an instance of a ChangeNotifier to its descendants. 

It comes from the provider package.

---
### ChangeNotifierProvider
In our case, the only widget that is on top of both MyCart and MyCatalog is MyApp.

```
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}
```

Note that we’re defining a builder that creates a new instance of CartModel. 

---
### ChangeNotifierProvider
If you want to provide more than one class, you can use MultiProvider:

```
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        Provider(create: (context) => SomeOtherClass()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---
### Consumer
Now that CartModel is provided to widgets in our app through the ChangeNotifierProvider declaration at the top, we can start using it.

This is done through the Consumer widget.

---
### Consumer
```
return Consumer<CartModel>(
  builder: (context, cart, child) {
    return Text("Total price: ${cart.totalPrice}");
  },
);
```

We must specify the type of the model that we want to access. In this case, we want CartModel, so we write Consumer<CartModel>. 

The second argument of the builder function is the instance of the ChangeNotifier. 

---
### Consumer
The third argument is child, which is there for optimization. If you have a large widget subtree under your Consumer that doesn’t change when the model changes, you can construct it once and get it through the builder.

```
return Consumer<CartModel>(
  builder: (context, cart, child) => Stack(
    children: [
      // Use SomeExpensiveWidget here, without rebuilding every time.
      if (child != null) child,
      Text("Total price: ${cart.totalPrice}"),
    ],
  ),
  // Build the expensive widget here.
  child: const SomeExpensiveWidget(),
);
```

---
### Consumer best practice

- put your Consumer widgets as deep in the tree as possible
  - You don’t want to rebuild large portions of the UI just because some detail somewhere changed.

---
### Consumer best practice
```
// DON'T DO THIS
return Consumer<CartModel>(
  builder: (context, cart, child) {
    return HumongousWidget(
      // ...
      child: AnotherMonstrousWidget(
        // ...
        child: Text('Total price: ${cart.totalPrice}'),
      ),
    );
  },
);

```
Instead:
```
// DO THIS
return HumongousWidget(
  // ...
  child: AnotherMonstrousWidget(
    // ...
    child: Consumer<CartModel>(
      builder: (context, cart, child) {
        return Text('Total price: ${cart.totalPrice}');
      },
    ),
  ),
);
```

---
### Provider.of
Sometimes, you don’t really need the data in the model to change the UI but you still need to access it. 

For example, a ClearCart button wants to allow the user to remove everything from the cart. It doesn’t need to display the contents of the cart, it just needs to call the clear() method.

Consumer<CartModel> rebuilds a widget on every change, so not an option.

---
### Provider.of
For this use case, we can use Provider.of, with the listen parameter set to false.

```
Provider.of<CartModel>(context, listen: false).removeAll();
```

Using the above line in a build method won’t cause this widget to rebuild when notifyListeners is called.

---
<!-- .slide: data-background="url('images/lab2.jpg')" --> 
<!-- .slide: class="lab" -->
## Lab time!

---
## BLoC

---
###  What is Bloc

BLoC stands for Business Logic Controller. 

- created by Google and introduced at Google I/O 2018
- created based on Streams and Reactive Programming

---
###  What is BLoC
Two libraries that make working with it much easier: bloc and flutter_bloc. I would also recommend the official documentation of these libraries. It is well-written, with tons of examples that could be applied to most use-cases. I will describe briefly all BLoC components, but if you want to dive deeper, the documentation is the best place to go.

---
### Layers of BLoC

In the BLoC pattern, we can distinguish four main layers of application:

- UI: It holds all the application's components that are visible to the user and could be interacted with. Since in Flutter all parts of the User Interface are Widgets, we can say that all of them belong in this layer.

- BLoC: These are the classes that act as a layer between data and UI components. The BLoC listens to events passed from it, and after receiving a response, it emits an appropriate state.

---
- Repository: It is responsible for fetching pieces of information from single or multiple data sources and processing it for the UI classes.

- Data sources: These are classes that provide the data for the application, from all the data sources, including the database, network, shared preferences, etc.

---
### Bloc Communication

So now, when we know all the basic structures, we should understand how these layers communicate with each other. The BLoC pattern relies on two main components, presented below.

Events that are passed from UI, which contains information about a specific action that has to be handled by the BLoC.

States that show how the UI should react to change of data. Every BLoC has its initial state, which is defined upon creation.

---
### BLoC: An example

If we wanted to implement a login screen, we would need to pass LoginEvent with login details when the user clicks on the appropriate button. After receiving a response, the BLoC should show the SuccessState when the login has been completed successfully, or ErrorState when the user has entered the wrong credentials, or a different error has occurred

---
## Triple pattern (Segmented State)

Separate state into:

- Error
- Loading
- State

For more info, see the triple documentation

> https://triple.flutterando.com.br/

---
## Triple Pattern: Example
```dart
class CounterStore extends Store<int> {
  CounterStore() : super(0);

  void increment() => update(state + 1);
  void decrement() => update(state - 1);
}

// in your state class
final store = CounterStore();

// in your build
ScopedBuilder<CounterStore, int>(
    store: store,
    onLoading: (context) => Center(child: CircularProgressIndicator()),
    onError: (context, error) => Center(child: Text(error.toString())),
    onState: (context, state) => Center(
        child: Text(
            '$state',
            style: Theme.of(context).textTheme.headline4,
        ),
)
```

---
### The triple pattern

> The triple pattern is often seen in combination with other state management solutions