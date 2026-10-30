import 'package:drift/drift.dart' hide Column;
// import 'package:flutter/material.dart';
import 'package:testing_drift/database.dart';
import 'package:flutter/cupertino.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(); 
  // runApp(WorkoutList(database: database));
  runApp(CupertinoApp(title: 'Navigation basics', home: CupertinoWorkoutList(database: database,)));
}

class CupertinoWorkoutList extends StatefulWidget {
  const CupertinoWorkoutList({super.key, required this.database});
  final AppDatabase database;

  @override
  State<CupertinoWorkoutList> createState() => _WorkOutListState();
}

class _WorkOutListState extends State<CupertinoWorkoutList> {
  late final Stream<List<WorkoutWithExercises>> _completedWorkoutsStream;

  @override
  void initState() {
    super.initState();
    _completedWorkoutsStream = widget.database.watchWorkoutWithExercises(onlyShowCompleted: true);
  }

  Future<void> addWorkout() async {
    final newWorkoutId = await widget.database.transaction(() async { // https://drift.simonbinder.eu/dart_api/transactions/
      final insertedWorkoutId = await widget.database.into(widget.database.workouts).insert(
        WorkoutsCompanion.insert(
          title: Value('New workout'), //title is nullable
          // endedAt: Value(DateTime.now()), // set to make workout 'completed'
        ),
      );

      await widget.database.into(widget.database.exercises).insert(
        ExercisesCompanion.insert(
          name: 'New exercise',
          workoutId: insertedWorkoutId,
        ),
      );
      return insertedWorkoutId;
    });

    print('new workout is created with an exercise and is returned from transaction');
    print(newWorkoutId);

    // now to redirect
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Workout app')),
        child: SafeArea(child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Center(child: CupertinoButton(
            onPressed: addWorkout,
            child: const Text('Create workout'),
          ),) ],
        ),)
    );
  }
        // child: StreamBuilder<List<WorkoutWithExercises>>(
        //   stream: _completedWorkoutsStream,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return Center(child: Text('Error: ${snapshot.error}'));
        //     }
        //     if (!snapshot.hasData) {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //     final items = snapshot.data!;
        //     // if (items.isEmpty) {
        //     //   return const Center(child: Text('No workouts yet'));
        //     // }
        //     return Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.all(16),
        //           child: Text('Completed Workouts', style: Theme.of(context).textTheme.headlineSmall),
        //         ),
        //         Expanded(
        //           child: ListView.builder(
        //             itemCount: items.length,
        //             itemBuilder: (context, index) {
        //               final workoutWithExercises = items[index];
        //               return ListTile(
        //                 title: Text('${workoutWithExercises.workout.id} - ${workoutWithExercises.workout.title ?? 'Untitled workout'}'),
        //                 subtitle: Text('${workoutWithExercises.exercises.length} exercise'),
        //               );
        //             },
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: addWorkout,
        //   child: const Icon(Icons.add),
        // ),
      //),
    //);
  //}
}
