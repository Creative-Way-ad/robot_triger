import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_triger/services/mqtt/state/MQTTAppState.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MQTTAppState currentAppState;
  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(),
      body: currentAppState.getReceivedText == '0'
          ? const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image(
                image: AssetImage(
                  'assets/smile-face.gif',
                ),
              ))
          : Container(),
    );
  }
}
