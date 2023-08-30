import 'package:fl_chart/fl_chart.dart';

class LineValue {
  late final String tip; //图例提示文字
  late final List<FlSpot> flSpots;

  LineValue(this.tip, this.flSpots);
}

class ChartLineData {
  late final String title;
  late final String subTitle;
  late final String xName;
  late final String yName;
  late final bool dotDataShow;
  late final Map<String, dynamic> xTitleMap;
  late final Map<String, dynamic> xTitleIndexMap;
  late final Map<String, dynamic> yTitleMap;
  late final double baselineY;
  late final double? minY;
  late final double? maxY;

  late final List<LineValue> lineValues;

  ChartLineData.fromJson(Map<String, dynamic> m) {
    title = m['title'] ?? '';
    subTitle = m['subTitle'] ?? '';
    xName = m['xName'] ?? '';
    yName = m['yName'] ?? '';
    baselineY = double.parse(m['baselineY'].toString());
    minY = double.tryParse(m['minY'].toString());
    maxY = double.tryParse(m['maxY'].toString());
    dotDataShow = m['dotDataShow'] ?? true;
    xTitleMap = m['xTitleMap'] ?? {};
    yTitleMap = m['yTitleMap'] ?? {};
    xTitleIndexMap = m['xTitleIndexMap'] ?? {};

    List<LineValue> list = [];
    for (var element in m['lineValues'] ?? []) {
      List<FlSpot> listSpots = [];
      for (var ele in element['flSpots']) {
        // type 'int' is not a subtype of type 'double' in type cast
        listSpots.add(FlSpot((double.tryParse(ele[0].toString()) ?? 0),
            (double.tryParse(ele[1].toString()) ?? 0)));
      }
      list.add(LineValue(element["tip"].toString(), listSpots));
    }
    lineValues = list;
  }
}

class GeneralConfigData {
  int updateTime = 0;
  String ruleInfo = "";

  GeneralConfigData.fromJson(Map<String, dynamic> json) {
    updateTime = json['updateTime'] ?? 0;
    ruleInfo = json['ruleInfo'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "updateTime": updateTime,
      "ruleInfo": ruleInfo,
    };
  }
}

abstract class JsonSerializable<T> {
  Map<String, dynamic> toJson();
}

class GenericData<T> {
  List<T> orders = [];
  FiledNames fieldNames = FiledNames();

  GenericData({required this.orders, required this.fieldNames});

  GenericData.fromJson(
      Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) {
    final List<dynamic> items = data['items'];
    orders = List<T>.generate(items.length, (index) {
      return fromJson(items[index]);
    });
    fieldNames = FiledNames.fromJsonList(data["fieldNames"]);
  }
}

class WalletBalance {
  int balance = 0;

  int frozenAmount = 0;

  int totalAmount = 0;

  WalletBalance(
      {required this.balance,
      required this.frozenAmount,
      required this.totalAmount});

  WalletBalance.fromJson(Map<String, dynamic> data) {
    balance = data['balance'] ?? 0;
    frozenAmount = data['frozenAmount'] ?? 0;
    totalAmount = data['balance'] ?? 0;
  }
}

enum MarketStatus {
  none,
  normal,
  close,
  waitToOpen,
  pause,
  weekend,
  holiday,
}

extension MarketStatusExtension on MarketStatus {
  String get statusString {
    switch (this) {
      case MarketStatus.normal:
        return "交易中";
      case MarketStatus.close:
        return "已收盘";
      case MarketStatus.waitToOpen:
        return "待开盘";
      case MarketStatus.pause:
        return "休市";
      case MarketStatus.weekend:
        return "周末休市";
      case MarketStatus.holiday:
        return "假日休市";
      default:
        return "-";
    }
  }

  static MarketStatus fromInt(int value) {
    switch (value) {
      case 1:
        return MarketStatus.normal;
      case 2:
        return MarketStatus.close;
      case 3:
        return MarketStatus.waitToOpen;
      case 4:
        return MarketStatus.pause;
      case 5:
        return MarketStatus.weekend;
      case 6:
        return MarketStatus.holiday;
      default:
        return MarketStatus.none;
    }
  }
}

enum Session {
  session2,
  session3,
  session5,
  session10,
  session15,
  session20,
  session30,
  session60,
  session0, // 全天
}

