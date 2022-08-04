import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';

  void setReceivedText(String text) {
    _receivedText = text;
    notifyListeners();
  }
  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

}
