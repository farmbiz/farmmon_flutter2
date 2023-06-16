import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:farmmon_flutter/zoomable_chart.dart';
import 'package:farmmon_flutter/presentation/resources/app_resources.dart';
import 'package:farmmon_flutter/icons/custom_icons_icons.dart';
import 'package:archive/archive_io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'dart:ffi';
// import 'package:flutter/cupertino.dart';
// import 'package:farmmon_flutter/util/extensions/color_extensions.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:ui';
// import 'package:dio/dio.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

var pp = 0;
var ppfarm = 0;
var farmNo = 1;
var lastDatetime = '';
var updateKey = '';
var MAXX = 24;
var difference = 0;
var statusCode = 0;

var farmName = List<String>.filled(1, '기본농장', growable: true);
var facilityName = List<String>.filled(1, '1번온실', growable: true);
var serviceKey =
    List<String>.filled(1, 'r34df5d2d566049e2a809c41da915adc6', growable: true);

/////////////////////////////////////////////
class Sensor {
  String? customDt;
  double? temperature;
  double? humidity;
  double? cotwo;
  double? leafwet;
  double? gtemperature;
  double? quantum;
  String? xlabel;

  Sensor({
    this.customDt,
    this.temperature,
    this.humidity,
    this.cotwo,
    this.leafwet,
    this.gtemperature,
    this.quantum,
    this.xlabel,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
        customDt: json['custom_dt'],
        temperature: json['temperature'],
        humidity: json['humidity'],
        cotwo: json['cotwo'],
        leafwet: json['leafwet'],
        gtemperature: json['gtemperature'],
        quantum: json['quantum'],
        xlabel: json['xlabel'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['custom_dt'] = customDt;
    data['temperature'] = temperature;
    data['humidity'] = humidity;
    data['cotwo'] = cotwo;
    data['leafwet'] = leafwet;
    data['gtemperature'] = gtemperature;
    data['quantum'] = quantum;
    data['xlabel'] = xlabel;
    return data;
  }
}

/////////////////////////////////////////////

class SensorList {
  List<Sensor>? sensors;
  SensorList({this.sensors});

  factory SensorList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<Sensor> sensors = <Sensor>[];

    sensors = listFromJson.map((sensor) => Sensor.fromJson(sensor)).toList();
    return SensorList(sensors: sensors);
  }
}

///////////////////////////////////////////////////////////

/////////////////////////////////////////////
class PINF {
  String? customDt;
  double? anthracnose;
  double? botrytis;
  String? xlabel;

  PINF({
    this.customDt,
    this.anthracnose,
    this.botrytis,
    this.xlabel,
  });

  factory PINF.fromJson(Map<String, dynamic> json) => PINF(
        customDt: json['custom_dt'],
        anthracnose: json['anthracnose'],
        botrytis: json['botrytis'],
        xlabel: json['xlabel'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['custom_dt'] = customDt;
    data['anthracnose'] = anthracnose;
    data['botrytis'] = botrytis;
    data['xlabel'] = xlabel;
    return data;
  }
}

/////////////////////////////////////////////

class PINFList {
  List<PINF>? pinfs;
  PINFList({this.pinfs});

  factory PINFList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<PINF> pinfs = <PINF>[];

    pinfs = listFromJson.map((pinf) => PINF.fromJson(pinf)).toList();
    return PINFList(pinfs: pinfs);
  }
}

///////////////////////////////////////////////////////////
final today = DateTime.now();
final somedaysago = today.subtract(const Duration(days: 15));
final somedaysagoString = DateFormat('yyyyMMdd HH00').format(somedaysago);

Sensor sensor = Sensor(
  customDt: somedaysagoString,
  temperature: 0.0,
  humidity: 0.0,
  cotwo: 0.0,
  leafwet: 0.0,
  gtemperature: 0.0,
  quantum: 0.0,
  xlabel: " ",
);

var sensorList = List<Sensor>.filled(50, sensor, growable: true);
/////////////////////////////////////////////////////////////
final somedaysagoString2 = DateFormat('yyyy-MM-dd').format(somedaysago);

PINF pinf = PINF(
  customDt: somedaysagoString2,
  anthracnose: 0.0,
  botrytis: 0.0,
  xlabel: " ",
);

var pinfList = List<PINF>.filled(50, pinf, growable: true);

/////////////////////////////////////////////////////////////

Future prefsLoad() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  farmNo = (prefs.getInt('farmNumber') ?? 1);
  ppfarm = (prefs.getInt('myFarm') ?? 0);

