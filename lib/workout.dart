import 'package:flutter/cupertino.dart';
// import 'package:testing_drift/database.dart';

class WorkoutDetails extends StatelessWidget {
  const WorkoutDetails({super.key, required this.workoutId});

  final int workoutId;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Workout Details $workoutId')),
      child: Center(
        child: CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
