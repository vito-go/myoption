import 'package:flutter/material.dart';
import 'package:myoption/util/util.dart';

class TradeRecordPage extends StatefulWidget {
  @override
  _TradeRecordPageState createState() => _TradeRecordPageState();
}

class _TradeRecordPageState extends State<TradeRecordPage> {
  final ScrollController _scrollController = ScrollController();
  final List<MonthlyTradeRecords> _monthlyTradeRecords = [];
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchTradeRecords();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchTradeRecords();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTradeRecords() async {
    // TODO: 发起网络请求获取交易记录数据，使用_offset和_limit作为参数
    List<TradeRecord> newTradeRecords = await fetchData(_offset, _limit);

    // 将新数据按照月份聚合
    List<MonthlyTradeRecords> newMonthlyTradeRecords = [];
    for (TradeRecord tradeRecord in newTradeRecords) {
      bool foundMonth = false;
      for (MonthlyTradeRecords monthlyTradeRecords in newMonthlyTradeRecords) {
        if (monthlyTradeRecords.month ==
            tradeRecord.orderTime.substring(0, 7)) {
          monthlyTradeRecords.tradeRecords.add(tradeRecord);
          foundMonth = true;
          break;
        }
      }
      if (!foundMonth) {
        MonthlyTradeRecords monthlyTradeRecords = MonthlyTradeRecords(
          month: tradeRecord.orderTime.substring(0, 7),
          tradeRecords: [tradeRecord],
        );
        newMonthlyTradeRecords.add(monthlyTradeRecords);
      }
    }

    setState(() {
      _monthlyTradeRecords.addAll(newMonthlyTradeRecords);
      _offset += _limit;
    });
  }

  bool expandedAll = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易记录'),
        actions: [
          IconButton(
              onPressed: () {
                myPrint(expandedAll);
                setState(() {
                  expandedAll = !expandedAll;
                });
                myPrint(expandedAll);
              },
              icon: const Icon(Icons.pan_tool))
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _monthlyTradeRecords.length,
        itemBuilder: (BuildContext context, int index) {
          MonthlyTradeRecords monthlyTradeRecords = _monthlyTradeRecords[index];
          return ExpansionTile(
            title: Text(monthlyTradeRecords.month),
            initiallyExpanded: expandedAll,
            children: monthlyTradeRecords.tradeRecords
                .map((tradeRecord) => ListTile(
                      title: Text(
                          '${tradeRecord.orderTime} - 金额: ${tradeRecord.amount}'),
                      subtitle: Text(
                          '订单状态: ${tradeRecord.orderStatus} - 商品价格: ${tradeRecord.productPrice}'),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class TradeRecord {
  final String orderStatus;
  final double productPrice;
  final double amount;
  final String orderTime;

  TradeRecord({
    required this.orderStatus,
    required this.productPrice,
    required this.amount,
    required this.orderTime,
  });
}

class MonthlyTradeRecords {
  final String month;
  final List<TradeRecord> tradeRecords;

  MonthlyTradeRecords({
    required this.month,
    required this.tradeRecords,
  });
}

// 模拟网络请求数据
Future<List<TradeRecord>> fetchData(int offset, int limit) async {
  await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求延迟

  List<TradeRecord> tradeRecords = [];

  // TODO: 根据offset和limit从服务器获取交易记录数据

  // 模拟生成测试数据
  for (int i = offset; i < offset + limit; i++) {
    TradeRecord tradeRecord = TradeRecord(
      orderStatus: '订单状态 $i',
      productPrice: (i + 1) * 10.0,
      amount: (i + 1) * 100.0,
      orderTime: '2022-${i % 12 + 1}-${i % 28 + 1}',
    );
    tradeRecords.add(tradeRecord);
  }

  return tradeRecords;
}