  final today = DateTime.now();
  final somedaysago = today.subtract(const Duration(days: 15));
  final somedaysagoString = DateFormat('yyyyMMdd HH00').format(somedaysago);
  lastDatetime = (prefs.getString('lastDatetime') ?? somedaysagoString);

  // prefs.setInt('farmNumber', farmNo);
  // prefs.setInt('myFarm', ppfarm);
  // await prefs.setString('lastDatetime', lastDatetime);
  print("prefs Loading... lastDatetime: $lastDatetime");

  print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

  farmName[0] = (prefs.getString('farmName0') ?? farmName[0]);
  facilityName[0] = (prefs.getString('facilityName0') ?? facilityName[0]);
  serviceKey[0] = (prefs.getString('serviceKey0') ?? serviceKey[0]);

  for (int i = 1; i < farmNo; i++) {
    farmName.add(prefs.getString('farmName$i') ?? farmName[0]);
    facilityName.add(prefs.getString('facilityName$i') ?? facilityName[0]);
    serviceKey.add(prefs.getString('serviceKey$i') ?? serviceKey[0]);
  }
  return 0;
}

Future prefsSave() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('farmNumber', farmNo);

  for (int i = 0; i < farmNo; i++) {
    await prefs.setString('farmName$i', farmName[i]);
    await prefs.setString('facilityName$i', facilityName[i]);
    await prefs.setString('serviceKey$i', serviceKey[i]);
  }
  await prefs.setInt('myFarm', ppfarm);
  print('prefs Save: ${(ppfarm + 1)} / $farmNo');
}

void prefsClear() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // print('prefs clear $farmNo');
  prefs.clear();
  if (farmNo > 1) {
    farmName.removeRange(1, farmNo);
    facilityName.removeRange(1, farmNo);
    serviceKey.removeRange(1, farmNo);
  }
  farmNo = 1;
  ppfarm = 0;
  final today = DateTime.now();
  final somedaysago = today.subtract(const Duration(days: 15));
  lastDatetime = DateFormat('yyyyMMdd HH00').format(somedaysago);
  sensorList = List<Sensor>.filled(50, sensor, growable: true);
  String jsonString = jsonEncode(sensorList);
  await writeJsonAsString('sensor.json', jsonString);

  pinfList = List<PINF>.filled(50, pinf, growable: true);
  jsonString = jsonEncode(pinfList);
  await writeJsonAsString('pinf.json', jsonString);

  print('prefs cleared: only $farmNo farm left');
}

/////////////////////////////////////////////////////////////////////
Future readJsonAsString() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents');
    // print('${dir.path}/sensor.json');
    print('read json file');
    var routeFromJsonFile =
        await File('${dir.path}/sensor.json').readAsString();
    sensorList = (SensorList.fromJson(routeFromJsonFile).sensors ?? <Sensor>[]);
    routeFromJsonFile = await File('${dir.path}/pinf.json').readAsString();
    pinfList = (PINFList.fromJson(routeFromJsonFile).pinfs ?? <PINF>[]);
  } catch (e) {
    return 0;
  }
}

Future<File> writeJsonAsString(String? file, String? data) async {
  // final file = File('json/sensor.json');
  final dir = await getApplicationDocumentsDirectory();
  // Directory dir = Directory('/storage/emulated/0/Documents');
  // print('${dir.path}/sensor.json');
  print('writing json file: $file');
  if (Platform.isAndroid) showToast("파일을 저장했습니다");
  // notifyListeners();
  return File('${dir.path}/$file').writeAsString(data ?? '');
  // return file.writeAsString(data ?? '');
}

/////////////////////////////////////////////////////////////

showToast(String message) {
  return Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.blueAccent,
    fontSize: 20,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}
