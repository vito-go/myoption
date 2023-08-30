import 'package:flutter/material.dart';
import 'package:myoption/util/util.dart';

enum ButtonStyleBtn {
  elevatedButton,
  outlineButton,
}

class MyButton extends StatefulWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final ButtonStyleBtn buttonStyleBtn;
  final Color progressColor;

  const MyButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonStyleBtn = ButtonStyleBtn.elevatedButton,
    this.progressColor = Colors.white,
  }) : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isLoading = false;
  late final onPressed = widget.onPressed;

  Future<void> onPress() async {
    if (onPressed == null) return;
    if (isLoading) return;
    myPrint("loading begin");
    setState(() {
      isLoading = true;
    });
    myPrint("loading done");
    await onPressed!();
    myPrint("函数执行结束");
    setState(() {
      isLoading = false;
    });
  }

  late final SizedBox sizedBoxProgress = SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      // color: widget.progressColor,
      valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
    ),
  );
  late final SizedBox sizedBoxText = SizedBox(
    // width: 20,
    height: 20,
    child: Text(widget.text),
  );

  @override
  Widget build(BuildContext context) {
    switch (widget.buttonStyleBtn) {
      case ButtonStyleBtn.elevatedButton:
        return ElevatedButton(
          onPressed: onPress,
          child: isLoading ? sizedBoxProgress : Text(widget.text),
        );
      case ButtonStyleBtn.outlineButton:
        return OutlinedButton(
          onPressed: onPress,
          child: isLoading ? sizedBoxProgress : Text(widget.text),
        );
    }
  }
}
