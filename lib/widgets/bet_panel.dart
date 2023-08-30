import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myoption/pages/login.dart';
import 'package:myoption/util/navigator.dart';
import 'package:myoption/util/prefs/prefs.dart';
import 'package:myoption/util/util.dart';
import 'package:myoption/widgets/loading_button.dart';
import 'package:myoption/widgets/types.dart';

import '../service/model/model.dart';
import '../service/submit_order.dart';
import '../util/global.dart';
import '../util/sstorage/sstorage.dart';

class ExchangeTime {
  String countryCode = "CN";

  int amStart = 93000;
  int amEnd = 113000;
  int pmStart = 130000;
  int pmEnd = 150000;

  bool inExchangeTime(DateTime dateTime) {
    final ssInt = int.parse(DateFormat('HHmmss').format(dateTime));
    if ((amStart <= ssInt && ssInt <= amEnd) ||
        (pmStart <= ssInt && ssInt <= pmEnd)) {
      return true;
    }
    return false;
  }
}

var exchangeTimeCN = ExchangeTime();

class BetPanel extends StatefulWidget {
  final String symbolCode;
  final String symbolName;
  final bool pop;
  final StreamController<List<Product>> streamController;

  const BetPanel(
      {super.key,
      required this.streamController,
      required this.pop,
      required this.symbolCode,
      required this.symbolName});

  @override
  _BetPanelState createState() => _BetPanelState();
}

class _BetPanelState extends State<BetPanel> {
  Option direction = Option.none;
  TextEditingController amountController = TextEditingController(text: "10");
  Session? session = prefs.getSession(Global.getCurUserId);
  final FocusNode focusNode = FocusNode();
  ValueNotifier<double> valueNotifierPrice = ValueNotifier(0);
  ValueNotifier<int> valueNotifierUpdateTime = ValueNotifier(
      Global.correctedTime() ?? DateTime.now().millisecondsSinceEpoch);

  bool get canBet {
    return ((direction != Option.none) && (session != null));
  }

