import 'package:dh_switch/dh_switch.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DHSwitch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SwitchPage(title: 'DHSwitch Demo'),
    );
  }
}

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              const Text("BorderStyle.solid"),
              DHSwitch(
                  value: value,
                  activeTrackColor: Colors.lightBlueAccent,
                  inactiveTrackColor: Colors.lightBlue,
                  borderColor: Colors.redAccent,
                  switchSize: const SwitchSize(
                      width: 44.0, height: 24.0, borderWidth: 2.0),
                  onChanged: (value) {
                    setState(() => this.value = value);
                  },
                  borderStyle: BorderStyle.solid),
              const SizedBox(height: 30),
              const Text("BorderStyle.none"),
              DHSwitch(
                  value: value,
                  activeTrackColor: Colors.lightGreenAccent,
                  inactiveTrackColor: Colors.lightGreen,
                  borderColor: Colors.yellowAccent,
                  onChanged: (value) {
                    setState(() => this.value = value);
                  },
                  throttleDuration: const Duration(seconds: 1),
                  isFirstRender: false,
                  borderStyle: BorderStyle.none)
            ],
          ),
        ));
  }
}
