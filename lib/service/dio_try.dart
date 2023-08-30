import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:myoption/util/util.dart';

import 'model/model.dart';

Future<RespData<T>> dioTryGet<T>(
  BuildContext? context,
  String www, {
  Map<String, dynamic>? queryParameters,
  required T Function(Map<String, dynamic> json) fromJson,
  Duration sendTimeout = const Duration(seconds: 3),
  Duration receiveTimeout = const Duration(seconds: 5),
  Map<String, dynamic>? header,
}) async {
  final dio = Dio();
  try {
    Response<Map<String, dynamic>> respBody =
        await dio.get<Map<String, dynamic>>(
      www,
      options: Options(
        headers: header,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        responseType: ResponseType.json,
      ), // set responseType to `stream`
      queryParameters: queryParameters,
    );
    if (respBody.statusCode != 200) {
      return RespData(code: -1);
    }
    final Map<String, dynamic>? respData = respBody.data;
    if (respData == null) return RespData(code: -1);
    return RespData.fromJson(respData, fromJson);
  } catch (e) {
    return RespData(code: -1);
  } finally {
    dio.close(force: true);
  }
}