extension SessionExtension on Session {
  int get value {
    switch (this) {
      case Session.session0:
        return 0;
      case Session.session2:
        return 2;
      case Session.session3:
        return 3;
      case Session.session5:
        return 5;
      case Session.session10:
        return 10;
      case Session.session15:
        return 15;
      case Session.session20:
        return 20;
      case Session.session30:
        return 30;
      case Session.session60:
        return 60;
    }
  }

  static Session fromInt(int value) {
    switch (value) {
      case 0:
        return Session.session0;
      case 2:
        return Session.session2;
      case 3:
        return Session.session3;
      case 5:
        return Session.session5;
      case 10:
        return Session.session10;
      case 15:
        return Session.session15;
      case 20:
        return Session.session20;
      case 30:
        return Session.session30;
      case 60:
        return Session.session60;
      default:
        throw Exception('Invalid Session value');
    }
  }

  String get sessionString {
    switch (this) {
      case Session.session0:
        return '全天';
      case Session.session2:
        return '2分钟';
      case Session.session3:
        return '3分钟';
      case Session.session5:
        return '5分钟';
      case Session.session10:
        return '10分钟';
      case Session.session15:
        return '15分钟';
      case Session.session20:
        return '20分钟';
      case Session.session30:
        return '30分钟';
      case Session.session60:
        return '60分钟';
    }
  }
}

class RespData<T> {
  int code = 0;
  String message = "";
  T? data;

  RespData({
    this.code = 0,
    this.message = "",
    this.data,
  });

  RespData.dataOK(T d) {
    data = d;
  }

  bool get success => code == 0;

  RespData.fromJson(
      Map<String, dynamic> m, T Function(Map<String, dynamic> json) fromJson) {
    code = m['code'] as int ?? 0;
    message = m['message'] as String;
    if (m.containsKey('data')) {
      data = fromJson(m['data'] as Map<String, dynamic>);
    }
  }

  RespData.error() {
    code = -1;
  }
}


class TradeOrder extends JsonSerializable {
  String transId = '';
  String sessionTimMin = '';
  String symbolCodeName = '';
  String strikePrice = "";
  String option = "";
  String betMoney = "";
  String orderTime = "";
  String session = "";
  String settlePrice = "";
  String settleResult = "";
  String orderStatus = "";
  String profitLoss = "";

  TradeOrder(
      {required this.transId,
      required this.sessionTimMin,
      required this.symbolCodeName,
      required this.strikePrice,
      required this.option,
      required this.betMoney,
      required this.orderTime,
      required this.session,
      required this.settlePrice,
      required this.settleResult,
      required this.orderStatus,
      required this.profitLoss});

  TradeOrder.fromJson(Map<String, dynamic> json) {
    transId = json['transId'] ?? '';
    symbolCodeName = json['symbolCodeName'] ?? '';
    sessionTimMin = json['sessionTimMin'] ?? '';
    strikePrice = json['strikePrice'] ?? '';
    option = json['option'] ?? '';
    betMoney = json['betMoney'] ?? '';
    orderTime = json['orderTime'] ?? '';
    session = json['session'] ?? '';
    settlePrice = json['settlePrice'] ?? '';
    settleResult = json['settleResult'] ?? '';
    orderStatus = json['orderStatus'] ?? '';
    profitLoss = json['profitLoss'] ?? '';
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transId'] = transId;
    data['sessionTimMin'] = sessionTimMin;
    data['symbolCodeName'] = symbolCodeName;
    data['strikePrice'] = strikePrice;
    data['option'] = option;
    data['betMoney'] = betMoney;
    data['orderTime'] = orderTime;
    data['session'] = session;
    data['settlePrice'] = settlePrice;
    data['settleResult'] = settleResult;
    data['orderStatus'] = orderStatus;
    data['profitLoss'] = profitLoss;
    return data;
  }
}

class WalletDetail extends JsonSerializable {
  String transId = '';
  String transType = '';
  String userId = '';
  String amount = '';
  String status = '';
  String remark = '';
  String sourceKind = '';
  String sourceTransId = '';
  String fromAccount = '';
  String toAccount = '';
  String balance = '';
  String createTime = '';
  String updateTime = '';

