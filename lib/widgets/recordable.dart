import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

import '../service/model/model.dart';

class DraggingList extends StatefulWidget {
  const DraggingList({Key? key, required this.filedNames, this.doneWithTitles})
      : super(key: key);
  final FiledNames filedNames;
  final void Function(FiledNames filedNames)? doneWithTitles;

  @override
  _DraggingListState createState() => _DraggingListState();
}

class _DraggingListState extends State<DraggingList> {
  final List<_ItemData> _items = [];
  late final FiledNames filedNames = widget.filedNames;

  List<String> get titles {
    return List.generate(_items.length, (index) => _items[index].field);
  }

  // Returns index of item with given key
  int _indexOfKey(Key key) {
    return _items.indexWhere((_ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    // Uncomment to allow only even target reorder possition
    // if (newPositionIndex % 2 == 1)
    //   return false;

    final draggedItem = _items[draggingIndex];
    setState(() {
      debugPrint("Reordering $item -> $newPosition");
      _items.removeAt(draggingIndex);
      filedNames.fields.removeAt(draggingIndex);
      _items.insert(newPositionIndex, draggedItem);
      filedNames.fields.insert(newPositionIndex, draggedItem.field);
    });
    return true;
  }

  void _reorderDone(Key item) {
    final draggedItem = _items[_indexOfKey(item)];
    debugPrint("Reordering finished for ${draggedItem.field}}");
    if (widget.doneWithTitles != null) {
      widget.doneWithTitles!(filedNames);
    }
  }

  //
  // Reordering works by having ReorderableList widget in hierarchy
  // containing ReorderableItems widgets
  //
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.filedNames.fields.length; ++i) {
      final label = widget.filedNames.fields[i];
      _items.add(_ItemData(
          label, widget.filedNames.fieldNameMap[label] ?? "", ValueKey(i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliverList = SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _Item(
            data: _items[index],
            // first and last attributes affect border drawn during dragging
            isFirst: index == 0,
            isLast: index == _items.length - 1,
          );
        },
        childCount: _items.length,
      ),
    );
    final customScrollView = CustomScrollView(
      // cacheExtent: 3000,
      slivers: <Widget>[
        SliverPadding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            sliver: sliverList),
      ],
    );
    return ReorderableList(
      onReorder: _reorderCallback,
      onReorderDone: _reorderDone,
      child: customScrollView,
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.data,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final _ItemData data;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;
    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    final Widget dragHandle = ReorderableListener(
      child: Container(
        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
        color: const Color(0x08000000),
        child: const Center(
          child: Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 14.0),
                    child: Text(data.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  )),
                  // Triggers the reordering
                  dragHandle,
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: data.key, //
        childBuilder: _buildChild);
  }
}

class _ItemData {
  _ItemData(this.field, this.name, this.key);

  final String field;
  final String name;

  // Each item in reorderable list needs stable and unique key
  final Key key;
}
