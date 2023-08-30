import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myoption/util/util.dart';

import '../../service/model/model.dart';

// [0:过期时间毫秒时间戳(0不过期),  1:内容]
/// must [initGlobalPrefs] before using
FlutterSecureStorage _ss = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true));

//     "userId": userId,
//     "salt": base64Encode(salt),
//     "password": base64Encode(pwdPbkdf2Sha256Bytes),
//     "x25519PubKey": base64Encode(alicePubKey.bytes),
//     "x25519PriEncKey": base64Encode(x25519PriEncKeyBytes),
//     "ed25519PubKey": base64Encode(ed25519PubKeyBytes),
//     "ed25519PriEncKey": base64Encode(ed25519PriEncKeyBytes),
class UserLoginInfo {
  String userId = "";
  String salt = "";
  String password = ""; //  base64Encode(pwdPbkdf2Sha256Bytes),
  String x25519PubKey = '';
  String x25519PriKey = '';
  String ed25519PubKey = '';
  String ed25519PriKey = '';
  String loginToken = '';
  String sharedKey = '';

  List<int> get sharedKeyBytes {
    return base64Decode(sharedKey);
  }

  KeyPair get keyPairEd25519 {
    return SimpleKeyPairData(base64Decode(ed25519PriKey),
        publicKey: SimplePublicKey(base64Decode(ed25519PubKey),
            type: KeyPairType.ed25519),
        type: KeyPairType.ed25519);
  }

  UserLoginInfo({
    required this.userId,
    required this.salt,
    required this.password,
    required this.x25519PubKey,
    required this.x25519PriKey,
    required this.ed25519PubKey,
    required this.ed25519PriKey,
    required this.loginToken,
    required this.sharedKey,
  });

  UserLoginInfo.fromJson(Map<String, dynamic> o) {
    userId = o['userId'] ?? '';
    salt = o['salt'] ?? '';
    password = o['password'] ?? '';
    x25519PubKey = o['x25519PubKey'] ?? '';
    x25519PriKey = o['x25519PriKey'] ?? '';
    ed25519PubKey = o['ed25519PubKey'] ?? '';
    ed25519PriKey = o['ed25519PriKey'] ?? '';
    loginToken = o['loginToken'] ?? '';
    sharedKey = o['sharedKey'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['salt'] = salt;
    data['password'] = password;
    data['x25519PubKey'] = x25519PubKey;
    data['x25519PriKey'] = x25519PriKey;
    data['ed25519PubKey'] = ed25519PubKey;
    data['ed25519PriKey'] = ed25519PriKey;
    data['loginToken'] = loginToken;
    data['sharedKey'] = sharedKey;
    return data;
  }
}

final ss = SStorage();

class SStorage {
  // ------
  String keyUserLoginInfo(String userId) {
    return "myoption:keyUserLoginInfo:$userId";
  }

  String keyUserInfo(String userId) {
    return "myoption:keyUserInfo:$userId";
  }

  String keyBalance(String userId) {
    return "myoption:keyBalance:$userId";
  }

  String keyCurrentLoginUser() {
    return "myoption:keyCurrentLoginUser";
  }

  String _keyOrderListColumns(String userId) {
    return "myoption:keyOrderListFiledNames:$userId";
  }

  String _keyWalletDetails(String userId) {
    return "myoption:_keyWalletDetails:$userId";
  }

  // -------------------------------
  Future<FiledNames> getOrderListColumns() async {
    final userId = await currentLoginUser;
    final key = _keyOrderListColumns(userId);
    final String? s = await _ss.read(key: key);
    if (s == null) return FiledNames();
    return FiledNames.fromJson(jsonDecode(s));
  }

  Future<void> setOrderListColumns(FiledNames filedNames) async {
    final userId = await currentLoginUser;
    final key = _keyOrderListColumns(userId);
    await _ss.write(key: key, value: jsonEncode(filedNames.toJson()));
  }

  Future<FiledNames> getKeyWalletDetails() async {
    final userId = await currentLoginUser;
    final key = _keyWalletDetails(userId);
    final String? s = await _ss.read(key: key);
    if (s == null) return FiledNames();
    return FiledNames.fromJson(jsonDecode(s));
  }

  Future<void> setKeyWalletDetails(FiledNames filedNames) async {
    final userId = await currentLoginUser;
    final key = _keyWalletDetails(userId);
    await _ss.write(key: key, value: jsonEncode(filedNames.toJson()));
  }

  // getCurUserId一定不为空
  Future<List<int>?> get sharedKeyBytes async {
    final userId = await currentLoginUser;
    if (userId == "") return null;
    final userLoginInfo = await getUserLoginInfo(userId);
    if (userLoginInfo == null) return null;
    return base64Decode(userLoginInfo.sharedKey);
  }

  Future<String> get currentLoginUser async {
    final key = keyCurrentLoginUser();
    final String? s = await _ss.read(key: key);
    myPrint(s);
    if (s == null) return "";
    return s;
  }

  Future<void> _setCurrentLoginUser(String userId) async {
    final key = keyCurrentLoginUser();
    return _ss.write(key: key, value: userId);
  }

  Future<int?> getBalance(String userId) async {
    final key = keyBalance(userId);
    final String? s = await _ss.read(key: key);
    if (s == null) return null;
    final result = int.tryParse(s);
    return result;
  }

  Future<void> setBalance(String userId, int balance) async {
    final key = keyBalance(userId);
    return _ss.write(key: key, value: balance.toString());
  }

  Future<void> logIn(UserLoginInfo userLoginInfo, int balance) async {
    final userId = userLoginInfo.userId;
    await _saveUserLoginInfo(userLoginInfo);
    await _setCurrentLoginUser(userId);
    await setBalance(userId, balance);
  }

  Future<void> logOut(String userId) async {
    await _ss.delete(key: keyUserLoginInfo(userId));
    await _ss.delete(key: keyCurrentLoginUser());
    await _ss.delete(key: keyBalance(userId));
  }

  Future<void> _saveUserLoginInfo(UserLoginInfo userLoginInfo) async {
    final key = keyUserLoginInfo(userLoginInfo.userId);
    return _ss.write(key: key, value: jsonEncode(userLoginInfo.toJson()));
  }

  // getCurUserId一定不为空
  Future<UserLoginInfo?> getUserLoginInfo(String userId) async {
    final key = keyUserLoginInfo(userId);
    String? s = await _ss.read(key: key);
    if (s == null) return null;
    Map<String, dynamic> result = jsonDecode(s);
    return UserLoginInfo.fromJson(result);
  }
}
