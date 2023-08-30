import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:myoption/util/config.dart';
import 'package:myoption/util/prefs/prefs.dart';
import 'package:myoption/util/sstorage/sstorage.dart';
import 'package:myoption/util/util.dart';

import '../service/model/model.dart';
import '../service/product_list.dart';
import 'big_endian.dart';
import 'init_sse.dart';

class Global {
  static APPConfig appConfig = APPConfig.empty();

  static String userAgent = '';
  static int serverPubKeyNo = 0;
  static String getCurUserId = ""; // 当前进程的登录用户 为空代表未登录

  static bool get isLogin => getCurUserId != "";

  static String get appName => appConfig.appName;

  static String get serverPubKey => appConfig.serverX25519PubKey;

  static String get appVersion => appConfig.version;

  static ApiHost get apiHost => appConfig.apiHost;
  static GeneralConfigData? generalConfigData;
  static bool dataNetwork = true;

  static Future<void> initConfig() async {
    appConfig = await parseAppConfig();

    userAgent = await getUserAgent();
  }

  static int? _deltaTime;

  static int? correctedTime() {
    // 50 是上行时间差
    const up = 50;
    return (_deltaTime == null)
        ? null
        : DateTime.now().millisecondsSinceEpoch + _deltaTime! + up;
  }

  static DateTime now() {
    // 50 是上行时间差
    const up = 50;
    return (_deltaTime == null)
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch + _deltaTime! + up);
  }

  static Future<bool> initGeneralConfigData() async {
    final now1 = DateTime.now().millisecondsSinceEpoch;
    final respData = await reqGeneralConfig(null);
    if (!respData.success) {
      return false;
    }
    generalConfigData = respData.data!;
    prefs.ruleInfo = respData.data!.ruleInfo;
    final updateTime = respData.data!.updateTime;
    _deltaTime = (updateTime - now1);
    return true;
  }

  static Future<void> init() async {
    await initConfig();
    await initGlobalPrefs();
    initGeneralConfigData();
    initSSS();
    getCurUserId = await ss.currentLoginUser;
    serverPubKeyNo = bigEndianUInt32(
        (await Sha1().hash(utf8.encode(serverPubKey))).bytes.sublist(0, 4));
  }
}