  WalletDetail({
    required this.transId,
    required this.transType,
    required this.userId,
    required this.amount,
    required this.status,
    required this.remark,
    required this.sourceKind,
    required this.sourceTransId,
    required this.fromAccount,
    required this.toAccount,
    required this.balance,
    required this.createTime,
    required this.updateTime,
  });

  WalletDetail.fromJson(Map<String, dynamic> json) {
    transId = json['transId'] ?? '';
    transType = json['transType'] ?? '';
    userId = json['userId'] ?? '';
    amount = json['amount'] ?? '';
    status = json['status'] ?? '';
    remark = json['remark'] ?? '';
    sourceKind = json['sourceKind'] ?? '';
    sourceTransId = json['sourceTransId'] ?? '';
    fromAccount = json['fromAccount'] ?? '';
    toAccount = json['toAccount'] ?? '';
    balance = json['balance'] ?? '';
    createTime = json['createTime'] ?? '';
    updateTime = json['updateTime'] ?? '';
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transId'] = transId;
    data['transType'] = transType;
    data['userId'] = userId;
    data['amount'] = amount;
    data['status'] = status;
    data['remark'] = remark;
    data['sourceKind'] = sourceKind;
    data['sourceTransId'] = sourceTransId;
    data['fromAccount'] = fromAccount;
    data['toAccount'] = toAccount;
    data['balance'] = balance;
    data['createTime'] = createTime;
    data['updateTime'] = updateTime;
    return data;
  }
}

class FiledNames {
  List<String> fields = [];
  Map<String, dynamic> fieldNameMap = {};
  Map<String, dynamic> fieldWidthMap = {};

  FiledNames();

  FiledNames.fromJsonList(List<dynamic> m) {
    for (var element in m) {
      fields.add(element['field'].toString());
      fieldNameMap[element['field'].toString()] = element['name'].toString();
      fieldWidthMap[element['field'].toString()] = -1.0;
    }
  }

  FiledNames.fromJson(Map<String, dynamic> json) {
    fields = (json['fields'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();
    fieldNameMap = json['fieldNameMap'] ?? {};
    fieldWidthMap = json['fieldWidthMap'] ?? {};
  }

  Map<String, dynamic> toJson() => {
        "fields": fields,
        "fieldNameMap": fieldNameMap,
        "fieldWidthMap": fieldWidthMap,
      };
}

class ProductListResult {
  int code = 0;
  String message = '';
  ProductData? data;

  ProductListResult({required this.code, this.message = "", this.data});

  ProductListResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? ProductData.fromJson(json['data']) : null;
  }
}

class ProductData {
  List<Product> items = [];

  ProductData({required this.items});

  @override
  ProductData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Product>[];
      json['items'].forEach((v) {
        items.add(Product.fromJson(v));
      });
    }
  }
}

class Product {
  String symbolCode = '';
  String symbolName = '';
  bool exist = false;
  double price = 0.0;
  int day = 0;
  int timeMin = 0;
  MarketStatus marketStatus = MarketStatusExtension.fromInt(0);

  Product({
    this.symbolCode = '',
    this.exist = false,
    this.price = 0.0,
    this.day = 0,
    this.timeMin = 0,
    this.symbolName = '',
    this.marketStatus = MarketStatus.none,
  });

  Product.fromJson(Map<String, dynamic> json) {
    symbolCode = json['symbolCode'] ?? '';
    exist = json['exist'] ?? false;
    price = json['price']?.toDouble() ?? 0.0;
    day = json['day'] ?? 0;
    timeMin = json['timeMin'] ?? 0;
    symbolName = json['symbolName'] ?? '';
    marketStatus = MarketStatusExtension.fromInt(json['marketStatus'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['symbolCode'] = symbolCode;
    data['exist'] = exist;
    data['price'] = price;
    data['day'] = day;
    data['timeMin'] = timeMin;
    data['symbolName'] = symbolName;
    data['marketStatus'] = marketStatus.statusString;
    return data;
  }
}

class SSEData {
  List<Product> items = [];
  int updateTime = 0;

  SSEData({required this.items, required this.updateTime});

  SSEData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Product>[];
      json['items'].forEach((v) {
        items.add(Product.fromJson(v));
      });
    }
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items'] = items.map((v) => v.toJson()).toList();
    data['updateTime'] = updateTime;
    return data;
  }
}

enum LoginAction {
  register,
  logIn,
}
