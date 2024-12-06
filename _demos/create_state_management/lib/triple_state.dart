import 'dart:async';

import 'package:create_state_management/create_state_management.dart';
import 'package:flutter/foundation.dart';

void main(List<String> args) {
  var future = Future.delayed(const Duration(seconds: 1), () => 10);

  var state = FutureToStateContainer(() async => await future);

  void printState() {
    state.tripleState.when(
      data: (data) => print(data),
      error: (error, stackTrace) => print(error),
      loading: () => print("loading"),
    );
  }

  state.addListener(printState);
}

class FutureToStateContainer<T> extends ChangeNotifier {
  FutureToStateContainer(
    this.futureInit,
  ) : tripleState = TripleState.loading() {
    unawaited(_startFuture());
  }

  Future<void> _startFuture() async {
    try {
      var data = await futureInit();
      tripleState = tripleState.moveToState(TripleState.data(data: data));
      notifyListeners();
    } catch (e, s) {
      tripleState = tripleState.moveToState(
        TripleState.error(error: e, stackTrace: s),
      );
      notifyListeners();
    }
  }

  void invalidate() {
    tripleState = tripleState.moveToState(TripleState.loading());
    notifyListeners();
    _startFuture();
  }

  final Future<T> Function() futureInit;

  TripleState<T> tripleState;
}
