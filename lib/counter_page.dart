
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testing_drift/bloc/counter_bloc.dart';
import 'package:testing_drift/bloc/counter_event.dart';
import 'package:testing_drift/bloc/counter_state.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = context.read<CounterBloc>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Counter test')),
      child: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: () => counterBloc.add(CounterIncrementPressed()),
                child: const Text('Add thing'),
              ),
              CupertinoButton(
                onPressed: () => counterBloc.add(CounterDecrementPressed()),
                child: const Text('Remove thing'),
              ),
              Expanded(
                child: BlocBuilder<CounterBloc, CounterState>(
                  builder: (context, state) {
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        for (int index = 0 ;index < state.count; index++)
                          Positioned(
                            left: Random().nextInt(250).toDouble(),
                            top: Random().nextInt(400).toDouble(),
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Image.asset('images/hank.jpg'),
                            )
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}