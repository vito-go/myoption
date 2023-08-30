import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/global_event.dart';

import '../pages/event_source_no_web.dart'
    if (dart.library.html) "../pages/event_source_web.dart";
import '../service/model/model.dart';
import 'util.dart';

StreamSubscription? subscriptionSSE;

StreamController<List<Product>> streamController = StreamController.broadcast();

// 如果subscriptionSSE进行cancel，服务器是可以收到结束的通知的
Future<void> initSSS() async {
  await subscriptionSSE?.cancel();
  subscriptionSSE = await sseProductList((String data) {
    final Map<String, dynamic> json = jsonDecode(data);
    if (json['items'] != null) {
      final items = <Product>[];
      json['items'].forEach((v) {
        items.add(Product.fromJson(v));
      });
      streamController.sink.add(items);
    }
  });
  if (subscriptionSSE == null) {
    if (Global.dataNetwork) {
      Global.dataNetwork = false;
      addToGlobalEvent(GlobalEvent(
          eventType: GlobalEventType.dataNetworkChange, param: false));
    }
  } else {
    if (!kIsWeb) {
      // web平台都不返回null
      if (!Global.dataNetwork) {
        Global.dataNetwork = true;
        addToGlobalEvent(GlobalEvent(
            eventType: GlobalEventType.dataNetworkChange, param: true));
      }
    }
  }
  subscriptionSSE?.onError((e) {
    sseOnError();
    myPrint("------- $e --------");
  });
}

Future<void> sseOnError() async {
  await subscriptionSSE?.cancel();
  subscriptionSSE = null;
  myPrint("------------>>>>>> ${Global.dataNetwork}");
  if (Global.dataNetwork) {
    Global.dataNetwork = false; //必须先改变dataNetwork的值才添加事件
    addToGlobalEvent(GlobalEvent(
        eventType: GlobalEventType.dataNetworkChange, param: false));
  }
}
