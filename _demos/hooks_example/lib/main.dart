import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const HookApp());
}

class HookApp extends StatelessWidget {
  const HookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: _CounterModule(),
          )
        ],
      ),
    );
  }
}

class _CounterModule extends HookWidget {
  const _CounterModule();

  @override
  Widget build(BuildContext context) {
    var countState = useState<int?>(null);
    var count = countState.value ?? 0;

    return Column(
      children: [
        Text("Count: $count"),
        FilledButton(
          onPressed: () {
            countState.value = ++count;
          },
          child: const Text("increment"),
        ),
        _CounterPageView(
          count: count,
        ),
      ],
    );
  }
}

class _CounterPageView extends HookWidget {
  const _CounterPageView({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    var controller = usePageController();

    print(count);

    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (!context.mounted) return;
        controller.animateToPage(
          count % 2,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
        );
      });

      return () {
        print("disposing for: $count");
      };
    }, [count]);

    return SizedBox.square(
      dimension: 200,
      child: PageView(
        controller: controller,
        children: [
          Container(
            height: 200,
            width: 200,
            color: Colors.red,
            child: const AutoUpdatingDate(
              seconds: 5,
            ),
          ),
          Container(
            height: 200,
            width: 200,
            color: Colors.blue,
            child: const AutoUpdatingDate(
              seconds: 1,
            ),
          )
        ],
      ),
    );
  }
}

class AutoUpdatingDate extends HookWidget {
  const AutoUpdatingDate({
    required this.seconds,
    super.key,
  });

  final int seconds;

  @override
  Widget build(BuildContext context) {
    var dateTime = useAutoUpdatingDateTime(
      duration: Duration(seconds: seconds),
    );
    return Text(dateTime.toIso8601String());
  }
}

DateTime useAutoUpdatingDateTime({
  Duration duration = const Duration(seconds: 1),
  List<Object?>? keys,
}) {
  return use(AutoUpdatingDateTimeHook(duration: duration, keys: keys));
}

class AutoUpdatingDateTimeHook extends Hook<DateTime> {
  const AutoUpdatingDateTimeHook({
    required this.duration,
    super.keys,
  });

  final Duration duration;

  @override
  CurrentDateHookState createState() => CurrentDateHookState();
}

class CurrentDateHookState
    extends HookState<DateTime, AutoUpdatingDateTimeHook> {
  late Timer timer;
  late final Timer otherTimer = Timer(Duration.zero, () {
    print(runtimeType);
  });

  Timer _initializeTimer() {
    return Timer.periodic(hook.duration, (_) {
      setState(() {});
    });
  }

  @override
  void initHook() {
    super.initHook();
    timer = _initializeTimer();
  }

  @override
  void didUpdateHook(AutoUpdatingDateTimeHook oldHook) {
    super.didUpdateHook(oldHook);

    if (oldHook.duration != hook.duration) {
      timer.cancel();
      timer = _initializeTimer();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  DateTime build(BuildContext context) {
    return DateTime.now();
  }
}
