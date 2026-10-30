import 'package:drift/drift.dart' hide Column;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testing_drift/bloc/counter_bloc.dart';
import 'package:testing_drift/counter_page.dart';
import 'package:testing_drift/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:testing_drift/workout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // needed?
  final database = AppDatabase();
  runApp(
    CupertinoApp(
      title: 'Bloc stuff', // https://www.youtube.com/watch?v=3bEkaRUVOeU
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CounterBloc())
        ],
        child: CounterPage(),
        // child: CupertinoWorkoutList(database: database),
      ),
    ),
  );
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
    _completedWorkoutsStream = widget.database.watchWorkoutWithExercises(
      onlyShowCompleted: false,
    );
  }

  Future<void> addWorkout() async {
    final newWorkoutId = await widget.database.transaction(() async {
      // https://drift.simonbinder.eu/dart_api/transactions/
      final insertedWorkoutId = await widget.database
          .into(widget.database.workouts)
          .insert(
            WorkoutsCompanion.insert(
              title: Value('New workout'), //title is nullable
              // endedAt: Value(DateTime.now()), // set to make workout 'completed'
            ),
          );

      await widget.database
          .into(widget.database.exercises)
          .insert(
            ExercisesCompanion.insert(
              name: 'New exercise',
              workoutId: insertedWorkoutId,
            ),
          );
      return insertedWorkoutId;
    });
    
    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => WorkoutDetails(workoutId: newWorkoutId,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Workout app')),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CupertinoButton(
                onPressed: addWorkout,
                child: const Text('Create workout'),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<WorkoutWithExercises>>(
                stream: _completedWorkoutsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No completed workouts yet'),
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final workoutWithExercises = items[index];
                      return CupertinoListTile(
                        title: Text(
                          '${workoutWithExercises.workout.id} - ${workoutWithExercises.workout.title ?? 'Untitled workout'}',
                        ),
                        subtitle: Text(
                          '${workoutWithExercises.exercises.length} exercise',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
