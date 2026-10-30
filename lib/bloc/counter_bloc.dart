import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testing_drift/bloc/counter_event.dart';
import 'package:testing_drift/bloc/counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<CounterIncrementPressed>((event, emit) {
      emit(CounterState(state.count + 1)); // increment the counter
    });
    on<CounterDecrementPressed>((event, emit) {
      emit(CounterState(state.count - 1)); // decrement the counter
    });
  }
}