/////////////////////////////////////////////////////////////

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // prefsLoad();
  HttpOverrides.global = MyHttpOverrides();
  // lastDatetime = sensorList[0].customDt.toString();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FarmMon App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var user_msg = '';
  // var farmNoUpdate = farmNo;

  Future apiRequestIOT() async {
    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = serviceKey[ppfarm];

    // IOT portal data update
    var now = DateTime.now();
    lastDatetime = sensorList[0].customDt.toString();
    lastDatetime = "${lastDatetime.substring(0, 11)}0000";

    difference = int.parse(
        now.difference(DateTime.parse(lastDatetime)).inHours.toString());
    print('Difference: $difference');
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);

    var urliotString = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliotString);

    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + deltaT12;

    // print('before for loop');
    for (int i = 0; i < difference; i++) {
      String formatDate = DateFormat('yyyyMMdd').format(now);
      String formatTime = DateFormat('HH').format(now);
      urliotString = "$urliot/$apikey/$formatDate/$formatTime";

      ///print(urliot2);

      HttpClient().idleTimeout = const Duration(seconds: 10);

      uriiot = Uri.parse(urliotString);
      http.Response response = await http.get(uriiot);
      now = now.subtract(Duration(hours: 1));
      // print(response.body);
      statusCode = response.statusCode;

      var jsonObj = jsonDecode(response.body);
      var custom_dt = jsonObj['datas'][0]['custom_dt'].toString();
      custom_dt = DateFormat('yyyyMMdd HH00').format(DateTime.parse(custom_dt));

      Sensor nsensor = Sensor(
        customDt: custom_dt,
        temperature: double.parse(jsonObj['datas'][0]['temperature']),
        humidity: double.parse(jsonObj['datas'][0]['humidity']),
        cotwo: double.parse(jsonObj['datas'][0]['cotwo']),
        leafwet: double.parse(jsonObj['datas'][0]['leafwet']),
        gtemperature: double.parse(jsonObj['datas'][0]['gtemperature']),
        quantum: double.parse(jsonObj['datas'][0]['quantum']),
        xlabel: DateFormat('HH:mm').format(
          DateTime.parse(jsonObj['datas'][0]['custom_dt']),
        ),
      );

      // sensorList.insert(0, nsensor);
      sensorList.insert(i, nsensor);
      print('$i----${nsensor.customDt}');
      var progress = ((i + 1) / difference) * 100;
      user_msg = "${progress.toStringAsFixed(0)}%";
      notifyListeners();
    }
    // print('after for loop');
    // print(statusCode);
    user_msg = "$statusCode";
    notifyListeners();
    return statusCode;
  }

  Future apiRequestPEST() async {
    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();

    var k = 0;
    for (k = 0; k < 24; k++) {
      var v1 = sensorList[k].customDt.toString();
      var d1 = DateTime.parse(v1);
      String formatTime = DateFormat('HH').format(d1);
      if (formatTime == '12') break;
    }
    var weatherString = 'datetime,temperature,humidity,leafwet\n';
    for (int j = (k + 336); j >= 0; j--) {
      var v1 = sensorList[j].customDt.toString();
      var v2 = sensorList[j].temperature.toString();
      var v3 = sensorList[j].humidity.toString();
      var v4 = sensorList[j].leafwet.toString();
      weatherString = "$weatherString$v1,$v2,$v3,$v4\n";
    }
    // print(weatherString);
    (File('${dir.path}/weather.csv').writeAsString(weatherString))
        .then((value) {
      encoder.create('${dir.path}/input.zip');
      encoder.addFile(File('${dir.path}/weather.csv'));
      encoder.close();
    });

    // zip weather.csv
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);

    var body = jsonEncode({
      'Input': token,
      'type': "file",
    });

    // http request
    var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urlbotrytis = 'http://147.46.206.95:7898/Botrytis';

    http.Response response = await http.post(
      Uri.parse(urlanthracnose),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: body,
    );

    var r = response.body;
    r = r.replaceAll("\\", "");
    var i = r.indexOf('output');
    var ii = r.indexOf("}}");
    var rr = r.substring(i + 10, ii + 2);
    final outputA = json.decode(rr);

    http.Response response2 = await http.post(
      Uri.parse(urlbotrytis),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: body,
    );

    var r2 = response2.body;
    r = r2.replaceAll("\\", "");
    var i2 = r.indexOf('output');
    var ii2 = r.indexOf("}}");
    var rr2 = r.substring(i2 + 10, ii2 + 2);
    final outputB = json.decode(rr2);

    // print(output.runtimeType);

    //////////////////////////////////////////////////////
