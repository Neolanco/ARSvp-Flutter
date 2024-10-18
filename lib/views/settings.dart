// views/settings.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final List<String> courses;
  final String? selectedCourse;

  const SettingsPage({super.key, required this.courses, this.selectedCourse});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedCourse;

  @override
  void initState() {
    super.initState();
    selectedCourse = widget.selectedCourse; // Set the initial selected course
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            DropdownButton<String>(
              value: selectedCourse,
              hint: const Text('Select a Course'),
              onChanged: (String? newCourse) {
                setState(() {
                  selectedCourse = newCourse;
                });
              },
              items: widget.courses.map<DropdownMenuItem<String>>((String course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedCourse);  // Return the selected course
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}





//import 'package:url_launcher/url_launcher.dart';


//class SettingsPage extends StatelessWidget {
//  const SettingsPage({super.key});
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text('Settings'),
//      ),
//      body: Center(
//        child: ListView(
//          children: const <Widget>[cardSource()],
//        ),
//      ),
//    );
//  }
//}


class cardSource extends StatelessWidget {
  const cardSource({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: InkWell(
        onTap: () {
          debugPrint('cardSource tapped');
          launcherSource();
        },
        child: const SizedBox(
          child: ListTile(
            leading: Icon(Icons.code),
            title: Text("Source"),
            subtitle: Text("Get Updates & More!"),
          ),
        ),
      ),
    );
  }
}


launcherSource() async {
  //final Uri url = Uri.parse('https://github.com/Neolanco/ARSvp-Flutter');
  //if (!await launchUrl(url)) {
  //  throw Exception('Could not launch $url');
  //}
}
