import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myoption/service/model/model.dart';
import 'package:myoption/widgets/bet_panel.dart';
import 'package:myoption/widgets/get_scaffold.dart';
import 'package:myoption/widgets/update_time_now.dart';

import '../util/global.dart';
import '../util/global_event.dart';
import '../util/init_sse.dart';
import '../widgets/line_chart.dart';
import '../widgets/reconnect.dart';

class IndexChart extends StatefulWidget {
  final String symbolCode;
  final String symbolName;
  final StreamController<List<Product>> streamController;
  final ChartLineData chartLineData;
  final List<Widget>? actions;

  const IndexChart(
      {super.key,
      required this.chartLineData,
      required this.streamController,
      required this.symbolCode,
      required this.symbolName,
      this.actions});

  @override
  State<StatefulWidget> createState() {
    return IndexChartState();
  }
}

class IndexChartState extends State<IndexChart> {
  late final streamController = widget.streamController;
  late final symbolCode = widget.symbolCode;
  late final symbolName = widget.symbolName;
  late final chartLineData = widget.chartLineData;

  @override
  void initState() {
    super.initState();
    globalEventSubscription = subscriptGlobalEvent(globalEventHandler);
  }

  void globalEventHandler(GlobalEvent event) {
    switch (event.eventType) {
      case GlobalEventType.dataNetworkChange:
        setState(() {});
        break;
      case GlobalEventType.timeNow:
        setState(() {});
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    globalEventSubscription?.cancel();
  }

  StreamSubscription<GlobalEvent>? globalEventSubscription;

  @override
  Widget build(BuildContext context) {
    final chart = LineChartSample(
        chartLineData: chartLineData,
        streamController: streamController,
        symbolCode: symbolCode);

    final List<Widget> children = [];

    if (!Global.dataNetwork) {
      children.add(const SizedBox(height: 5));
      children.add(const Center(child: ReConnect(onPressed: initSSS)));
    }
    children.add(const SizedBox(height: 5));
    children.add(const ShowUpdateTimeNow());
    children.add(const SizedBox(height: 5));

    children.add(Expanded(child: chart));
    children.add(BetPanel(
        pop: false,
        streamController: streamController,
        symbolCode: symbolCode,
        symbolName: symbolName));
    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.center, children: children);
    return getScaffold(
      context,
      body: body,
      appBar: AppBar(
        title: Text("$symbolName($symbolCode)"),
        actions: widget.actions,
      ),
    );
  }
}
