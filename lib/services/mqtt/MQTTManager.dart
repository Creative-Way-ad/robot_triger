import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:robot_triger/services/mqtt/state/MQTTAppState.dart';

class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  final String _username = "EslamJuba";
  final String _passwd = "aio_MyMI49ByFeQgfrUBkvyQ02S9fOg6";
  late StreamSubscription _streamSubscription;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager({
    required String host,
    required String topic,
    required String identifier,
    required MQTTAppState state,
  })  : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient.withPort(
      _host,
      _identifier,
      1883,
      maxConnectionAttempts: 50,
    );
    _client!.port = 1883;
    _client!.keepAlivePeriod = 60;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: false);
    _client!.autoReconnect = true;

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(
            _identifier) // If you set this you must set a will message
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    debugPrint('MQTTMANAGER:::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  void connect() async {
    assert(_client != null);
    try {
      debugPrint('MQTTMANAGER:::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect(_username, _passwd);
    } on Exception catch (e) {
      debugPrint('MQTTMANAGER:::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    debugPrint('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    debugPrint('MQTTMANAGER:::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    debugPrint(
        'MQTTMANAGER:::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      debugPrint(
          'MQTTMANAGER:::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    debugPrint('MQTTMANAGER:::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      String topic = recMess.payload.variableHeader!.topicName;

      _currentState.setReceivedText(message);
      debugPrint(
          'MQTTMANAGER:::Change notification:: topic is <${c[0].topic}>, payload is <-- $message -->');
      debugPrint('');
    });
    debugPrint(
        'MQTTMANAGER:::OnConnected client callback - Client connection was sucessful');
  }
}
