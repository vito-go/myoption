import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


import '../service/model/model.dart';

//type lineChartData struct {
// 	Title     string           `json:"title"`
// 	SubTitle  string           `json:"subTitle"`
// 	FlSpots   []flSpot         `json:"flSpots,omitempty"`
// 	XTitleMap map[int64]string `json:"xTitleMap"` // 横坐标轴映射
// 	YTitleMap map[int64]string `json:"yTitleMap"` // 纵坐标轴映射
// }



class _LineChart extends StatelessWidget {
  final ChartLineData data;

  const _LineChart({required this.data});

  final double barWidth = 1; // 根据lines 动态调整

  @override
  Widget build(BuildContext context) {
    return LineChart(sampleData1);
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData(),
        baselineY: data.baselineY,
        // minX: 0,
        // maxX: 240,
        maxY: data.maxY,
        minY: data.minY,
      );

  /// Cover Default implementation for [LineTouchTooltipData.getTooltipItems].
  List<LineTooltipItem> getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final textStyle = TextStyle(
          color: touchedSpot.bar.gradient?.colors.first ??
              touchedSpot.bar.color ??
              Colors.blueGrey);
      String y = touchedSpot.y.toString();
      String x = data.xTitleMap[touchedSpot.x.toInt().toString()] ??
          touchedSpot.x.toString();
      if (data.xName != "" && data.yName != "") {
        return LineTooltipItem(
            "${data.xName}: $x\n${data.yName}: $y", textStyle,
            textAlign: TextAlign.start);
      }
      return LineTooltipItem("$x: $y", textStyle, textAlign: TextAlign.start);
    }).toList();
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.75),
            getTooltipItems: getTooltipItems,
            fitInsideHorizontally: true,
            fitInsideVertically: true),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        rightTitles: AxisTitles(sideTitles: rightTitles),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: leftTitles),
      );

  List<LineChartBarData> lineBarsData() {
    List<LineChartBarData> result = [];
    for (var i = 0; i < data.lineValues.length; i++) {
      result.add(lineChartBarData1(
        color: lineColors[i],
        spots: data.lineValues[i].flSpots,
      ));
    }
    return result;
  }

  // Y轴
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white);
    String valueText = value.toStringAsFixed(2);
    Text text = Text(valueText, style: style, textAlign: TextAlign.center);
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white);
    final valueText = value.toStringAsFixed(2);
    var y = data.yTitleMap[valueText] ??
        "${value > data.baselineY ? ' ' : ''}${((value / data.baselineY - 1) * 100.0).toStringAsFixed(2)}%";
    Text text = Text(y, style: style, textAlign: TextAlign.center);
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  SideTitles get leftTitles => SideTitles(
      getTitlesWidget: leftTitleWidgets, showTitles: true, reservedSize: 72);

  SideTitles get rightTitles => SideTitles(
      getTitlesWidget: rightTitleWidgets, showTitles: true, reservedSize: 72);

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xff72719b));
    Widget text;
    // web 版本必须用.toInt()才能和linux版本保持一致. linux: value 带一位小数 web 的value不带小数位
    text = Text(data.xTitleMap[value.toInt().toString()] ?? "",
        style: style, textAlign: TextAlign.center);
    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 37,
        interval: 60,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (double value) {
        if (value.toStringAsFixed(2) == data.baselineY.toStringAsFixed(2)) {
          return FlLine(
              strokeWidth: 1.5, color: Colors.blue, dashArray: [10, 0]);
        }
        return defaultGridLine(value);
      });

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData lineChartBarData1(
      {required Color color, required List<FlSpot> spots}) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: barWidth,
      show: true,
      isStrokeCapRound: true,
      dotData:
          FlDotData(checkToShowDot: (FlSpot spot, LineChartBarData barData) {
        return false;
      }),
      belowBarData: BarAreaData(show: false),
      aboveBarData: BarAreaData(show: false),
      spots: spots,
    );
  }
}

class LineChartSample extends StatefulWidget {
  const LineChartSample(
      {super.key, required this.chartLineData, required this.streamController, required this.symbolCode});

  final ChartLineData chartLineData;
  final String symbolCode;
  final StreamController<List<Product>> streamController;

  @override
  State<StatefulWidget> createState() => LineChartSampleState();
}

class LineChartSampleState extends State<LineChartSample> {
  late ChartLineData chartLineData = widget.chartLineData;
  late StreamSubscription? subscription;
  late String symbolCode = widget.symbolCode;

  @override
  void initState() {
    super.initState();
    subscription =
        widget.streamController.stream.listen((List<Product> data) {
      if (data.isEmpty) return;
      Product? ele;

      for (var i = 0; i < data.length; i++) {
        if (data[i].symbolCode == symbolCode) {
          ele = data[i];
          break;
        }
      }
      if (ele == null) return;
      if (chartLineData.lineValues.isEmpty) return;
      final line = chartLineData.lineValues[0];
      for (var i = line.flSpots.length - 1; i >= 0; i--) {
        final flSpot = line.flSpots[i];
        final int idx =
            chartLineData.xTitleIndexMap[ele.timeMin.toString()] ?? 150000;
        if (flSpot.x.toInt() >= idx) {
          chartLineData.lineValues[0].flSpots[i] = FlSpot(flSpot.x, ele.price);
        }
      }
      setState(() {});
      return;
    });
  }

  Widget getLegends() {
    List<Widget> children = [];
    for (var i = 0; i < chartLineData.lineValues.length; i++) {
      if (chartLineData.lineValues[i].tip == "") {
        continue;
      }
      children.add(
        Indicator(
            color: lineColors[i],
            text: chartLineData.lineValues[i].tip,
            isSquare: true),
      );
    }
    if (children.isEmpty) return const Text("");
    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 20,
      spacing: 20,
      children: children,
    );
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (chartLineData.title != "") {
      children.add(const SizedBox(height: 16));
      children.add(Text(chartLineData.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center));
    }
    if (chartLineData.subTitle != "") {
      children.add(const SizedBox(height: 16));
      children.add(Text(
        chartLineData.subTitle,
        style: const TextStyle(
          color: Color(0xff827daa),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ));
    }
    children.add(Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 22, left: 6, bottom: 10, top: 26),
        child: _LineChart(data: chartLineData),
      ),
    ));
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(0)),
        gradient: LinearGradient(
          colors: [
            Color(0xff2c274c),
            Color(0xff46426c),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

// lineColors的长度必须大于 [lines]
const List<Color> lineColors = [
  Color(0xff4af699),
  Colors.blue,
  Colors.yellow,
  Colors.green
];

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = Colors.white70,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
          color: color,
        ),
      ),
      const SizedBox(
        width: 4,
      ),
      SizedBox(
        width: 128,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      )
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 256, minWidth: 60),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
