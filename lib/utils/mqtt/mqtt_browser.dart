import 'dart:convert';
import 'package:get/utils.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_browser_client.dart';
import '../../type/touPintType.dart';
import './mqtt.dart';

class CustomMqtt extends Mqtt {
  int code;
  void Function() onConnected;
  late MqttBrowserClient client;
  void Function(TouYingData touYingData)? onMessage;
  CustomMqtt({
    required int this.code,
    required this.onConnected,
    this.onMessage,
  }) : super(code:code, onConnected:onConnected,onMessage: onMessage);
  @override
  Future<MqttBrowserClient> connect() async {
    //"ws://mqtt.start237.top/mqtt", "",80
    // "wss://ne.start237.top/mqtt", "",8084
    client = MqttBrowserClient(hostName,"");
    /// Set logging on if needed, defaults to off
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 20;

    /// The ws port for Mosquitto is 8080, for wss it is 8081
    client.port = prot;

    client.keepAlivePeriod = 20;

    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;

    var now = DateTime.now();
    final connMessage = MqttConnectMessage()
    // .authenticateAs(
    // "sgb_app_${now.millisecondsSinceEpoch.toString()}_name",
    // 'emqx_test')
        .startClean();
    // .withWillQos(MqttQos.atLeastOnce);
    // .withWillRetain();
    client.connectionMessage = connMessage;
    try {
      await client.connect();
      client.subscribe("$topic/$code", MqttQos.atMostOnce);

    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return client;
    }

    try{
      client.updates!.listen(onCMessage);
      // client.published!.listen((MqttPublishMessage message) {
      //   print(
      //       '${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      // });

    }catch(e){
      e.printError();
    }


    return client;
  }

  @override
  disconnect(){
    client.disconnect();
  }
  @override
  publishMessage(String json){
    final builder = MqttPayloadBuilder();
    builder.addUTF8String(json);

    client.publishMessage(
        "$topic/$code",
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true
    );
  }

}
