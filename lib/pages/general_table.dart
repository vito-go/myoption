import 'package:flutter/material.dart';
 import 'package:myoption/util/util.dart';
import 'package:myoption/widgets/get_scaffold.dart';
import 'package:myoption/widgets/recordable.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../service/model/model.dart';
import '../util/navigator.dart';

class GeneralTable<T extends JsonSerializable> extends StatefulWidget {
  const GeneralTable(
      {super.key,
      required this.getFiledNames,
      required this.setFiledNames,
      required this.reqDataList,
      required this.title});

  final String title;
  final Future<FiledNames> Function() getFiledNames;
  final Future<void> Function(FiledNames) setFiledNames;
  final Future<RespData<GenericData<T>>>Function(BuildContext context,
      {required int offset, required int limit}) reqDataList;

  @override
  _OrderListPageState<T> createState() => _OrderListPageState();
}

class _OrderListPageState<T extends JsonSerializable>
    extends State<GeneralTable> {
  final ScrollController _scrollController = ScrollController();

  int _offset = 0;
  final int _limit = 20;

  ValueNotifier<Widget> valueNotifierLoading = ValueNotifier(const Text(""));
  bool haseMore = true;

  FiledNames get filedNames => orderListDate.filedNames;

  set filedNames(FiledNames f) {
    orderListDate.filedNames = f;
  }

  OrderListDate<T> orderListDate =
      OrderListDate(orders: [], filedNames: FiledNames());

  List<String> get titles => filedNames.fields;

  List<GridColumn> get columns => orderListDate.columns;

  Map<String, dynamic> get titleNameMap => filedNames.fieldNameMap;

  List<String> get titleNames => List.generate(
      titles.length, (index) => titleNameMap[titles[index]].toString());
  final tablePadding =
      const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5);
  Key keySfDataGrid = Key(DateTime.now().microsecondsSinceEpoch.toString());

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    actions.add(IconButton(
        tooltip: "重置标题栏宽度",
        onPressed: () async {
          orderListDate.filedNames.fieldWidthMap = {};
          widget.setFiledNames(orderListDate.filedNames);
          setState(() {});
          myToast(context, "标题栏宽度已重置");
          return;
        },
        icon: const Icon(Icons.width_normal_outlined)));
    actions.add(IconButton(
        tooltip: "调整标题栏顺序",
        onPressed: () async {
          final pageColumns = getScaffold(context,
              appBar: AppBar(
                title: const Text("调整标题栏顺序"),
              ),
              body: DraggingList(
                doneWithTitles: (fs) {
                  setState(() {
                    filedNames = fs;
                    keySfDataGrid =
                        Key(DateTime.now().microsecondsSinceEpoch.toString());
                    widget.setFiledNames(fs);
                  });
                },
                filedNames: filedNames,
              ));
          pushTo(context, pageColumns);
          return;
        },
        icon: const Icon(Icons.reorder)));

    final body = SfDataGrid(
      key: keySfDataGrid,
      source: orderListDate,
      columnWidthMode: ColumnWidthMode.auto,
      columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
      allowColumnsResizing: true,
      onColumnResizeEnd: (detail) {
        myPrint(detail.column.label);
        widget.setFiledNames(orderListDate.filedNames);
      },
      onColumnResizeUpdate: (details) {
        myPrint(details);
        setState(() {
          myPrint(details);
          orderListDate.filedNames.fieldWidthMap[details.column.columnName] =
              details.width;
        });
        return true;
      },
      columns: orderListDate.columns,
      selectionMode: SelectionMode.singleDeselect,
    );

    return getScaffold(
      context,
      noMobileWidthRate: 0.65,
      appBar: AppBar(
        title: Text(widget.title),
        actions: actions,
      ),
      body: Column(
        children: [
          Expanded(child: body),
          ValueListenableBuilder(
              valueListenable: valueNotifierLoading,
              builder: (BuildContext context, Widget value, Widget? child) {
                return value;
              }),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    initTitles().then((_) => {
          _loadTransactions().then((_) {
            if (haseMore) {
              valueNotifierLoading.value = _buildLoaderButton();
            } else {
              valueNotifierLoading.value = _buildNoMoreMore();
            }
          })
        });
  }

  Future<void> initTitles() async {
    final value = await widget.getFiledNames();
    if (value.fields.isNotEmpty) {
      setState(() {
        filedNames = value;
      });
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
    valueNotifierLoading.dispose();
    _scrollController.dispose();
  }

  Widget _buildNoMoreMore() {
    return Container(
      // padding: const EdgeInsets.only(top: 15, bottom: 15),
      height: 50,

      alignment: Alignment.center,
      child: Row(children: const <Widget>[
        Expanded(child: Divider(height: 2)),
        SizedBox(
          width: 10,
        ),
        Text(
          '没有更多了',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(child: Divider(height: 2)),
      ]),
    );
  }

  Widget _buildLoader() {
    return Container(
      // padding: const EdgeInsets.only(bottom: 10),
      height: 50,

      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  void _scrollListener() {
    if (!haseMore) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadTransactions();
    }
  }

  Widget _buildLoaderButton() {
    return Container(
      // padding: const EdgeInsets.all(10.0),
      height: 50,
      alignment: Alignment.center,
      child: ElevatedButton(
          onPressed: () {
            _loadTransactions();
          },
          child: const Text("加载更多")),
    );
  }

  Future<void> _loadTransactions() async {
    // Simulate API request to get transactions
    // Replace this with your actual API call
    valueNotifierLoading.value = _buildLoader();
    final respData =
        await widget.reqDataList(context, offset: _offset, limit: _limit);
    if (respData.code != 0) return;
    // Generate dummy transactions
    if (respData.data!.orders.isEmpty) {
      myToast(context, "没有更多了");
      haseMore = false;
      myPrint("--------");
      valueNotifierLoading.value = _buildNoMoreMore();
      return;
    }
    orderListDate.orders.addAll(respData.data!.orders as Iterable<T>);
    respData.data!.fieldNames.fieldNameMap =
        respData.data!.fieldNames.fieldNameMap;
    if (titles.isEmpty) {
      filedNames = respData.data!.fieldNames;
    }
    // 剔除
    final setCols = respData.data!.fieldNames.fields.toSet();
    final List<String> filedNew = [];
    for (var element in filedNames.fields) {
      if (setCols.contains(element)) {
        filedNew.add(element);
      }
    }
    orderListDate.filedNames.fields = filedNew;

    _offset += _limit;
    orderListDate =
        OrderListDate(filedNames: filedNames, orders: orderListDate.orders);
    setState(() {});
    if (haseMore) {
      valueNotifierLoading.value = _buildLoaderButton();
    }
  }
}


class OrderListDate<T extends JsonSerializable> extends DataGridSource {
  FiledNames filedNames = FiledNames();
  List<T> orders = [];

  Map<String, dynamic> get colWidthMap => filedNames.fieldWidthMap;

  OrderListDate({required this.filedNames, required this.orders});

  double getWidthByFiled(String filed) {
    final width = colWidthMap[filed];
    if (width is! double) return double.nan;
    if (width <= 0) return double.nan;
    return width;
  }

  List<GridColumn> get columns =>
      // filedNames.fields
      filedNames.fields.isEmpty
          ? []
          : List.generate(
              filedNames.fields.length + 1,
              (index) => index == 0
                  ? GridColumn(
                      width: double.nan,
                      columnName: "id",
                      label: Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 10),
                          child: const Text(
                            'ID',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )))
                  : GridColumn(
                      width: getWidthByFiled(filedNames.fields[index - 1]),
                      columnName: filedNames.fields[index - 1],
                      label: Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            filedNames.fieldNameMap[
                                    filedNames.fields[index - 1]] ??
                                '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))));

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> dataRows = [];
    for (var i = 0; i < orders.length; i++) {
      final order = orders[i];
      List<DataGridCell> cells = [
        DataGridCell<String>(columnName: 'id', value: (i + 1).toString())
      ];
      final orderJson = order.toJson();
      for (var col in filedNames.fields) {
        cells.add(DataGridCell<String>(
            columnName: filedNames.fieldNameMap[col] ?? '',
            value: orderJson[col] ?? ''));
      }
      dataRows.add(DataGridRow(cells: cells));
    }
    // _employeeData = dataRows;
    return dataRows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      // return Align(child: Text(e.value.toString()),alignment: AlignmentDirectional.center,);
      return Container(
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.center,
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