/////////////////////////////////////////////////////
    int j = 14;
    for (int i = 0; i < 14; i++) {
      var custom_dt = outputA['$j']['date'].toString();

      PINF npinf = PINF(
        customDt: custom_dt,
        anthracnose: outputA['$j']['PINF'],
        botrytis: outputB['$j']['PINF'],
        xlabel: DateFormat('MM/dd').format(
          DateTime.parse(outputA['$j']['date']),
        ),
      );
      j--;
      pinfList.insert(i, npinf);

      // print('$j: $custom_dt');
    }

    return 0;
  }

  Future getAPI() async {
    // current = WordPair.random();
    // farmNoUpdate = farmNo;
    await apiRequestIOT().then((value) {
      notifyListeners();
    });
    return 0;
  }

  Future<void> getSensorList() async {
    // current = WordPair.random();
    notifyListeners();
  }

  void getData() {
    notifyListeners();
  }

  void getNext() {
    // current = WordPair.random();
    // farmNoUpdate = farmNo;
    notifyListeners();
  }

  void toggleFavorite() {
    // if (favorites.contains(current)) {
    //   favorites.remove(current);
    // } else {
    //   favorites.add(current);
    // }
    notifyListeners();
  }
}

/////////////////////////////////////////////////////////////////////

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    prefsLoad().then((value) {
      readJsonAsString().then((value) {
        setState(() {
          lastDatetime = sensorList[0].customDt.toString();
          lastDatetime = "${lastDatetime.substring(0, 11)}0000";
          print(lastDatetime);
          print('farmNo at initState: $farmNo');
        });
      });
    });
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (selectedIndex) {
      case 0:
        // appState.farmNoUpdate = farmNo;
        // print('farmNo update:  ${appState.farmNoUpdate}');
        page = StrawberryPage();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = MyLineChartPage();
        break;
      case 4:
        // appState.farmNoUpdate = farmNo;
        // print('farmNo update:  ${appState.farmNoUpdate}');
        page = MySetting();
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                ///                extended: constraints.maxWidth >= 600,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.strawberry), //solidLemon
                    label: Text('딸기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.tomato), //solidLemon
                    label: Text('토마토'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.bellpepper), //solidLemon
                    label: Text('파프리카'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.thermostat),
                    label: Text('환경'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('설정'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  if (mounted) {
                    setState(() {
                      selectedIndex = value;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class StrawberryPage extends StatefulWidget {
  @override
  State<StrawberryPage> createState() => _StrawberryPageState();
}

class _StrawberryPageState extends State<StrawberryPage> {
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
  // @override
  // void didChangeDependencies() {
  //   print('didChangeDependencies 호출');
  //   updateKey = DateTime.now().toString();
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    // callAPI();

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    // var now = DateTime.now();
    // String formatDate = DateFormat('yyyy년 MM월 dd일').format(now);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmName[ppfarm],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

                  // appState.callAPI();

                  await appState.getAPI().then((value) {
                    setState(() {
                      lastDatetime = sensorList[0].customDt.toString();
                      lastDatetime = "${lastDatetime.substring(0, 11)}0000";
                      print(lastDatetime);
                    });
                  });
                  await appState.apiRequestPEST().then((value) {});

                  // appState.getAPI().then((value) {
                  // });
                  // Future.delayed(const Duration(milliseconds: 1000), () {
                  // if (mounted) {
                  setState(() {
                    pp = 0;
                    appState.getNext();
                    // print('after 1000 milliseconds');
                    // });
                    // }
                  });
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('탄저병:'),
              Text(
                '■',
                style: TextStyle(
                  color: Colors.amber,
                ),
              ),
              SizedBox(width: 10),
              Text('잿빛곰팡이병:'),
              Text(
                '■',
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          Expanded(
            child: MyBarChart(),
          ),
          // Text(lastDatetime),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  pp = 7;
                  appState.toggleFavorite();
                },
                child: Text('지난주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  backgroundColor: Colors.blueGrey, // Text Color
                ),
                onPressed: () async {
                  pp = 0;
                  // appState.callAPI();
                  if (Platform.isAndroid) showToast("IOT포털에서 데이터를 가져옵니다");

                  await appState.getAPI().then((value) {
                    if (Platform.isAndroid) showToast("병해충 발생위험도를 계산합니다");
                    appState.apiRequestPEST().then((value) {
                      // print(difference);
                      // print(statusCode);
                      // print(pp);
                      setState(() {
                        lastDatetime = sensorList[0].customDt.toString();
                        lastDatetime = "${lastDatetime.substring(0, 11)}0000";
                        print(lastDatetime);

                        if ((difference >= 0)) {
                          //(statusCode == 200) &&
                          String jsonString = jsonEncode(sensorList);
                          writeJsonAsString('sensor.json', jsonString);
                          jsonString = jsonEncode(pinfList);
                          writeJsonAsString('pinf.json', jsonString);
                          if (Platform.isAndroid) showToast("파일에 데이터를 저장합니다");

                          // SharedPreferences prefs = await SharedPreferences.getInstance();
                          // lastDatetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(nowtosave);

                          lastDatetime = sensorList[0].customDt.toString();
                          lastDatetime = "${lastDatetime.substring(0, 11)}0000";

                          // await prefs.setString('lastDatetime', lastDatetime);
                          // print("prefs Save lastDatetime $lastDatetime");
                        }
                      });
                    });
                    // print('after data update procedure... ');
                    // updateKey = DateTime.now().toString();

                    // var temp = sensorList[0].temperature;
                    // sensorList[0].temperature = temp;

                    if (mounted) {
                      setState(() {
                        appState.getNext();
                      });
                    }
                  });
                },
                child: Text('이번주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  pp = 0;
                  // await apiRequestPEST().then((value) {
                  if (mounted) {
                    setState(() {
                      appState.getNext();
                    });
                  }
                  // });
                },
                child: Text('다음주'),
              ),
              SizedBox(width: 10),
              Text(appState.user_msg),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MyLineChartPage extends StatefulWidget {
  const MyLineChartPage({super.key});

  @override
  State<MyLineChartPage> createState() => _MyLineChartPageState();
}

class _MyLineChartPageState extends State<MyLineChartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmName[ppfarm],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

                  if (mounted) {
                    setState(() {
                      pp = 0;
                    });
                  }
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: MyLineChart(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "예측결과",
          style: style,
          semanticsLabel: "탄저병 예측 결과 차트",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (int i = 1; i <= 5; i++) // var pair in appState.favorites
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('공주농가$i'), // ${pair.asLowerCase}
          ),
      ],
    );
  }
}

class MyBarChart extends StatefulWidget {
  const MyBarChart({super.key});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  @override
  void initState() {
    super.initState();
    print('Bar Chart initState 호출');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      // implement the bar chart
      child: BarChart(
        // key: ValueKey(sensorList[0].customDt),
        // key: ValueKey(updateKey),
        BarChartData(
          maxY: 1,
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          // add bars
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 6].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 6].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 5].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 5].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 4].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 4].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 3].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 3].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 2].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 2].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 1].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 1].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 0].anthracnose.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(pinfList[pp + 0].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
          ],
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, titleMeta) {
                  return Padding(
                    // You can use any widget here
                    padding: EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: getTitles(value, titleMeta),
                    ),
                  );
                },
                reservedSize: 47,
                // interval: 12,
              ),
            ),
          ),
        ),
        swapAnimationDuration: Duration(milliseconds: 300), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      ///      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = pinfList[pp + 7].xlabel.toString();
        break;
      case 1:
        text = pinfList[pp + 6].xlabel.toString();
        break;
      case 2:
        text = pinfList[pp + 5].xlabel.toString();
        break;
      case 3:
        text = pinfList[pp + 4].xlabel.toString();
        break;
      case 4:
        text = pinfList[pp + 3].xlabel.toString();
        break;
      case 5:
        text = pinfList[pp + 2].xlabel.toString();
        break;
      case 6:
        text = pinfList[pp + 1].xlabel.toString();
        break;
      case 7:
        text = pinfList[pp + 0].xlabel.toString();
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }
}

