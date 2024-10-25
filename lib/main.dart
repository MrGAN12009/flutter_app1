import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Apple Style App',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: FirstScreen(),
    );
  }
}

// First Screen
class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Welcome'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PageView(
                children: [
                  Image.asset('assets/images/png1.png'),
                  Image.asset('assets/images/png2.png'),
                  Image.asset('assets/images/png3.png'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Как работает приложение?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1) Выбираете субъект в котором проживаете.\n'
                      '2) Выбираете ваш город.\n'
                      '3) Выбираете тему которая Вас интересует.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    CupertinoButton.filled(
                      child: Text('Далее'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => SecondScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Второй экран
class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  Map<String, dynamic> rawData = {};
  List<String> firstLevelOptions = [];
  List<String> secondLevelOptions = [];
  List<dynamic> thirdLevelOptions = [];

  String? selectedSubject;
  String? selectedCity;
  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    fetchRegions();
  }

  Future<void> fetchRegions() async {
    final response = await http.get(Uri.parse('http://192.168.0.88:8000/regions'));
    if (response.statusCode == 200) {
      setState(() {
        rawData = json.decode(response.body) as Map<String, dynamic>;
        firstLevelOptions = rawData.keys.toList();
      });
    } else {
      throw Exception('Failed to load regions');
    }
  }

  void _showSelectionMenu(BuildContext context, List<String> options, Function(String) onSelected) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: options.map((option) {
          return CupertinoActionSheetAction(
            child: Text(option),
            onPressed: () {
              Navigator.pop(context);
              onSelected(option);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Функция для показа предупреждающего сообщения
  void _showWarningDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Необходимо заполнить все поля"),
        content: Text("Пожалуйста, выберите субъект, город и тему обращения."),
        actions: [
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Написать обращение'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Написать обращение',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Чтобы тебя услышали',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                child: Text(selectedSubject ?? 'Выберите ваш субъект'),
                onPressed: () {
                  if (firstLevelOptions.isNotEmpty) {
                    _showSelectionMenu(context, firstLevelOptions, (String selection) {
                      setState(() {
                        selectedSubject = selection;
                        selectedCity = null;
                        selectedTopic = null;
                        secondLevelOptions = (rawData[selectedSubject] as Map<String, dynamic>).keys.toList();
                      });
                    });
                  }
                },
              ),
              CupertinoButton(
                child: Text(selectedCity ?? 'Выберите ваш город'),
                onPressed: () {
                  if (secondLevelOptions.isNotEmpty) {
                    _showSelectionMenu(context, secondLevelOptions, (String selection) {
                      setState(() {
                        selectedCity = selection;
                        selectedTopic = null;
                        thirdLevelOptions = rawData[selectedSubject][selectedCity] as List<dynamic>;
                      });
                    });
                  }
                },
              ),
              CupertinoButton(
                child: Text(selectedTopic ?? 'Выберите тему обращения'),
                onPressed: () {
                  if (thirdLevelOptions.isNotEmpty) {
                    _showSelectionMenu(context, thirdLevelOptions.map((e) => e.toString()).toList(), (String selection) {
                      setState(() {
                        selectedTopic = selection;
                      });
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                child: Text('Далее'),
                onPressed: () {
                  if (selectedSubject != null && selectedCity != null && selectedTopic != null) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ResultScreen(
                          selectedSubject: selectedSubject!,
                          selectedCity: selectedCity!,
                        ),
                      ),
                    );
                  } else {
                    _showWarningDialog(); // Показываем предупреждение
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Third Screen
class ResultScreen extends StatelessWidget {
  final String selectedSubject;
  final String selectedCity;

  ResultScreen({
    required this.selectedSubject,
    required this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Скопируйте адреса'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Скопируйте электронные адреса',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'И направьте через личную почту',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Вы выбрали:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Субъект РФ: $selectedSubject\nГород: $selectedCity',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
