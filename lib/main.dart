import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:testing_drift/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase(); 
  runApp(MainApp(database: database));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.database});

  final AppDatabase database;

  Future<void> addWorkout() async {
    await database.transaction(() async { // https://drift.simonbinder.eu/dart_api/transactions/
      final insertedWorkoutId = await database.into(database.workouts).insert(
        WorkoutsCompanion.insert(
          title: Value('New workout'), //title is nullable
        ),
      );

      await database.into(database.exercises).insert(
        ExercisesCompanion.insert(
          name: 'New exercise',
          workoutId: insertedWorkoutId,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: StreamBuilder<List<Workout>>(
          stream: database.select(database.workouts).watch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(child: Text('No workouts yet'));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final workout = items[index];
                return ListTile(
                  title: Text('${workout.id} - ${workout.title ?? 'Untitled workout'}'),
                  subtitle: Text(workout.startedAt.toString()),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addWorkout,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
