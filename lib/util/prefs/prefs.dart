import 'package:flutter/material.dart';
import 'package:myoption/pages/types.dart';
import 'package:myoption/util/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/model/model.dart';

late SharedPreferences _globalPrefs;

Future<void> initGlobalPrefs() async {
  _globalPrefs = await SharedPreferences.getInstance();
}

final prefs = _Prefs();
const String defaultRuleInfo =
    "产品介绍：\n本产品以以上证指数为标的，用于投注上证指数的价格。用户可选择下注金币数量（10-2000金币），以及不同场次（2分钟、3分钟、5分钟、10分钟、20分钟、30分钟、60分钟、全天）。投注方向有两个选项：看涨和看跌。\n\n举例说明：当前时间为10:01:00，实时价格指数为3230.64。用户选择5分钟场次，看涨，并下注10金币。\n\n到10:06:00，如果价格高于3230.64（如3233.56），用户盈利10金币；如果价格小于等于3230.64，用户亏损10金币。";

class _Prefs {
  String _keyDefaultSession(String userId) {
    return "myoption:_keyDefaultSession:$userId";
  }

  String _keyTodayToastInfo() {
    return "myoption:_keyTodayToastInfo";
  }

  String get _keyRuleInfo => "myoption:_keyRuleInfo";

  String get _keyThemeMode => "myoption:themeMode";

  String get currentLoginUser => Global.getCurUserId;

  ThemeMode get themeMode {
    final key = _keyThemeMode;
    final result = _globalPrefs.getInt(key);
    if (result == null) {
      _globalPrefs.setInt(key, 2);
       return ThemeMode.light;
    }
    if (result == 0) {
      return ThemeMode.system;
    }
    if (result == 1) {
      return ThemeMode.dark;
    }
    if (result == 2) {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  // 0 system 1 dark 2 light
  set themeMode(ThemeMode value) {
    final key = _keyThemeMode;
    if (value == ThemeMode.system) {
      _globalPrefs.setInt(key, 0);
    } else if (value == ThemeMode.dark) {
      _globalPrefs.setInt(key, 1);
    } else if (value == ThemeMode.light) {
      _globalPrefs.setInt(key, 2);
    }
  }

  String get ruleInfo =>
      _globalPrefs.getString(_keyRuleInfo) ?? defaultRuleInfo;

  set ruleInfo(String s) {
    _globalPrefs.setString(_keyRuleInfo, s);
  }

  Session? getSession(String userId) {
    final userId = currentLoginUser;
    final key = _keyDefaultSession(userId);
    final result = _globalPrefs.getInt(key);
    if (result == null) return null;
    return SessionExtension.fromInt(result);
  }

  bool getIsTodayToastInfo() {
    final key = _keyTodayToastInfo();
    final String toady =
        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}";
    final result = _globalPrefs.getString(key);
    if (result == null) return false;
    return toady == result;
  }

  void setIsTodayToastInfo() {
    final key = _keyTodayToastInfo();
    final String toady =
        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}";
    _globalPrefs.setString(key, toady);
  }

  Future<bool> setSession(String userId, Session? session) async {
    final userId = currentLoginUser;
    final key = _keyDefaultSession(userId);
    if (session == null) {
      return _globalPrefs.remove(key);
    }
    return _globalPrefs.setInt(key, session.value);
  }
}
