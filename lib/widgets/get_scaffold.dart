import 'package:flutter/material.dart';
import 'package:myoption/util/util.dart';

Widget getScaffold(BuildContext context,
    {required Widget body,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    double noMobileWidthRate = 0.5}) {
  if (platFormIsMobile()) {
    return Scaffold(
      body: body,
      appBar: appBar,
      drawer: drawer,
    );
  }

  double mediaWidth = MediaQuery.of(context).size.width;
  double width = double.infinity;
  if (mediaWidth > 750) {
    width = mediaWidth * noMobileWidthRate;
    if (width < 750) {
      width = 750;
    }
  }
  return Scaffold(
    body: Center(
      child: SizedBox(
        width: width,
        child: body,
      ),
    ),
    appBar: appBar,
    drawer: drawer,
  );
}
