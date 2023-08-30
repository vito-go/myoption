import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myoption/service/log_in.dart';

import '../service/model/model.dart';
import '../util/util.dart';
import '../widgets/loading_button.dart';
import '../widgets/restart_app.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  // const Register({Key? key}) : super(key: key);

  @override
  State createState() {
    return _Register();
  }
}

class _Register extends State {
  InputBorder enabledBorder =
      OutlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade200));
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController pwdAssureController = TextEditingController();
  bool pwdEye = true;
  final pwdFocus = FocusNode();
  final userIdFocus = FocusNode();
  final pwdAssureFocus = FocusNode();
  final InputBorder focusedBorder =
      const OutlineInputBorder(borderSide: BorderSide());

  String? clientCodeSelected;

  Future<bool> doRegister(
      BuildContext context, String clientCodeSelected) async {
    if (userIdController.text == "") {
      myToast(context, "账户号不能为空");
      userIdFocus.requestFocus();
      return false;
    }
    if (pwdController.text == "") {
      myToast(context, "密码不能为空");
      pwdFocus.requestFocus();
      return false;
    }
    if (pwdController.text != pwdAssureController.text) {
      myToast(context, "两次输入密码不匹配");
      pwdFocus.requestFocus();
      return false;
    }
    userIdFocus.unfocus();
    pwdFocus.unfocus();
    pwdAssureFocus.unfocus();
    return true;
  }

  bool agree = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> onPressed() async {
    String userId = userIdController.text;
    String pwd = pwdController.text;
    if (userId == "") {
      myToast(context, "帐号不能为空");
      return;
    }
    if (pwd == "") {
      myToast(context, "密码不能为空");
      return;
    }
    final success = await userLogIn(context, LoginAction.register,
        userId: userId, pwd: pwd);
    if (success) {
      if (context.mounted) {
        Navigator.pop(context);
        RestartApp.restart(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    late double maxWidth;
    if (platFormIsMobile()) {
      maxWidth = double.infinity;
    } else {
      maxWidth = MediaQuery.of(context).size.width * 0.5;
      if (maxWidth < 500) {
        maxWidth = 500;
      }
    }
    final editUserId = TextField(
      controller: userIdController,
      keyboardType: TextInputType.visiblePassword,
      inputFormatters: [
        LengthLimitingTextInputFormatter(16),
        FilteringTextInputFormatter(RegExp("[a-z0-9_]"), allow: true)
      ],
      maxLength: 16,
      focusNode: userIdFocus,
      decoration: InputDecoration(
        helperMaxLines: 2,
        helperText: ('必须以字母开头，只能包含字母、数字和下划线'),
        prefixIcon: const Icon(Icons.account_circle),
        labelText: ('帐号'),
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
    );
    final editPasswd = TextField(
      maxLength: 18,
      controller: pwdController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: pwdEye,
      focusNode: pwdFocus,
      // maxLength: 20,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        FilteringTextInputFormatter(RegExp("[A-Za-z0-9_@,.;<>]"), allow: true)
      ],

      decoration: InputDecoration(
        counterStyle: const TextStyle(color: Colors.red),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                pwdEye = !pwdEye;
              });
            },
            icon: const Icon(Icons.remove_red_eye_rounded)),
        labelText: ('密码'),
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
    );

    final editPasswdAssure = TextField(
      controller: pwdAssureController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: pwdEye,
      focusNode: pwdAssureFocus,
      maxLength: 18,
      inputFormatters: [
        LengthLimitingTextInputFormatter(18),
      ],
      decoration: InputDecoration(
        counterStyle: const TextStyle(color: Colors.red),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                pwdEye = !pwdEye;
              });
            },
            icon: const Icon(Icons.remove_red_eye_rounded)),
        labelText: ("请再次确认密码"),
        // counterText: ('请再次确认密码'),
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
    );
    final Widget bodyChild = ListView(
      children: <Widget>[
        // Center(child: dropdown),
        const SizedBox(height: 12),
        editUserId,
        const SizedBox(height: 12),
        editPasswd,
        const SizedBox(height: 12),
        editPasswdAssure,
        // privacy,
        const SizedBox(height: 12),
        MyButton(text: "注册", onPressed: onPressed)
      ],
    );

    final body = Container(
      padding: const EdgeInsets.all(10),
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: bodyChild,
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const Login();
                }));
              },
              child: const Text(
                '登录',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ))
        ],
        // toolbarHeight: Global.toolbarHeight,
      ),
      body: Center(child: body),
    );
  }
}
