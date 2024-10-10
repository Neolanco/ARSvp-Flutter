import 'package:flutter/material.dart';
import 'logic/GetSubPlans.dart'; // Import the background logic
import 'models/SubPlan.dart';    // Import the SubPlan model

void main() {
  runApp(SubPlanApp());
}

class SubPlanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Substitution Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  Future<List<List<SubPlan>>>? subPlanFuture;

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
      ),
      body: FutureBuilder<List<List<SubPlan>>>(
        future: subPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            // Display the substitution plan
            List<List<SubPlan>> subPlans = snapshot.data!;
            return ListView.builder(
              itemCount: subPlans.length,
              itemBuilder: (context, dayIndex) {
                return ExpansionTile(
                  title: Text('Day ${dayIndex + 1}'),
                  children: subPlans[dayIndex].map((subPlan) {
                    return ListTile(
                      title: Text('Class: ${subPlan.course}, Subject: ${subPlan.subject}'),
                      subtitle: Text('Teacher: ${subPlan.teacher}, Room: ${subPlan.room}'),
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
