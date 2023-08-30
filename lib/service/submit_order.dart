import 'dart:convert';

import 'package:flutter/cupertino.dart';
 import 'package:myoption/service/req_post.dart';

import 'package:myoption/widgets/types.dart';

import '../util/global.dart';
import 'model/model.dart';

// 先去判定登录
Future<RespData> reqSubmitOrder(BuildContext context,
    {required String symbolCode,
    required double strikePrice,
    required Option option,
    required int betMoney,
    required Session session}) async {
  final www = Global.apiHost.submitOrder;
  final Map<String, dynamic> reqBodyData = {
    "symbolCode": symbolCode,
    "strikePrice": strikePrice,
    "betMoney": betMoney,
    "option": option.value,
    "session": session.value,
  };
  final reqBodyBytes = utf8.encode(jsonEncode(reqBodyData));
  return reqPost(context, www: www, reqBodyBytes: reqBodyBytes);
}