class MyLineChart extends StatefulWidget {
  const MyLineChart({super.key});

  @override
  State<MyLineChart> createState() => _MyLineChartState();
}

class _MyLineChartState extends State<MyLineChart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      // implement the bar chart
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ZoomableChart(
          maxX: MAXX.toDouble() - 1,
          builder: (minX, maxX) {
            return LineChart(
              LineChartData(
                clipData: FlClipData.all(),
                minX: minX,
                maxX: maxX,
                maxY: 100,
                minY: 1,
                borderData: FlBorderData(
                    border: const Border(
                  top: BorderSide.none,
                  right: BorderSide(width: 1),
                  left: BorderSide(width: 1),
                  bottom: BorderSide(width: 1),
                )),
                // groupsSpace: 10,
                // add bars
                lineTouchData:
                    // LineTouchData(enabled: false),
                    LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    maxContentWidth: 100,
                    tooltipBgColor: Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final multiplyer = [0.5, 1, 10];
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors[0] ??
                              touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return LineTooltipItem(
                          ' ${(touchedSpot.y * multiplyer[touchedSpot.barIndex]).toStringAsFixed(1)} ',
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
                                    .temperature
                                    .toString()) *
                                2)
                    ],

                    isCurved: true,
                    color: AppColors.contentColorRed,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
                                .humidity
                                .toString()))
                    ],
                    isCurved: true,
                    color: AppColors.contentColorBlue,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
                                    .cotwo
                                    .toString()) /
                                10)
                    ],
                    isCurved: true,
                    color: AppColors.contentColorBlack,
                    gradient: LinearGradient(colors: gradientColors),
                    barWidth: 0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      // color: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                    ),
                  ),
                ],

                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: getTitles2(value, titleMeta),
                        );
                      },
                      reservedSize: 38,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: getTitles3(value, titleMeta),
                        );
                      },
                      reservedSize: 38,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 57,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: getTitles(value, titleMeta),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              swapAnimationDuration: Duration(milliseconds: 250), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            );
          },
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      // color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    text = sensorList[pp + (MAXX - value.toInt() - 1)].xlabel.toString();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget getTitles2(double value, TitleMeta meta) {
    final stylered = TextStyle(
      color: Colors.redAccent,
      // color: AppColors.contentColorBlue,
      // fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value ~/ 2}', style: stylered),
    );
  }

  Widget getTitles3(double value, TitleMeta meta) {
    final styleblue = TextStyle(
      color: Colors.blueAccent,
      // color: AppColors.contentColorBlue,
      // fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(value.toStringAsFixed(0), style: styleblue),
    );
  }
}

