// main.dart
import 'package:flutter/material.dart';
import 'logic/GetSubPlans.dart'; // Import the background logic
import 'models/Day.dart';        // Import the Day model
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(SubPlanApp());
}

class SubPlanApp extends StatelessWidget {
  const SubPlanApp({Key? key}) : super(key: key);

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Dynamic Color',
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: SubPlanScreen(),
      );
    });
  }
}

class SubPlanScreen extends StatefulWidget {
  @override
  _SubPlanScreenState createState() => _SubPlanScreenState();
}

class _SubPlanScreenState extends State<SubPlanScreen> {
  Future<List<Day>>? subPlanFuture;

  @override
  void initState() {
    super.initState();
    subPlanFuture = getSubPlanLocal(); // Call the function from the logic file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Substitution Plan'),
        elevation: 4,
      ),
      body: FutureBuilder<List<Day>>(
        future: subPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            // Display the substitution plans by day
            List<Day> days = snapshot.data!;

            return ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                Day day = days[index];
                return ExpansionTile(
                  title: Text(day.date),
                  children: day.subPlans.map((subPlan) {
                    return ListTile(
                      title: Text('Class: ${subPlan.course}, Subject: ${subPlan.subject}'),
                      subtitle: Text('Teacher: ${subPlan.teacher}, Room: ${subPlan.room}, Remark: ${subPlan.remark}'),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
