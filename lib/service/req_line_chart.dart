import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:myoption/util/global.dart';
import 'package:myoption/util/util.dart';

import 'model/model.dart';

Future<RespData<ChartLineData>> reqLineChart(
    BuildContext context, String symbolCode) async {
  final dio = Dio();

  Response<Map<String, dynamic>> respBody = await dio.get<Map<String, dynamic>>(
    Global.apiHost.lineChart,
    queryParameters: {"symbolCode": symbolCode},
    options: Options(
        headers: {},
        sendTimeout: const Duration(seconds: 3),
        responseType: ResponseType.json), // set responseType to `stream`
  );
  final Map<String, dynamic>? data = respBody.data;
  if (data == null) return RespData(code: -1);
  return RespData.fromJson(data, ChartLineData.fromJson);
}