class MySetting extends StatefulWidget {
  const MySetting({Key? key}) : super(key: key);

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  TextEditingController inputController3 = TextEditingController();
  // String inputText = '';
  // String text = 'first';

  @override
  void initState() {
    prefsLoad();
    print('farmNo at initState: $farmNo');
    super.initState();
    // Start listening to changes.
    inputController1.addListener(_printLatestValue);
    inputController2.addListener(_printLatestValue);
    inputController3.addListener(_printLatestValue);

    inputController1.text = farmName[ppfarm];
    inputController2.text = facilityName[ppfarm];
    inputController3.text = serviceKey[ppfarm];
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    inputController1.dispose();
    inputController2.dispose();
    inputController3.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print('첫번째 텍스트필드: ${inputController1.text}');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // appState.farmNoUpdate = farmNo;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('농장정보 입력'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    controller: inputController1,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '농가를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   farmName[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: farmName[ppfarm],
                      hintText: '농가를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    controller: inputController2,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '센서위치를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   facilityName[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: facilityName[ppfarm],
                      hintText: '센서위치를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    key: Key(farmName[ppfarm]),
                    controller: inputController3,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '인증키를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   serviceKey[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: serviceKey[ppfarm],
                      hintText: '데이터저장소 인증키를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('총 $farmNo농가가 등록되었습니다!!!'),
                ),
                Text('선택농가: ${ppfarm + 1} - 이름: ${farmName[ppfarm]}'),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('$ppfarm / $farmNo');
                          farmNo++;
                          print('$ppfarm / $farmNo');

                          farmName.add('추가농가$farmNo');
                          facilityName.add('');
                          serviceKey.add('');

                          if (mounted) {
                            setState(() {
                              ppfarm = farmNo - 1;
                              // print(ppfarm);
                              // for (int i = 0; i < farmNo; i++) {
                              // print(farmName[i]);
                              // }
                              inputController1.text = '추가농가$farmNo';
                              inputController2.text = '';
                              inputController3.text = '';
                            });
                          }
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('farmNumber', farmNo);
                          await prefs.setInt('myFarm', ppfarm);
                        },
                        child: const Text('농장추가'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // save prefs info of the new farm
                          // _printLatestValue();
                          farmName[ppfarm] = inputController1.text;
                          facilityName[ppfarm] = inputController2.text;
                          serviceKey[ppfarm] = inputController3.text;
                          // go to the next farm
                          ppfarm = (ppfarm + 1) % farmNo;

                          prefsSave();

                          if (mounted) {
                            setState(() {
                              // _printLatestValue();
                              inputController1.text = farmName[ppfarm];
                              inputController2.text = facilityName[ppfarm];
                              inputController3.text = serviceKey[ppfarm];
                              // print('next farm: ${(ppfarm + 1)} / $farmNo');
                            });
                          }
                        },
                        child: const Text('다음'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mounted) {
                            setState(() {
                              // _printLatestValue();
                              prefsClear();
                            });
                          }
                        },
                        child: const Text('리셋'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
