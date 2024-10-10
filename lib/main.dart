// main.dart
import 'package:flutter/material.dart';
import 'logic/GetSubPlans.dart'; // Import the background logic
import 'models/Day.dart';        // Import the Day model
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(SubPlanApp());
}

class SubPlanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Substitution Plan',
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: const Color.fromARGB(255, 0, 255, 34)),
      ),
      home: SubPlanScreen(),
    );
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
