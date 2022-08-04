import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;


class Mqtt2 {
  static String broker = "io.adafruit.com";
  static int port = 1883;
  static String username = "EslamJuba";
  static String passwd = "aio_MyMI49ByFeQgfrUBkvyQ02S9fOg6";
  // static String clientIdentifier = randomId().toString();
  static String clientIdentifier = '';
  static double temp = 20;

  static  mqtt.MqttClient? client;
  static late mqtt.MqttConnectionState connectionState;

  static late StreamSubscription subscription;

  static Future<Subscription?> subscribeToTopic(String topic) async {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      return client!.subscribe(topic, mqtt.MqttQos.atMostOnce);
    }
    return null;
  }

  static Future<bool> connect() async {
    try {
      if ((client!.connectionStatus!.state ==
              mqtt.MqttConnectionState.connected ||
          client!.connectionStatus!.state ==
              mqtt.MqttConnectionState.connecting)) {
        return connectToServer();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
    client = MqttServerClient.withPort(broker, clientIdentifier, 1883,
        maxConnectionAttempts: 50);
    client!.port = port;
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    // client.onDisconnected = _onDisconnected;
    return connectToServer();
  }

  static Future<bool> connectToServer() async {
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    try {
      await client!.connect(username, passwd);

      if (client!.connectionStatus!.state ==
          mqtt.MqttConnectionState.connected) {
        connectionState = client!.connectionStatus!.state;

        return true;
      } else {
        disconnect();
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      disconnect();
      return false;
    }
  }

  static void disconnect() {
    client!.disconnect();
    // _onDisconnected();
  }

  void _onDisconnected() {
    // ignore: deprecated_member_use
    connectionState = client!.connectionState!;
    // ignore: unnecessary_null_comparison
    if (subscription != null) subscription.cancel();
    // cubit.changeMqttState(false);
  }

  static Future<void> setSubscribe(
      List<String> subscribeList, Function mqttSetState) async {
    for (var topic in subscribeList) {
      subscribeToTopic(topic);
    }
    subscription =
        client!.updates!.listen((List<mqtt.MqttReceivedMessage> event) {
      onMessage(event, mqttSetState);
    });
  }

  static Future<void> onMessage(
      List<mqtt.MqttReceivedMessage> event, Function mqttSetState) async {
    final mqtt.MqttPublishMessage recMess =
        await event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    String topic = recMess.payload.variableHeader!.topicName;

    mqttSetState(topic, message);
  }

  static bool publish(topic, msg) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);

    try {
      client!.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!,
          retain: false);
      return true;
    } catch (err) {
      // toast('Connection failed');
      return false;
    }
  }
}