  String get userId => Global.getCurUserId;

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    valueNotifierPrice.dispose();
    subscription?.cancel();
  }

  void reset() {
    focusNode.unfocus();
    direction = Option.none;
    session = null;
    amountController.text = "";
    prefs.setSession(userId, null);
    setState(() {});
  }

  bool checkBetMoney(int betMoney) {
    if (betMoney < 10) {
      myToast(context, "最低下注10金币");
      return false;
    }
    if (betMoney > 2000) {
      myToast(context, "最多下注2000金币");
      return false;
    }
    if (betMoney % 10 != 0) {
      myToast(context, "下注金额必须为10的整数倍");
      return false;
    }
    return true;
  }

  Future<void> submitOrder() async {
    if (Global.correctedTime() == null) {
      myToast(context, "请同步时间");
      return;
    }
    if (!Global.dataNetwork) {
      myToast(context, "网络错误，请稍后重试");
      return;
    }
    if (!Global.isLogin) {
      myToast(context, "请登录");
      if (widget.pop) {
        Navigator.pop(context);
      }
      pushTo(context, const Login());
      return;
    }
    final sessionBet = session;
    if (sessionBet == null) {
      myToast(context, "请选择场次");
      return;
    }
    if (direction == Option.none) {
      myToast(context, "请选择交易方向: ${Option.call.text}, ${Option.put.text}");
      return;
    }
    final balance = (await ss.getBalance(Global.getCurUserId));
    if (amountController.text == "") {
      myToast(context, "下注金额不能为空");
      return;
    }

    final int betMoney = int.parse(amountController.text);
    if (!checkBetMoney(betMoney)) {
      return;
    }
    if (balance == null) {
      myToast(context, "余额有误，请重新登陆");
      return;
    }
    if (balance < betMoney) {
      myToast(context, "余额不足");
      return;
    }
    final strikePrice = valueNotifierPrice.value;
    if (strikePrice <= 0) {
      myToast(context, "当前非交易时间");
      return;
    }

    final respData = await reqSubmitOrder(context,
        symbolCode: widget.symbolCode,
        strikePrice: strikePrice,
        option: direction,
        betMoney: betMoney,
        session: sessionBet);
    if (respData.code != 0) {
      return;
    }
    prefs.setSession(Global.getCurUserId, sessionBet);
    ss.setBalance(Global.getCurUserId, balance - betMoney);
    myToast(context, "下注成功");
    if (widget.pop) {
      Navigator.pop(context);
    }
    return;
  }

  List<DropdownMenuItem<Session>> getDropdownItemList(String symbolCode) {
    //Session.values
    //                   .map<DropdownMenuItem<Session>>((Session value) {
    //                 return DropdownMenuItem<Session>(
    //                   value: value,
    //                   child: Text(value.sessionString),
    //                 );
    //               }).toList()
    List<DropdownMenuItem<Session>> dropdownItems = [];

    final now = Global.now();

    for (Session value in Session.values) {
      bool enable = false;
      TextStyle? textStyle = const TextStyle(color: Colors.grey);
      if (value == Session.session0) {
        if (exchangeTimeCN.inExchangeTime(Global.now())) {
          enable = true;
          textStyle = null;
        }
      } else if (exchangeTimeCN
          .inExchangeTime(now.add(Duration(minutes: value.value)))) {
        enable = true;
        textStyle = null;
      }

      DropdownMenuItem<Session> dropdownItem = DropdownMenuItem<Session>(
          value: value,
          enabled: enable,
          child: Text(value.sessionString, style: textStyle));
      dropdownItems.add(dropdownItem);
    }
    List<DropdownMenuItem<Session>> dropdownItemList = dropdownItems.toList();
    return dropdownItemList;
  }

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.streamController.stream.listen((List<Product> data) {
      for (var ele in data) {
        if (ele.symbolCode == widget.symbolCode) {
          valueNotifierPrice.value = ele.price;
          valueNotifierUpdateTime.value =
              Global.correctedTime() ?? DateTime.now().millisecondsSinceEpoch;
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${widget.symbolName} ${widget.symbolCode}',
              style: const TextStyle(fontSize: 18),
            ),
            const Expanded(child: Text("")),
            IconButton(onPressed: reset, icon: const Icon(Icons.refresh))
          ],
        ),
        const SizedBox(height: 5),
        ValueListenableBuilder(
            valueListenable: valueNotifierPrice,
            builder: (BuildContext context, double? value, Widget? child) {
              return Text(
                '行权价: $value',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            }),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  if (direction == Option.call) {
                    setState(() {
                      direction = Option.none;
                    });
                    return;
                  }
                  setState(() {
                    direction = Option.call;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        direction == Option.call
                            ? Colors.red.shade600
                            : Colors.grey)),
                // color: direction == '看涨' ? Colors.green : null,
                child: Text(
                  Option.call.text,
                  style: TextStyle(
                      color: direction == Option.call ? Colors.white : null),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  if (direction == Option.put) {
                    setState(() {
                      direction = Option.none;
                    });
                    return;
                  }
                  setState(() {
                    direction = Option.put;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        direction == Option.put
                            ? Colors.green.shade600
                            : Colors.grey)),
                child: Text(Option.put.text),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: TextFormField(
                focusNode: focusNode,
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "金额",
                  // hintText: '请输入金额',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            DropdownButton<Session>(
              hint: const Text("请选择场次"),
              value: session,
              onChanged: (Session? newValue) {
                if (newValue == null) return;
                prefs.setSession(userId, newValue);
                session = newValue;
                setState(() {});
              },
              items: getDropdownItemList(widget.symbolCode),
            ),
            const SizedBox(width: 20),
            Expanded(
                child: ListTile(
                    title: ValueListenableBuilder(
                        valueListenable: valueNotifierUpdateTime,
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          if (value <= 0) return const Text("");
                          final ss = session;
                          if (ss == null) return const Text("");
                          if (ss == Session.session0) {
                            return RichText(
                                text: TextSpan(
                                    text: "到期时间:  ",
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    children: [
                                  TextSpan(
                                      text: ss.sessionString,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))
                                ]));
                          }
                          final now =
                              DateTime.fromMillisecondsSinceEpoch(value);
                          final settleTimeMin = DateFormat('HH:mm')
                              .format(now.add(Duration(minutes: ss.value)));
                          // return Text('到期时间: $settleTimeMin');
                          return RichText(
                              text: TextSpan(
                                  text: "到期时间:  ",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  children: [
                                TextSpan(
                                    text: settleTimeMin,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))
                              ]));
                        }))),
          ],
        ),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(
            child: MyButton(text: "下注", onPressed: submitOrder),
          ),
        ]),
        const SizedBox(height: 10),
      ],
    );
    return Container(
      // constraints: BoxConstraints(maxHeight: 380),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: column,
      ),
    );
  }
}

class SymbolExchangeConfig {
  String countryCode;
  String symbolCode;
  List<List<int>> tradingTime;

  SymbolExchangeConfig({
    required this.countryCode,
    required this.symbolCode,
    required this.tradingTime,
  });
}
