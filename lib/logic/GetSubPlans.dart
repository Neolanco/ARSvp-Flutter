import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import '../models/SubPlan.dart';

Future<List<List<SubPlan>>> getSubPlanLocal() async {
  var subPlanUrl = 'https://ars-leipzig.de/vertretungen/HTML/';
  var dayAmount = await getDayamountRemote(subPlanUrl);
  return await getAllSubPlanRemote(subPlanUrl, dayAmount);
}

Future<int> getDayamountRemote(String subPlanUrl) async {
  var response = await http.Client().get(Uri.parse(subPlanUrl + "index.html"));
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    return document.getElementsByClassName("day").length - 1;
  } else {
    throw Exception("Failed to load day amount");
  }
}

Future<List<List<SubPlan>>> getAllSubPlanRemote(String url, int dayAmount) async {
  List<String> dayUrls = [];
  for (int k = 1; k <= dayAmount; k++) {
    String formattedAmount = k.toString().padLeft(3, '0');
    dayUrls.add(url + "V_DC_" + formattedAmount + ".html");
  }

  List<List<SubPlan>> plans = [];
  for (String dayUrl in dayUrls) {
    plans.add(await getSubPlanRemote(dayUrl));
  }
  return plans;
}

Future<List<SubPlan>> getSubPlanRemote(String subPlanUrl) async {
  var response = await http.Client().get(Uri.parse(subPlanUrl));
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    var element = document.querySelectorAll('table>tbody')[0];
    var data = element.querySelectorAll('tr');
    int amount = data.length;

    List<SubPlan> subPlans = [];
    for (int k = 0; k < amount - 1; k++) {
      subPlans.add(
        SubPlan(
          course: data[k].children[0].text.trim(),  // Klasse
          position: data[k].children[1].text.trim(), // Pos
          subject: data[k].children[2].text.trim(),  // Fach
          teacher: data[k].children[3].text.trim(),  // Lehrer
          room: data[k].children[4].text.trim(),     // Raum
          type: data[k].children[5].text.trim(),     // Art
          remark: data[k].children[6].text.trim(),   // Bemerkung
        ),
      );
    }
    return subPlans;
  } else {
    throw Exception("Failed to load substitution plan");
  }
}
