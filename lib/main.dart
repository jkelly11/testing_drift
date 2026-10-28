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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Todos')),
        body: StreamBuilder<List<TodoItem>>(
          stream: database.select(database.todoItems).watch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(child: Text('No todos yet'));
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.content),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            database.into(database.todoItems).insert(
                  TodoItemsCompanion.insert(
                    title: 'New todo',
                    content: 'Added at ${DateTime.now()}',
                  ),
                );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
