import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:myoption/util/global_event.dart';
import 'package:myoption/widgets/reconnect.dart';

import '../pages/types.dart';
import '../util/global.dart';

class ShowUpdateTimeNow extends StatefulWidget {
  const ShowUpdateTimeNow({super.key});

  @override
  State<StatefulWidget> createState() {
    return ShowUpdateTimeNowState();
  }
}

class ShowUpdateTimeNowState extends State<ShowUpdateTimeNow> {
  int? now;
  Timer? timerNowPeriodic;

  @override
  void initState() {
    super.initState();
    timerNowPeriodic = Timer.periodic(const Duration(seconds: 1), (timer) {
      now = Global.correctedTime();
      setState(() {});
    });
    now = Global.correctedTime();
  }

  @override
  void dispose() {
    super.dispose();
    timerNowPeriodic?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final nowInt = now;
    return nowInt == null
        ? SizedBox(
            height: 36,
            child: Center(
              child: ReConnect(
                onPressed: () async {
                  final result = await Global.initGeneralConfigData();
                  if (result) {
                    addToGlobalEvent(GlobalEvent(
                        eventType: GlobalEventType.timeNow, param: null));
                    setState(() {});
                  }
                },
                text: "同步时间",
              ),
            ),
          )
        : SizedBox(
            height: 36,
            child: Center(
                child: Text(
              DateFormat(timeFormatSec)
                  .format(DateTime.fromMillisecondsSinceEpoch(nowInt)),
              style: const TextStyle(fontSize: 18),
            )),
          );
  }
}
