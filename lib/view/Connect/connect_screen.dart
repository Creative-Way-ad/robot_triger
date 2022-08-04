import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_triger/services/mqtt/MQTTManager.dart';
import 'package:robot_triger/services/mqtt/state/MQTTAppState.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Efada"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.deepOrangeAccent,
                  child: Text(
                    _prepareStateMessageFrom(appState.getAppConnectionState),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                _buildTextFieldWith(
                    _hostTextController,
                    'io.adafruit.com',
                    'Enter broker address',
                    currentAppState.getAppConnectionState),
                const SizedBox(height: 10),
                _buildTextFieldWith(
                    _topicTextController,
                    'EslamJuba/feeds/welcome-feed',
                    'Enter a topic to subscribe or listen',
                    currentAppState.getAppConnectionState),
                const SizedBox(height: 10),
                _buildConnectButtonFrom(currentAppState.getAppConnectionState)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              20.0,
            ),
            child: Center(
              child: Text(
                _prepareRobotState(
                  currentAppState.getReceivedText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWith(
    TextEditingController controller,
    String? defaultValue,
    String hintText,
    MQTTAppConnectionState state,
  ) {
    if (defaultValue != null) {
      controller.text = defaultValue;
    }
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _topicTextController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildConnectButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.lightBlueAccent,
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
            child: const Text('Connect'), //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.redAccent,
            onPressed:
                state == MQTTAppConnectionState.connected ? _disconnect : null,
            child: const Text('Disconnect'), //
          ),
        ),
      ],
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  // Utility functions
  String _prepareRobotState(String msg) {
    switch (msg) {
      case '0':
        return 'foreword';
      case '1':
        return 'right';
      case '2':
        return 'left';
    }
    return 'MSG : $msg';
  }

  void _configureAndConnect() {
    // TODO: Use UUID
    String id = '';
    manager = MQTTManager(
      host: _hostTextController.text,
      topic: _topicTextController.text,
      identifier: id,
      state: currentAppState,
    );
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }
}
