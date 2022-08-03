import 'package:flutter/material.dart';

import 'mqtt2.dart';

Future<void> initMqtt(response) async {
  var res = await Mqtt2.connect();
  print('Mqtt connections: $res');
  await Mqtt2.setSubscribe(['EslamJuba/feeds/welcome-feed'], response);
}

/// message = 0 => Foreword
/// message = 1 => Right
/// message = 2 => Left
void response(String topic, String message) {
  print('topic: $topic, message: $message');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = '';
  @override
  void initState() {
    super.initState();
    initMqtt(response);
  }

  void response(String topic, String msg) {
    if (msg == '0') {
      message = 'foreword';
    } else if (msg == '1') {
      message = 'right';
    } else if (msg == '2') {
      message = 'left';
    }

    print('topic: $topic, message: $msg');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              message,
            ),
          ],
        ),
      ),
    );
  }
}
