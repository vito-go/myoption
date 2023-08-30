//
// type registerParam struct {
// UserId   string `json:"userId,omitempty"`
// Nick     string `json:"nick,omitempty"`
// Avatar   string `json:"avatar"`
// Password string `json:"password,omitempty"`
// // 新增字段
// X25519PubKey     string `json:"x25519PubKey"`
// X25519PriEncKey  string `json:"x25519PriEncKey"`
// Ed25519PubKey    string `json:"ed25519PubKey"`
// Ed25519PriEncKey string `json:"ed25519PriEncKey"`
// }
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/sstorage/sstorage.dart';

import '../util/compute_25519.dart';
import '../util/util.dart';
import 'model/model.dart';

Future<bool> userLogIn(BuildContext context, LoginAction loginAction,
    {required String userId, required String pwd}) async {
  final serverPubKey = Global.serverPubKey;
  final dio = Dio();

  final algorithm = X25519();
  // We need the private key pair of Alice.
  final SimpleKeyPair x25519KeyPair = await algorithm.newKeyPair();
  final alicePubKey = await x25519KeyPair.extractPublicKey();
  final alicePriKey = await x25519KeyPair.extractPrivateKeyBytes();
// We can now calculate a 32-byte shared secret key.
  final sharedKey = await algorithm.sharedSecretKey(
    keyPair: x25519KeyPair,
    remotePublicKey:
        SimplePublicKey(base64Decode(serverPubKey), type: KeyPairType.x25519),
  );
  final passwordBytes = utf8.encode(pwd);
  final salt = randomBytes(length: 16);
  final encIV = salt;

  final priEncKey = await compute(keyByPasswordPbkdf2Compute, <String, dynamic>{
    "passwordBytes": passwordBytes,
    "salt": Uint8List.fromList(salt),
  });
  final passwordSalt =
      (await Sha1().hash(utf8.encode(userId))).bytes.sublist(0, 16);
  final pwdPbkdf2Bytes =
      await compute(keyByPasswordPbkdf2Compute, <String, dynamic>{
    "passwordBytes": passwordBytes,
    "salt": Uint8List.fromList(passwordSalt),
    "keyLength": 24,
    "iterations": 1024,
  });

  final pwdPbkdf2Sha256Bytes = (await Sha256().hash(pwdPbkdf2Bytes)).bytes;
  final x25519PriEncKeyBytes =
      await aesCtr256bitsWithKey(key: priEncKey, iv: encIV, data: alicePriKey);

  final ed25519 = Ed25519();
  final ed25519KeyPair = await ed25519.newKeyPair();
  final ed25519PriKeyBytes = await ed25519KeyPair.extractPrivateKeyBytes();
  final ed25519PubKeyBytes = (await ed25519KeyPair.extractPublicKey()).bytes;
  final ed25519PriEncKeyBytes = await aesCtr256bitsWithKey(
      key: priEncKey, iv: encIV, data: ed25519PriKeyBytes);
  final passwordBase64 = base64Encode(pwdPbkdf2Sha256Bytes);
  final x25519PubKey = base64Encode(alicePubKey.bytes);
  final x25519PriEncKey = base64Encode(x25519PriEncKeyBytes);
  final ed25519PubKey = base64Encode(ed25519PubKeyBytes);
  final ed25519PriEncKey = base64Encode(ed25519PriEncKeyBytes);
  Map<String, String> data = {
    "userId": userId,
    "salt": base64Encode(salt),
    "password": passwordBase64,
    "x25519PubKey": x25519PubKey,
    "x25519PriEncKey": x25519PriEncKey,
    "ed25519PubKey": ed25519PubKey,
    "ed25519PriEncKey": ed25519PriEncKey,
  };
  String bodyData = jsonEncode(data);
  final sharedKeyBytes = await sharedKey.extractBytes();
  final IV = randomBytes();
  final encBody = await aesCtr256bitsWithKey(
      key: sharedKeyBytes, iv: IV, data: utf8.encode(bodyData));
  final signature = await compute(ed25519Sign, <String, dynamic>{
    "message": utf8.encode(bodyData),
    "keyPair": ed25519KeyPair,
  });

  myPrint("---sin done");

  final String www;
  switch (loginAction) {
    case LoginAction.register:
      www = Global.apiHost.appRegister;
      break;
    case LoginAction.logIn:
      www = Global.apiHost.logIn;
      break;
  }

  final xTime = Global.now().millisecondsSinceEpoch;
  final serverPubKeyNoMix = xTime ^ Global.serverPubKeyNo;
  final xUserBytes = await aesCtr256bitsWithKey(
      key: sharedKeyBytes, iv: IV, data: utf8.encode(userId));
  final Map<String, dynamic> header = {
    "X-User-Agent": await getUserAgent(),
    "X-IV": base64Encode(IV),
    "X-User-U": base64Encode(xUserBytes),
    "X-User-D": "TODO-DeviceId",
    "X-PubKey-Number": serverPubKeyNoMix,
    "X-Client-TimeStamp": xTime,
    "X-Client-PubKey": base64Encode(alicePubKey.bytes),
    "X-Client-SignPubKey": base64Encode(ed25519PubKeyBytes),
    "X-Sign": base64Encode(signature.bytes),
  };
  final Options options = Options(
    headers: header,
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.json,
  );
  final Response<Map<String, dynamic>> response =
      await dio.post(www, data: base64Encode(encBody), options: options);

  if (response.statusCode == 200) {
    final respData = response.data;
    if (respData == null) return false;
    if (respData["code"] != 0) {
      myToast(context, respData["message"]);
      return false;
    }
    //	LoinToken string       `json:"loinToken"` // 同步数据的时候不用返回
    // 	Balance   int64        `json:"balance"`
    final Map<String, dynamic> data = respData['data'];
    final balance = respData['data']['balance'] ?? 0;
    final loinToken = respData['data']['loinToken'];
    final UserLoginInfo userLoginInfo;
    switch (loginAction) {
      case LoginAction.register:
        userLoginInfo = UserLoginInfo(
          userId: userId,
          salt: base64Encode(salt),
          password: passwordBase64,
          x25519PubKey: x25519PubKey,
          x25519PriKey: base64Encode(alicePriKey),
          ed25519PubKey: ed25519PubKey,
          ed25519PriKey: base64Encode(ed25519PriKeyBytes),
          loginToken: loinToken,
          sharedKey: base64Encode(sharedKeyBytes),
        );
        myPrint("注册： ${userLoginInfo.toJson()}");
        break;
      case LoginAction.logIn:
        final realSalt = base64Decode(data["salt"]);
        final realPriEncKey =
            await compute(keyByPasswordPbkdf2Compute, <String, dynamic>{
          "passwordBytes": passwordBytes,
          "salt": Uint8List.fromList(realSalt),
        });
        final x25519PriEncKeyBytes = base64Decode(data["x25519PriEncKey"]);
        final x25519PriKey = await aesCtr256bitsWithKey(
            key: realPriEncKey, iv: realSalt, data: x25519PriEncKeyBytes);
        final ed25519PriEncKeyBytes = base64Decode(data["ed25519PriEncKey"]);
        final ed25519PriKey = await aesCtr256bitsWithKey(
            key: realPriEncKey, iv: realSalt, data: ed25519PriEncKeyBytes);

        final realSharedKey = await algorithm.sharedSecretKey(
          keyPair: SimpleKeyPairData(x25519PriKey,
              publicKey: SimplePublicKey(base64Decode(data["x25519PubKey"]),
                  type: KeyPairType.x25519),
              type: KeyPairType.x25519),
          remotePublicKey: SimplePublicKey(base64Decode(serverPubKey),
              type: KeyPairType.x25519),
        );

        userLoginInfo = UserLoginInfo(
          userId: userId,
          salt: data["salt"],
          password: passwordBase64,
          x25519PubKey: data["x25519PubKey"],
          x25519PriKey: base64Encode(x25519PriKey),
          ed25519PubKey: data["ed25519PubKey"],
          ed25519PriKey: base64Encode(ed25519PriKey),
          loginToken: loinToken,
          sharedKey: base64Encode(await realSharedKey.extractBytes()),
        );
        myPrint("登录： ${userLoginInfo.toJson()}");
        break;
    }
    await ss.logIn(userLoginInfo, balance);
    await Global.init();
    return true;
  }
  return false;
}
