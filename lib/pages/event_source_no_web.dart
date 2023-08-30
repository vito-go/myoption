import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/util.dart';

Future<StreamSubscription<dynamic>?> sseProductList(
    void Function(String data) onData) async {
  final dio = Dio();
  ResponseBody? data;
  try {
    Response<ResponseBody> response = await dio.get<ResponseBody>(
      "${Global.apiHost.priceLast}?dataType=json",
      options: Options(
          headers: {
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          },
          responseType: ResponseType.stream,
          sendTimeout:
              const Duration(seconds: 3)), // set responseType to `stream`
    );
    myPrint("--------------==== ${response.data}");
    data = response.data;
  } catch (e) {
    myPrint("--------------====  $e");
    return null;
  }
  if (data == null) return null;
  final listener = data.stream.listen((Uint8List event) {
    // myPrint(event);
    onData(utf8.decode(event));
  }, cancelOnError: true);
  return listener;
}
