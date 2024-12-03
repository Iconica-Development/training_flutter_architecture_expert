import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:training_app/searchable_training_overview.dart';

void main(List<String> args) {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: TrainingOverviewScreen(),
      ),
    ),
  );
}
