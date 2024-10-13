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

class _SubPlanScreenState extends State<SubPlanScreen> with SingleTickerProviderStateMixin {
  Future<List<Day>>? subPlanFuture;
  List<Day> days = [];
  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    String subPlanUrl = getBaseUrl();
    subPlanFuture = getSubPlanLocal(subPlanUrl: subPlanUrl).then((fetchedDays) {
      setState(() {
        days = fetchedDays;
        _tabController = TabController(length: days.length, vsync: this);
        _tabController.addListener(_handleTabChange); // Add listener for tab changes
      });
      return fetchedDays;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      currentIndex = _tabController.index; // Always sync with TabController index
    });
  }

  void _switchToTab(int index) {
    setState(() {
      currentIndex = index;
      _tabController.animateTo(currentIndex); // Change the tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          days.isNotEmpty ? (days[currentIndex].dayDate.split(' '))[1] : 'Substitution Plan',
        ),
        elevation: 1,
        bottom: days.isNotEmpty
            ? TabBar(
                controller: _tabController,
                isScrollable: true, // For scrollable tabs if the number is large
                tabs: days.map((day) => Tab(text: (day.dayDate.split(' '))[0])).toList(),
              )
            : null,
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
            return TabBarView(
              controller: _tabController,
              children: days.map((day) {
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
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
