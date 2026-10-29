import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()(); 
  TextColumn get title => text().nullable().withLength(max: 50)();
  DateTimeColumn get startedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get endedAt => dateTime().nullable()();
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 50)();
  IntColumn get workoutId => integer().references(Workouts, #id)();
}

class ExerciseSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weight => real().nullable()();
  IntColumn get reps => integer().nullable()();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
}

class WorkoutWithExercises {
  final Workout workout;
  final List<Exercise> exercises;

  WorkoutWithExercises(this.workout, this.exercises);
}

@DriftDatabase(tables: [Workouts, Exercises, ExerciseSets])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  Stream<List<WorkoutWithExercises>> watchWorkoutWithExercises({bool onlyShowCompleted = false}) {
    // the query defined in dart, look for workouts and left join with exercises
    var query = select(workouts).join([
      leftOuterJoin(exercises, exercises.workoutId.equalsExp(workouts.id)),
    ])
    ..orderBy([OrderingTerm.asc(workouts.id)]);

    if (onlyShowCompleted) {
      query = query..where(workouts.endedAt.isNotNull());
    }

    // watch() used 
    return query.watch().map((rows) {
      final grouped = <int, WorkoutWithExercises>{};
      for (final row in rows) {
        final workout = row.readTable(workouts);
        final exercise = row.readTableOrNull(exercises);
        final entry = grouped.putIfAbsent(
          workout.id,
          () => WorkoutWithExercises(workout, []),
        );
        if (exercise != null) entry.exercises.add(exercise);
      }
      return grouped.values.toList(); 
    });
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory
      ),
    );
  }
}