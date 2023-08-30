//type submitOrderParam struct {
// 	SymbolCode  string        `json:"symbolCode,omitempty"`
// 	StrikePrice float64       `json:"strikePrice,omitempty"`
// 	Option      mtype.Option  `json:"option,omitempty"`
// 	BetMoney    int64         `json:"betMoney,omitempty"`
// 	Session     mtype.Session `json:"session,omitempty"`
// }

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:myoption/service/req_get.dart';
import 'package:myoption/util/sstorage/sstorage.dart';

import '../util/global.dart';
import '../util/util.dart';
import 'model/model.dart';

// 先去判定登录
Future<RespData> reqPost(BuildContext context,
    {required String www, required List<int> reqBodyBytes}) async {
  final dio = Dio();
  final userId = Global.getCurUserId;
  if (userId == "") return RespData(code: -1, message: "用户未登录");
  final UserLoginInfo? userLoginInfo = await ss.getUserLoginInfo(userId);
  if (userLoginInfo == null) return RespData(code: -1, message: "用户未登录");
  final sharedKeyBytes = userLoginInfo.sharedKeyBytes;
  final IV = randomBytes();
  final encBody = await aesCtr256bitsWithKey(
      key: sharedKeyBytes, iv: IV, data: reqBodyBytes);
  final Map<String, dynamic>? header =
      await loginHeader(reqBodyBytes: reqBodyBytes,IV: IV);
  if (header == null) return RespData(code: -1, message: "用户未登录");
  final Options options = Options(
    headers: header,
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 3),
    responseType: ResponseType.json,
  );
  final Response<Map<String, dynamic>> response =
      await dio.post(www, data: base64Encode(encBody), options: options);

  if (response.statusCode == 200) {
    final responseData = response.data;
    if (responseData == null) return RespData.error();
    if (responseData["code"] != 0) {
      myToast(context, responseData["message"]);
      return RespData(
          code: responseData["code"], message: responseData['message']);
    }
    return RespData(
        code: responseData["code"],
        message: responseData['message'],
        data: responseData['data']);
  }
  myPrint("www: $www  statusCode: ${response.statusCode}");
  return RespData.error();
}
