import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final TextEditingController _topicTextController = TextEditingController();

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();
    _hostTextController.text = 'io.adafruit.com';
    _topicTextController.text = 'EslamJuba/feeds/welcome-feed';
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Efada"),
        backgroundColor: const Color(0xff112143),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: currentAppState.getReceivedText == '0'
              ? Colors.black
              : Colors.white,
          height: 640.h,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: currentAppState.getAppConnectionState ==
                              MQTTAppConnectionState.connected
                          ? Colors.green
                          : Colors.grey,
                      child: Text(
                        _prepareStateMessageFrom(
                            currentAppState.getAppConnectionState),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              currentAppState.getReceivedText == '0'
                  ? const SizedBox(
                      width: double.infinity,
                      child: Image(
                        image: AssetImage(
                          'assets/smile-face.gif',
                        ),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          _buildTextFieldWith(
                              _hostTextController,
                              'Enter broker address',
                              currentAppState.getAppConnectionState),
                          SizedBox(height: 10.h),
                          _buildTextFieldWith(
                              _topicTextController,
                              'Enter a topic to subscribe or listen',
                              currentAppState.getAppConnectionState),
                          SizedBox(height: 10.h),
                          _buildConnectButtonFrom(
                              currentAppState.getAppConnectionState)
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWith(
    TextEditingController controller,
    String hintText,
    MQTTAppConnectionState state,
  ) {
    bool shouldEnable = false;
    if ((controller == _hostTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _topicTextController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
      enabled: shouldEnable,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: 0,
          bottom: 0,
          top: 0,
          right: 0,
        ),
        labelText: hintText,
      ),
    );
  }

  Widget _buildConnectButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: const Color(0xff112143),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
            child: Text(
              'Connect',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
            ), //
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Colors.redAccent,
            onPressed:
                state == MQTTAppConnectionState.connected ? _disconnect : null,
            child: Text(
              'Disconnect',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
              ),
            ), //
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
