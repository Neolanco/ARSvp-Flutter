import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

Future<List<List<List<dynamic>>>> getSubPlanLocal() async {
  var subPlanUrl = 'https://ars-leipzig.de/vertretungen/HTML/';
  var dayAmount = await getDayamountRemote(subPlanUrl);
  var subPlanLocal = await getAllSubPlanRemote(subPlanUrl, dayAmount);
  return subPlanLocal;
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

Future<List<List<List<dynamic>>>> getAllSubPlanRemote(String url, int dayAmount) async {
  List<String> dayUrls = [];
  for (int k = 1; k <= dayAmount; k++) {
    String formattedAmount = k.toString().padLeft(3, '0');
    dayUrls.add(url + "V_DC_" + formattedAmount + ".html");
  }

  List<List<List<dynamic>>> plans = [];
  for (String dayUrl in dayUrls) {
    plans.add(await getSubPlanRemote(dayUrl));
  }
  return plans;
}

Future<List<List<dynamic>>> getSubPlanRemote(String subPlanUrl) async {
  var response = await http.Client().get(Uri.parse(subPlanUrl));
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    var element = document.querySelectorAll('table>tbody')[0];
    var data = element.querySelectorAll('tr');
    int amount = data.length;

    List<List<dynamic>> subPlanLocal = List.generate(amount - 1, (i) => List<dynamic>.generate(7, (index) => null));
    for (int k = 0; k < amount - 1; k++) {
      subPlanLocal[k][0] = data[k].children[0].text.trim(); // Klasse
      subPlanLocal[k][1] = data[k].children[1].text.trim(); // Pos
      subPlanLocal[k][2] = data[k].children[2].text.trim(); // Fach
      subPlanLocal[k][3] = data[k].children[3].text.trim(); // Lehrer
      subPlanLocal[k][4] = data[k].children[4].text.trim(); // Raum
      subPlanLocal[k][5] = data[k].children[5].text.trim(); // Art
      subPlanLocal[k][6] = data[k].children[6].text.trim(); // Bemerkung
    }
    return subPlanLocal;
  } else {
    throw Exception("Failed to load substitution plan");
  }
}
