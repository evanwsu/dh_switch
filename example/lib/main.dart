import 'package:dh_switch/dh_switch.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DHSwitch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SwitchPage(title: 'DHSwitch Demo'),
    );
  }
}

class SwitchPage extends StatefulWidget {
  SwitchPage({Key? key, required this.title}) : super(key: key);

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
              SizedBox(height: 80),
              Text("BorderStyle.solid"),
              DHSwitch(
                  value: value,
                  activeTrackColor: Colors.lightBlueAccent,
                  inactiveTrackColor: Colors.lightBlue,
                  borderColor: Colors.redAccent,
                  switchSize:
                      SwitchSize(width: 44.0, height: 24.0, borderWidth: 2.0),
                  onChanged: (value) {
                    setState(() => this.value = value);
                  },
                  borderStyle: BorderStyle.solid),
              SizedBox(height: 30),
              Text("BorderStyle.none"),
              DHSwitch(
                  value: value,
                  activeTrackColor: Colors.lightGreenAccent,
                  inactiveTrackColor: Colors.lightGreen,
                  borderColor: Colors.yellowAccent,
                  onChanged: (value) {
                    setState(() => this.value = value);
                  },
                  borderStyle: BorderStyle.none)
            ],
          ),
        ));
  }
}
