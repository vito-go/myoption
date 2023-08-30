import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myoption/pages/login.dart';
import 'package:myoption/service/req_line_chart.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/navigator.dart';
import 'package:myoption/util/prefs/prefs.dart';
import 'package:myoption/util/util.dart';

import '../service/model/model.dart';
import '../service/product_list.dart';
import '../util/global_event.dart';
import '../util/init_sse.dart';
import '../widgets/bet_panel.dart';
import '../widgets/get_scaffold.dart';
import '../widgets/home_drawer.dart';
import '../widgets/reconnect.dart';
import '../widgets/update_time_now.dart';
import 'index_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Product> initData = [];

  void globalEventHandler(GlobalEvent event) {
    myPrint("home收到 ${event.eventType}");
    switch (event.eventType) {
      case GlobalEventType.dataNetworkChange:
        setState(() {});
        break;
      case GlobalEventType.timeNow:
        setState(() {});
        break;
    }
  }

  /*
  *
如果你的属性值依赖于类中的其他函数，那么你必须在initState方法中初始化它们。
* 这是因为，在build方法被调用之前，Flutter需要确保所有的变量都已经被正确地初始化。
* 如果你在late final变量中初始化依赖于其他函数的属性，那么这些函数可能还没有被调用，
* 这会导致late final变量没有正确的值。因此，如果你的属性依赖于其他函数的返回值或状态，
* 最好在initState方法中初始化它们，以确保它们在build方法被调用之前被正确地初始化。
  * */
  StreamSubscription<GlobalEvent>? globalEventSubscription;

// late final无法初始化
  final TextEditingController controllerBet = TextEditingController(text: "10");

  @override
  void dispose() {
    super.dispose();
    globalEventSubscription?.cancel();
    focusNode.dispose();
    controllerBet.dispose();
  }

  Widget buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        // color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  void showPanel(Product p) {
    final BetPanel panel = BetPanel(
      pop: true,
      symbolName: p.symbolName,
      symbolCode: p.symbolCode,
      streamController: streamController,
    );
    if (kIsWeb || !platFormIsMobile()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 480), child: panel),
          );
        },
      );
      return;
    }
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
        context: context,
        builder: (BuildContext context) {
          return panel;
        });
  }

  Future<void> _pushToLineChart(BuildContext context, Product p) async {
    final respData = await reqLineChart(context, p.symbolCode);
    if (respData.code != 0) {
      myToast(context, respData.message);
      return;
    }
    myPrint(respData.data!);
    if (!context.mounted) return;
    final IndexChart indexChart = IndexChart(
      chartLineData: respData.data!,
      streamController: streamController,
      symbolCode: p.symbolCode,
      symbolName: p.symbolName,
    );
    pushTo(context, indexChart);
  }

  Widget _productToRow(BuildContext context, Product p) {
    final Text textCodeName =
        Text("${p.symbolName}\n${p.symbolCode}", textAlign: TextAlign.center);
    final List<Widget> children = [
      Expanded(flex: 3, child: textCodeName),
      Expanded(
          flex: 2,
          child: Text("${p.marketStatus.statusString} ",
              textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child: Text("${p.price > 0 ? p.price : 0}",
              textAlign: TextAlign.center)),
      Expanded(
          flex: 3,
          child: ElevatedButton(
              onPressed: () {
                if (Global.correctedTime() == null) {
                  myToast(context, "请同步时间");
                }
                showPanel(p);
              },
              child: const Text("交易"))),
    ];
    final row = InkWell(
      onTap: () {
        if (!Global.dataNetwork) {
          myToast(context, "网络错误，请稍后重试");
          return;
        }
        _pushToLineChart(context, p);
      },
      child: Row(children: children),
    );
    return row;
  }

  List<Widget> productsRows(BuildContext context, List<Product> products) {
    List<Widget> items = [];
    for (var i = 0; i < products.length; i++) {
      final p = products[i];
      items.add(_productToRow(context, p));
      items.add(const Divider());
    }
    return items;
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: buildHeader("产品"),
        ),
        Expanded(flex: 2, child: buildHeader("状态")),
        Expanded(flex: 3, child: buildHeader("价格")),
        Expanded(flex: 3, child: buildHeader("操作")),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    controllerBet.addListener(() {});
    initProductList();
    myPrint("准备globalEventSubscription");
    globalEventSubscription = subscriptGlobalEvent(globalEventHandler);
    Future.delayed(const Duration(seconds: 3), () {
      if (!prefs.getIsTodayToastInfo()) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(Global.appName),
                content: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(prefs.ruleInfo),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            prefs.setIsTodayToastInfo();
                          },
                          child: const Text("关闭且今天不再提醒")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text("关闭")),
                    ],
                  )
                ],
              );
            });
      }
    });
  }

  void initProductList() {
    reqProductList(context).then((value) {
      if (value.code == 0) {
        streamController.sink.add(value.data!.items);
      }
    });
  }

  final FocusNode focusNode = FocusNode();
  late final ValueNotifier<int?> notifierTimeNow =
      ValueNotifier(Global.correctedTime());

  @override
  Widget build(BuildContext context) {
    final Widget widgetListView = StreamBuilder<List<Product>>(
        stream: streamController.stream,
        initialData: initData,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          final products = snapshot.data!;
          return ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return _productToRow(context, products[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemCount: products.length);
        });

    final List<Widget> children = [];
    if (!Global.dataNetwork) {
      children.add(const Center(child: ReConnect(onPressed: initSSS)));
      children.add(const SizedBox(height: 8));
    }
    children.add(const ShowUpdateTimeNow());
    children.add(const SizedBox(height: 5));
    children.add(_buildHeader());
    children.add(const SizedBox(height: 10));
    children.add(Expanded(child: widgetListView));
    children.add(const SizedBox(height: 10));
    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.center, children: children);
    Widget appBarTitle;
    if (Global.isLogin) {
      appBarTitle = Text(Global.getCurUserId);
    } else {
      appBarTitle = const Text("(未登录)");
    }
    List<Widget> actions = [];
    if (kDebugMode) {
      actions.add(
          IconButton(onPressed: () async {}, icon: const Icon(Icons.coffee)));
    }
    actions.add(IconButton(
        onPressed: () {
          showAboutDialog(
              context: context,
              children: [Text(prefs.ruleInfo)],
              applicationName: Global.appName);
        },
        icon: const Icon(Icons.help)));
    final appBar = AppBar(
      title: InkWell(
        onTap: Global.isLogin
            ? null
            : () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const Login();
                }));
              },
        child: appBarTitle,
      ),
      actions: actions,
    );
    const drawer = MyDrawer();
    return getScaffold(
      context,
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: body,
      ),
      drawer: const SafeArea(child: drawer),
    );
  }
}
