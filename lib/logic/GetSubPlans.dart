// GetSubPlans.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import '../models/Day.dart';      // Import the Day model

Future<List<Day>> getSubPlanLocal() async {
  var subPlanUrl = 'https://ars-leipzig.de/vertretungen/HTML/';
  var dayAmount = await getDayamountRemote(subPlanUrl);
  var days = await getAllSubPlanRemote(subPlanUrl, dayAmount);
  return days;
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

Future<List<Day>> getAllSubPlanRemote(String url, int dayAmount) async {
  List<Day> days = [];
  
  for (int k = 1; k <= dayAmount; k++) {
    String formattedAmount = k.toString().padLeft(3, '0');
    String dayUrl = url + "V_DC_" + formattedAmount + ".html";
    
    // Get the substitution plans for that day
    List<SubPlan> subPlans = await getSubPlanRemote(dayUrl);
    
    // You could dynamically calculate the date based on the day number (for example)
    // String date = 'Day $k';  // Replace this with actual date parsing logic if available
    String date = await getDateRemote(dayUrl);  // Replace this with actual date parsing logic if available
    
    days.add(Day(date: date, subPlans: subPlans));
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
    dom.Document document = parse(response.body);
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
