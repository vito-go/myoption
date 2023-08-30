import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myoption/util/sstorage/sstorage.dart';

import '../util/compute_25519.dart';
import '../util/global.dart';
import '../util/util.dart';

// 先去判定登录
Future<Map<String, dynamic>?> loginHeader(
    {UserLoginInfo? userLoginInfo,
    List<int>? reqBodyBytes,
    List<int>? IV}) async {
  final userId = Global.getCurUserId;
  if (userId == "") return null;

  if (userLoginInfo == null) {
    userLoginInfo = await ss.getUserLoginInfo(userId);
    if (userLoginInfo == null) return null;
  }

  final sharedKeyBytes = userLoginInfo.sharedKeyBytes;
  final xClientPubkey = userLoginInfo.x25519PubKey;
  final xClientSignPubkey = userLoginInfo.ed25519PubKey;
  final xTime = Global.now().millisecondsSinceEpoch;
  final serverPubKeyNoMix = xTime ^ Global.serverPubKeyNo;
  IV = IV ?? randomBytes();
  // final IV = randomBytes();
  final xUserBytes = await aesCtr256bitsWithKey(
      key: sharedKeyBytes, iv: IV, data: utf8.encode(userId));
  // 对时间戳签名
  final message = reqBodyBytes ?? utf8.encode(xTime.toString());
  final signature = await compute(ed25519Sign, <String, dynamic>{
    "message": message,
    "keyPair": userLoginInfo.keyPairEd25519,
  });

  final Map<String, dynamic> header = {
    "X-User-Agent": await getUserAgent(),
    "X-IV": base64Encode(IV),
    "X-User-U": base64Encode(xUserBytes),
    "X-User-D": "TODO-DeviceId",
    "X-PubKey-Number": serverPubKeyNoMix,
    "X-Client-TimeStamp": xTime,
    "X-Client-PubKey": xClientPubkey,
    "X-Client-SignPubKey": xClientSignPubkey,
    "X-Sign": base64Encode(signature.bytes),
  };
  return header;
}
