import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

const String serverX25519PubKey = String.fromEnvironment("SERVER_KEY",
    defaultValue: "IY6ICGL/kjcySPrzlq5RMIy4ItycfPhoBZ+9DIihrlo=");

class DartDefine {
  static const String SERVER_KEY = "SERVER_KEY";
  static const String APP_CONFIG = "APP_CONFIG";
}

class APPConfig {
  String appName = '';
  String version = "";
  String clientCode = '';
  String clientName = '';
  String homePage = '';

  // String serverX25519PubKey = '';
  ApiHost apiHost = ApiHost.empty();
  String serverX25519PubKey = const String.fromEnvironment(
      DartDefine.SERVER_KEY,
      defaultValue: "IY6ICGL/kjcySPrzlq5RMIy4ItycfPhoBZ+9DIihrlo=");

  APPConfig.empty();

  String toJson() {
    return jsonEncode({
      "appName": appName,
      "version": version,
      "clientCode": clientCode,
      "clientName": clientName,
      "homePage": homePage,
      "serverX25519PubKey": serverX25519PubKey,
      "apiHost": apiHost.toString(), // todo
    });
  }

  APPConfig({
    required this.appName,
    required this.version,
    required this.clientCode,
    required this.clientName,
    required this.homePage,
    required this.apiHost,
    required this.serverX25519PubKey,
  });
}

Future<APPConfig> parseAppConfig() async {
  String env = const String.fromEnvironment(DartDefine.APP_CONFIG,
      defaultValue: "config/online/https.yaml");
  final String envHostsFilePath = 'assets/$env';
  final data = await rootBundle.load(envHostsFilePath);
  final yamlData = utf8.decode(data.buffer.asUint8List());
  final YamlMap doc = loadYaml(yamlData);
  final String clientCode = doc['clientCode']!;
  final String homePage = doc['homePage'] as String;
  final String appName = doc['appName'] as String;
  final String clientName = doc['clientName'] as String;
  final YamlMap apiHost = doc['apiHost'] as YamlMap;
  final String version = doc['version'] as String;
  // final String serverX25519PubKey = doc['serverX25519PubKey'] as String;
  return APPConfig(
    appName: appName,
    version: version,
    clientCode: clientCode,
    clientName: clientName,
    homePage: homePage,
    apiHost: ApiHost.fromJson(apiHost),
    serverX25519PubKey: serverX25519PubKey,
  );
}

class ApiHost {
  String appRegister = '';
  String submitOrder = '';
  String orderList = '';
  String walletDetails = '';
  String myBalance = '';
  String logIn = '';
  String priceLast = '';
  String productList = '';
  String lineChart = '';
  String generalConfig = '';

  ApiHost.empty();

  ApiHost.fromJson(YamlMap json) {
    appRegister = json['appRegister'];
    submitOrder = json['submitOrder'];
    orderList = json['orderList'];
    logIn = json['logIn'];
    priceLast = json['priceLast'];
    productList = json['productList'];
    generalConfig = json['generalConfig'];
    walletDetails = json['walletDetails'];
    myBalance = json['myBalance'];
    lineChart = json['lineChart'];
  }
}
