// main.dart
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'logic/GetSubPlans.dart'; // Import the background logic
import 'models/Day.dart'; // Import the Day model
import 'views/settings.dart'; // Import the Settings Page

void main() {
  runApp(const SubPlanApp());
}

class SubPlanApp extends StatelessWidget {
  const SubPlanApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue, brightness: Brightness.dark);

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
        home: const SubPlanScreen(),
      );
    });
  }
}

class SubPlanScreen extends StatefulWidget {
  const SubPlanScreen({super.key});

  @override
  _SubPlanScreenState createState() => _SubPlanScreenState();
}

String getBaseUrl() {
  if (kIsWeb) {
    return "to-be-implemented"; // Web specific URL
  } else {
    return "https://ars-leipzig.de/vertretungen/HTML/"; // Default URL
  }
}

class _SubPlanScreenState extends State<SubPlanScreen> {
  Future<List<Day>>? subPlanFuture;
  int currentIndex = 0;
  List<Day> days = [];
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    String subPlanUrl = getBaseUrl();
    subPlanFuture = getSubPlanLocal(subPlanUrl: subPlanUrl).then((fetchedDays) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          days.isNotEmpty ? '${days[currentIndex].date} (${currentIndex + 1}/${days.length})' : 'Substitution Plan',
        ),
        elevation: 1,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Day>>(
        future: subPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
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
                        title: Text('${subPlan.course}, ${subPlan.position} - ${subPlan.subject}: ${subPlan.type} ${subPlan.remark}'),
                        subtitle: Text('Teacher: ${subPlan.teacher}, Room: ${subPlan.room}'),
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
                  child: const Icon(Icons.arrow_left),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (currentIndex < days.length - 1) {
                      navigateToPage(currentIndex + 1);
                    }
                  },
                  child: const Icon(Icons.arrow_right),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
