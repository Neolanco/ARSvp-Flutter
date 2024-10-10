import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

getSubPlanLocal() async {
  var SubPlanUrl = 'https://ars-leipzig.de/vertretungen/HTML/';
  var dayamount = (await getDayamountRemote(SubPlanUrl));
  var SubPlanLocal = getAllSubPlanRemote(SubPlanUrl, dayamount);
  return SubPlanLocal;
}

getDayamountRemote(SubPlanUrl) async {
  var response = await http.Client().get(Uri.parse(SubPlanUrl + "index.html"));

  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    var dayamount = document.getElementsByClassName("day").length - 1; // get all with class="day" and subtract 1 because the legend has an element with that class
    return dayamount;
  } else {
    throw Exception();
  }
}

getAllSubPlanRemote(url, dayamount) async {
  print(dayamount);
  List<String> dayurl = List.generate(0, (index) => ''); // Ich weiß nich warum das heir growable ist. bei getSubPlanRemote ists nich so lol
  for (int k = 1; k <= dayamount; k++) {
    String formattedAmount = k.toString().padLeft(3, '0'); // make sure the number is formated in 3 decimals
    var fullUrl = (url + "V_DC_" + formattedAmount + ".html");
    print(fullUrl);
    dayurl.insert(k - 1, fullUrl);
  }
  print(dayurl.length);
  print(dayurl);

  List<List<List<dynamic>>> plans = List.generate(
    0,
    (index1) => List.generate(
      0,
      (index2) => List.generate(
        0,
        (index3) => '',
      ),
    ),
  );

  for (int k = 0; k <= dayurl.length - 1; k++) {
    print("iteration$k");
    print(dayurl[k]);
    plans.insert(k, await getSubPlanRemote(dayurl[k]));
  }
  print(plans);
  return plans;
}

getSubPlanRemote(SubPlanUrl) async {
  //print(SubPlanUrl);
  var response = await http.Client().get(Uri.parse(SubPlanUrl));

  //print(response.statusCode);
  //print(response.body);

  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    //print(document.getElementsByTagName("tr").length);
    var amount = document.getElementsByTagName("tr").length;
    //print(document);

    //print(document.getElementsByTagName("tr")[0].innerHtml);

    var element = document.querySelectorAll('table>tbody')[0];

    var SubPlanLocal = List<List>.generate(amount - 1, (i) => List<dynamic>.generate(7, (index) => null, growable: false), growable: false);

    for (int k = 0; k <= amount - 2; k++) {
      //print("Position: " + k.toString());
      //print(document.getElementsByTagName("tr")[k].innerHtml);
      //var row = document.getElementsByTagName("tr")[k].innerHtml;
      //print(row.getElementsByTagName("td")[k].innerHtml);

      var data = element.querySelectorAll('tr');

      // print(data[k].children[0].text.toString().trim()); // Klasse    --> course
      // print(data[k].children[1].text.toString().trim()); // Pos       --> pos
      // print(data[k].children[2].text.toString().trim()); // Fach      --> subject
      // print(data[k].children[3].text.toString().trim()); // Lehrer    --> teacher
      // print(data[k].children[4].text.toString().trim()); // Raum      --> room
      // print(data[k].children[5].text.toString().trim()); // Art       --> type
      // print(data[k].children[6].text.toString().trim()); // Bemerkung --> remark

      SubPlanLocal[k][0] = data[k].children[0].text.toString().trim();
      SubPlanLocal[k][1] = data[k].children[1].text.toString().trim();
      SubPlanLocal[k][2] = data[k].children[2].text.toString().trim();
      SubPlanLocal[k][3] = data[k].children[3].text.toString().trim();
      SubPlanLocal[k][4] = data[k].children[4].text.toString().trim();
      SubPlanLocal[k][5] = data[k].children[5].text.toString().trim();
      SubPlanLocal[k][6] = data[k].children[6].text.toString().trim();
    }
    // print("richa" + SubPlanLocal.toString());
    return SubPlanLocal;
  } else {
    throw Exception();
  }
}
