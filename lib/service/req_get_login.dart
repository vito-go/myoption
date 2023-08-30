// 先去判定登录
import 'package:flutter/cupertino.dart';
import 'package:myoption/service/dio_try.dart';
import 'package:myoption/service/req_get.dart';

import '../util/global.dart';
import 'model/model.dart';

Future<RespData<GenericData<TradeOrder>>> reqOrderList(BuildContext context,
    {required int offset, required int limit}) async {
  final www = Global.apiHost.orderList;
  final queryParameters = <String, dynamic>{
    "offset": offset,
    "limit": limit,
  };
  final header = await loginHeader();
  return dioTryGet(context, www, fromJson: (Map<String, dynamic> json) {
    return GenericData.fromJson(json, (p0) => TradeOrder.fromJson(p0));
  }, queryParameters: queryParameters, header: header);
}

Future<RespData<GenericData<WalletDetail>>> reqWalletDetails(
    BuildContext context,
    {required int offset,
    required int limit}) async {
  final www = Global.apiHost.walletDetails;
  final queryParameters = <String, dynamic>{
    "offset": offset,
    "limit": limit,
  };
  final header = await loginHeader();
  return dioTryGet(context, www, fromJson: (Map<String, dynamic> json) {
    return GenericData.fromJson(json, (p0) => WalletDetail.fromJson(p0));
  }, queryParameters: queryParameters, header: header);
}

Future<RespData<WalletBalance>> reqMyBalance(BuildContext context) async {
  final www = Global.apiHost.myBalance;
  final queryParameters = <String, dynamic>{};
  final header = await loginHeader();
  return dioTryGet(context, www,
      fromJson: WalletBalance.fromJson,
      queryParameters: queryParameters,
      header: header);
}
