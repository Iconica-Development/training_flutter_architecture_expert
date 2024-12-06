import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyState extends ChangeNotifier {
  int counter;

  MyState({
    required this.counter,
  });

  void increment() {
    counter++;
    notifyListeners();
  }
}

class StateWatcher extends StatelessWidget {
  const StateWatcher({
    super.key,
    required this.state,
  });

  final MyState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CounterDisplay(state: state),
        FilledButton(
          onPressed: state.increment,
          child: const Text("increment"),
        ),
      ],
    );
  }
}

class CounterDisplay extends StatefulWidget {
  const CounterDisplay({
    super.key,
    required this.state,
  });

  final MyState state;

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  void onStateUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.state.addListener(onStateUpdate);
  }

  @override
  void dispose() {
    widget.state.removeListener(onStateUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Count: ${widget.state.counter}");
  }
}
