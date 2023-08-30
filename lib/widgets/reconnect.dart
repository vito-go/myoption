import 'package:flutter/material.dart';
import 'package:myoption/util/util.dart';

class ReConnect extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final String text;

  const ReConnect({Key? key, required this.onPressed, this.text = "网络错误，点击重试"})
      : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<ReConnect> {
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
    final int start = DateTime.now().millisecondsSinceEpoch;
    try {
      await onPressed!();
    } catch (_) {}
    int delayed = 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - start;
    if (elapsed < 150) {
      // 需要150毫秒的时间以显示加载效果
      delayed = 150 - elapsed;
    }
    myPrint("-----elapsed $elapsed----- delayed: $delayed");
    Future.delayed(Duration(milliseconds: delayed), () {
      setState(() {
        isLoading = false;
      });
    });
    myPrint("函数执行结束");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.75),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                height: 20,
                width: 20,
                child: isLoading
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Colors.red,
                      )),
            const SizedBox(width: 5),
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
