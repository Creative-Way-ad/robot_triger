import 'package:flutter/material.dart';

import 'mqtt2.dart';

Future<void> initMqtt(response) async {
  var res = await Mqtt2.connect();
  debugPrint('Mqtt connections: $res');
  await Mqtt2.setSubscribe(['EslamJuba/feeds/welcome-feed'], response);
}

/// message = 0 => Foreword
/// message = 1 => Right
/// message = 2 => Left
void response(String topic, String message) {
  debugPrint('topic: $topic, message: $message');
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
      title: 'Robot App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
    setState(() {
      if (msg == '0') {
        message = 'foreword';
      } else if (msg == '1') {
        message = 'right';
      } else if (msg == '2') {
        message = 'left';
      }
      debugPrint('topic: $topic, message: $msg');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
