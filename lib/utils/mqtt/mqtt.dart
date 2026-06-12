import 'package:flutter/services.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'dart:convert';
import '../../type/touPintType.dart';
class Mqtt {
  int code;
  String topic = "topic/sgb";
  void Function() onConnected;
  String hostName = 'ws://ne.start237.top/mqtt';
  int prot = 8083;
  void Function(TouYingData touYingData)? onMessage;
  Mqtt({
    required int this.code,
    required this.onConnected,
    required this.onMessage,
  });

  connect() {}

  publishMessage(String json){

  }
// 设置连接码
  setCode(int code){
    this.code = code;
  }

// 连接断开
  void onDisconnected() {
    print('Disconnected');
  }

// 订阅主题成功
  void onSubscribed(MqttSubscription subscription) {
    print('主题订阅成功 topic: $topic/$code');
  }



// 订阅主题失败
  void onSubscribeFail(MqttSubscription subscription) {
    print('订阅主题失败 $topic');
  }

// 成功取消订阅
  void onUnsubscribed(cb) {
    print('成功取消订阅: ');
  }

// 收到 PING 响应
  void pong() {
    print('收到 PING 响应');
  }

  disconnect(){}

  MqttPayloadBuilder get builder {
     return MqttPayloadBuilder();
  }

  // 接收消息
  onCMessage(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    MqttHeader header = recMess.header as MqttHeader;
    print("header-->${header.toString()}");
    //换成
    String pt = Utf8Decoder().convert(recMess.payload.message!);
    // print(
    // '<${c[0].topic}>, payload is <-- $pt -->');
    dynamic json = jsonDecode(pt);
    TouYingData touYingData = TouYingData.fromJson(json);
    // print(touYingData.username);
    if(this.onMessage!=null){
      this.onMessage!(touYingData);
    }


  }
  // 加载默认模板数据
  static Future<TouYingData> loadDefaultTmp() async {
    var str = await rootBundle.loadString('lib/json/ty_default_tmp.json');
    dynamic json = jsonDecode(str);
    return TouYingData.fromJson(json);

  }

}
