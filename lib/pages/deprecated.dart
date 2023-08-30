import 'package:flutter/material.dart';

class Deprecated {
  ValueNotifier<String> valueNotifier = ValueNotifier("向右滑动提交订单");
  ValueNotifier<Widget> valueNotifierFeedBack =
      ValueNotifier(const CircleAvatar(
    child: Icon(Icons.swipe_right),
  ));

  String get slideToSubmit => "向右滑动提交订单";

  String get releaseToSubmit => "松手提交订单";

  Row getRowSlide() {
    return Row(
      children: [
        SizedBox(
          width: 50,
        ),
        Draggable(
          onDragUpdate: (detail) {
            print(detail.globalPosition);
          },
          data: 1,
          childWhenDragging: const CircleAvatar(
            backgroundColor: Colors.transparent,
          ),
          axis: Axis.horizontal,
          feedback: ValueListenableBuilder(
              valueListenable: valueNotifierFeedBack,
              builder: (BuildContext context, Widget value, Widget? child) {
                return value;
              }),
          child: CircleAvatar(
            child: Icon(Icons.swipe_right),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
            child: ValueListenableBuilder(
                valueListenable: valueNotifier,
                builder: (BuildContext context, String value, Widget? child) {
                  return Text(value);
                })),
        DragTarget(
          builder: (BuildContext context, List<Object?> candidateData,
              List<dynamic> rejectedData) {
            if (candidateData.isEmpty) {
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.done,
                  color: Colors.white70,
                ),
              );
            }

            return const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.done,
                color: Colors.white,
              ),
            );
          },
          onWillAccept: (color) {
            valueNotifier.value = releaseToSubmit;
            valueNotifierFeedBack.value = const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.done,
                color: Colors.white,
              ),
            );
            return true;
          },
          onAccept: (color) {
            valueNotifier.value = slideToSubmit;
            valueNotifierFeedBack.value = CircleAvatar(
              child: Icon(Icons.swipe_right),
            );
          },
          onLeave: (color) {
            valueNotifier.value = slideToSubmit;
            valueNotifierFeedBack.value = const CircleAvatar(
              child: Icon(Icons.swipe_right),
            );
          },
        ),
      ],
    );
  }
}
