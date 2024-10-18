// views/settings.dart
import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ListView(
          children: const <Widget>[cardSource()],
        ),
      ),
    );
  }
}

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
  final Uri url = Uri.parse('https://github.com/Neolanco/ARSvp-Flutter');
  //if (!await launchUrl(url)) {
  //  throw Exception('Could not launch $url');
  //}
}
