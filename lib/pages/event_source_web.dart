import 'dart:async';
import 'dart:html';

import 'package:myoption/util/init_sse.dart';
import 'package:myoption/util/util.dart';

import '../util/global.dart';
import '../util/global_event.dart';

EventSource? eventSource;

Future<StreamSubscription<dynamic>?> sseProductList(
    void Function(String data) onData) async {
  // in browsers, you need to pass a http.BrowserClient:
  // todo 服务端适配协议
  eventSource?.close();
  try {
    eventSource = EventSource("${Global.apiHost.priceLast}?dataType=text");
  } catch (e) {
    myPrint("-------- $e");
    return null;
  }
  eventSource?.onError.listen((Event event) {
    myPrint("----================----------  ${event.type} ${event.path}");
    eventSource?.close();
    sseOnError();
  });
  eventSource?.onOpen.listen((Event event) {
    myPrint("----========open========----------  ${event.type} ${event.path}");
    Global.dataNetwork = true;
    addToGlobalEvent(
        GlobalEvent(eventType: GlobalEventType.dataNetworkChange, param: true));
  });

  final listener = eventSource?.onMessage.listen((MessageEvent event) {
    onData(event.data);
  }, onError: (e) {
    myPrint("-------->>> $e");
  }, cancelOnError: true);
  // window.alert("SSE链接成功");
  return listener;
}
