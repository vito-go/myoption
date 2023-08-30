import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pointycastle/export.dart';

import 'global.dart';

List<int> randomBytes({int length = 16}) {
  var rnd = Random();
  var list = List<int>.generate(length, (i) => rnd.nextInt(255));
  return list;
}

Uint8List keyByPasswordPbkdf2(List<int> passwordBytes, Uint8List salt,
    {int keyLength = 32, int iterations = 4096}) {
  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength));
  final key = pbkdf2.process(Uint8List.fromList(passwordBytes));
  return key;
}

Future<Uint8List> keyByPasswordPbkdf2Compute(Map<String, dynamic> m) async {
  final passwordBytes = m['passwordBytes'];
  final salt = m['salt'];
  final iterations = m['iterations'] ?? 4096;
  final keyLength = m['keyLength'] ?? 32;

  final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength));
  final key = pbkdf2.process(Uint8List.fromList(passwordBytes));
  return key;
}

/*
// web版本的 Scrypt方法太慢了 耗时15秒钟，不行啊 太慢了
Scrypt算法中的三个参数N、r和p用于控制哈希函数的迭代次数、块大小和并行度。这些参数的值对于Scrypt算法的安全性和性能都有影响：

N：迭代次数
N表示哈希函数的迭代次数，它必须是2的幂次方。较高的迭代次数可以增加算法的安全性，但也会增加计算密集度。通常，N的值应该至少为16384。
r：块大小
r表示哈希函数所需的内存块的大小，以字节为单位。较大的块大小可以增加算法的安全性，但也会增加计算密集度。通常，r的值应该为8。
p：并行度
p表示Scrypt算法的并行度，即需要的并行线程数。较高的并行度可以增加算法的安全性，但也会增加计算密集度。通常，p的值应该为1。
这些参数的值应根据您的安全需求和计算能力进行调整。对于需要更高安全性的应用程序，应该使用更大的N、r和p值。但是，这也会增加计算密集度，可能会使应用程序的性能受到影响。
*/
Uint8List keyByPasswordScrypt(List<int> passwordBytes, Uint8List salt,
    {int keyLength = 32, int N = 16384}) {
  // 设置Scrypt参数
  final params = ScryptParameters(N, 8, 1, keyLength, salt);
  // 生成Scrypt密钥
  final scrypt = Scrypt()..init(params);
  final key = scrypt.process(Uint8List.fromList(passwordBytes));
  // 输出生成的密钥
  return key;
}

enum PlatformOS { android, ios, linux, web, windows, none }

bool platFormIsMobile() {
  if (kIsWeb) {
    return false;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    return true;
  }
  return false;
}

PlatformOS getPlatformOS() {
  if (kIsWeb) {
    return PlatformOS.web;
  }
  if (Platform.isAndroid) {
    return PlatformOS.android;
  }
  if (Platform.isIOS) {
    return PlatformOS.ios;
  }
  if (Platform.isLinux) {
    return PlatformOS.linux;
  }
  if (Platform.isWindows) {
    return PlatformOS.windows;
  }
  return PlatformOS.none;
}

myToast(BuildContext context, dynamic msg) {
  if (!context.mounted) return;
  showToast(
    "$msg",
    context: context,
    animation: StyledToastAnimation.fade,
    reverseAnimation: StyledToastAnimation.fade,
    position: StyledToastPosition.center,
    // curve: Curves.linear,
    // reverseCurve: Curves.linear,
  );
  myPrint(msg, skip: 2);
}

myPrint(dynamic msg,
    {List<dynamic>? args, String level = 'INFO', int skip = 1}) {
  if (kIsWeb) {
    skip = 2;
  }
  //  根据环境进行打印输出
  if (kDebugMode) {
    var traceString = StackTrace.current.toString().split("\n")[skip];
    String arg = "";

    if (args != null) {
      arg = "{";
      for (var i = 0; i < args.length; i++) {
        if (i % 2 == 0) {
          arg += '"${args[i]}": ';
        } else {
          if (i == args.length - 1) {
            arg += '${args[i]}';
          } else {
            arg += '${args[i]}, ';
          }
        }
      }
      arg += "}";
    }

    print("[$level] ${DateTime.now()} $traceString $msg $arg");
  }
}

Future<List<int>> aesCtr256bitsWithKey(
    {required List<int> key,
    required List<int> iv,
    required List<int> data}) async {
  // For AES, the only valid block size is 128 bits.i.e. block size is 16.
  iv[15];
  final algorithm = AesCtr.with256bits(macAlgorithm: Hmac.sha256());
  // Generate a random 256-bit secret key
  // final secretKey = await algorithm.newSecretKey();
  final secretKey = await algorithm.newSecretKeyFromBytes(key);
  // Generate a random 96-bit nonce.
  // final nonce = algorithm.newNonce();
  // Encrypt
  final secretBox = await algorithm.encrypt(
    data,
    secretKey: secretKey,
    nonce: iv,
  );

  return secretBox.cipherText;
}

//user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36
/// mychat/<version> OsName/OsVersion deviceName/(DeviceInfo)
Future<String> getUserAgent() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (kIsWeb) {
    return "";
  }
  if (Platform.isLinux) {
    LinuxDeviceInfo info = await deviceInfo.linuxInfo;
    return "${Global.appName}/${Global.appVersion} linux/${info.versionId} ${info.name}/(${info.version})";
  }
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    return "${Global.appName}/${Global.appVersion} android/${info.version.release} ${info.manufacturer}/(${info.model})";
  }
  if (Platform.isMacOS) {
    MacOsDeviceInfo info = await deviceInfo.macOsInfo;
    return "${Global.appName}/${Global.appVersion} macos/${info.osRelease} apple/(${info.model})";
  }
  if (Platform.isWindows) {
    WindowsDeviceInfo info = await deviceInfo.windowsInfo;
    return "${Global.appName}/${Global.appVersion} windows/${info.buildNumber} microsoft/(${info.productName})";
  }
  if (Platform.isIOS) {
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return "${Global.appName}/${Global.appVersion} ios/${info.systemVersion} apple/(${info.model})";
  }
  if (Platform.isFuchsia) {
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return "${Global.appName}/${Global.appVersion} fuchsia/${info.systemVersion} google/(${info.systemName}-${info.model})";
  }
  return '${Global.appName}/${Global.appVersion} ${Platform.operatingSystem}/${Platform.operatingSystemVersion} unknown/(unknown)';
}
