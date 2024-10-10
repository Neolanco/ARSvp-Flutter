import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'logic/GetSubPlans.dart'; // Import the background logic
import 'models/Day.dart';        // Import the Day model

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
        title: 'Substitution Plan',
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
  int currentIndex = 0;
  List<Day> days = [];

  @override
  void initState() {
    super.initState();
    subPlanFuture = getSubPlanLocal().then((fetchedDays) {
      setState(() {
        days = fetchedDays;
      });
      return fetchedDays;
    });
  }

  void navigateToPage(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.jumpToPage(index);
  }

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          days.isNotEmpty
              ? '${days[currentIndex].date} (${currentIndex + 1}/${days.length})'
              : 'Substitution Plan',
        ),
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
            // Populate the day list
            return PageView.builder(
              controller: pageController,
              itemCount: days.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                Day day = days[index];
                return ListView(
                  children: day.subPlans.map((subPlan) {
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        title: Text(
                            '${subPlan.course}, ${subPlan.position} - ${subPlan.subject}: ${subPlan.type}'),
                        subtitle: Text(
                            'Teacher: ${subPlan.teacher}, Room: ${subPlan.room}, Remark: ${subPlan.remark}'),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          // Show the buttons only if the screen width is larger than 600px (i.e., on desktop or tablet)
          if (constraints.maxWidth > 600) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (currentIndex > 0) {
                      navigateToPage(currentIndex - 1);
                    }
                  },
                  child: Icon(Icons.arrow_left),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (currentIndex < days.length - 1) {
                      navigateToPage(currentIndex + 1);
                    }
                  },
                  child: Icon(Icons.arrow_right),
                ),
              ],
            );
          } else {
            // No buttons for mobile view
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
