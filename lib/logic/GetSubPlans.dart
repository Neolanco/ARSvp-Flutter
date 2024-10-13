// logic/GetSubPlans.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import '../models/Day.dart';      // Import the Day model
import 'dart:convert'; // For utf8 decoding

Future<List<Day>> getSubPlanLocal({required String subPlanUrl}) async {
  var dayAmount = await getDayamountRemote(subPlanUrl);
  var days = await getAllSubPlanRemote(subPlanUrl, dayAmount);
  return days;
}

Future<int> getDayamountRemote(String subPlanUrl) async {
  var response = await http.Client().get(Uri.parse("${subPlanUrl}index.html"));
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    return document.getElementsByClassName("day").length - 1;
  } else {
    throw Exception("Failed to load day amount");
  }
}

Future<List<Day>> getAllSubPlanRemote(String url, int dayAmount) async {
  List<Day> days = [];
  
  for (int k = 1; k <= dayAmount; k++) {
    String formattedAmount = k.toString().padLeft(3, '0');
    String dayUrl = "${url}V_DC_$formattedAmount.html";
    
    List<SubPlan> subPlans = await getSubPlanRemote(dayUrl);    // Get the substitution plans for that day
    
    String dayDate = await getDateRemote(dayUrl);
    
    days.add(Day(dayDate: dayDate, subPlans: subPlans));
  }

  return days;
}

Future<String> getDateRemote(String subPlanUrl) async{
  var response = await http.Client().get(Uri.parse(subPlanUrl));
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    var element = document.querySelectorAll('body')[0];
    var data = element.querySelectorAll('h1');
    
    return data[0].text.trim();
    
  } else {
    throw Exception("Failed to load substitution plan");
  }
}


Future<List<SubPlan>> getSubPlanRemote(String subPlanUrl) async {
  var response = await http.Client().get(Uri.parse(subPlanUrl));
  if (response.statusCode == 200) {
    // Decode the response as UTF-8 (fixes äüö etc.)
    var body = utf8.decode(response.bodyBytes);
    dom.Document document = parse(body);
    var element = document.querySelectorAll('table>tbody')[0];
    var data = element.querySelectorAll('tr');
    int amount = data.length;

    List<SubPlan> subPlans = [];
    for (int k = 0; k < amount - 1; k++) {
      subPlans.add(
        SubPlan(
          course: data[k].children[0].text.trim(),
          position: data[k].children[1].text.trim(),
          subject: data[k].children[2].text.trim(),
          teacher: data[k].children[3].text.trim(),
          room: data[k].children[4].text.trim(),
          type: data[k].children[5].text.trim(),
          remark: data[k].children[6].text.trim(),
        ),
      );
    }
    return subPlans;
  } else {
    throw Exception("Failed to load substitution plan");
  }
}
