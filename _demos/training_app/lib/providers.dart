import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final myStateProvider = StateProvider((ref) => IntContainer(value: 1));

class IntContainer {
  int value;
  IntContainer({
    required this.value,
  });

  void increase() {
    value++;
  }
}

final powerProvider =
    Provider((ref) => pow(ref.watch(myStateProvider).value, 2));

class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var power = ref.watch(powerProvider);
    var value = ref.watch(myStateProvider);

    return Column(
      children: [
        Text('value: $value'),
        Text('power: $power'),
        FilledButton(
          onPressed: () {
            var container = ref.read(myStateProvider);

            container.increase();

            ref.read(myStateProvider.notifier).state = container;
          },
          child: const Text('Increase'),
        ),
      ],
    );
  }
}
