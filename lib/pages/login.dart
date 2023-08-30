import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myoption/pages/register.dart';
import 'package:myoption/util/navigator.dart';
import 'package:myoption/widgets/restart_app.dart';

import '../service/log_in.dart';
import '../service/model/model.dart';
import '../util/util.dart';
import '../widgets/loading_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State createState() {
    return _Login();
  }
}

class _Login extends State {
  final InputBorder enabledBorder =
      OutlineInputBorder(borderSide: BorderSide(color: Colors.teal.shade200));
  TextEditingController userIdController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  bool pwdEye = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userIdController.dispose();
    pwdController.dispose();
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
    final success =
        await userLogIn(context, LoginAction.logIn, userId: userId, pwd: pwd);
    if (success) {
      if (context.mounted) {
        Navigator.pop(context);
        RestartApp.restart(context);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    InputBorder focusedBorder = OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor));

    double maxWidth = double.infinity;
    if (platFormIsMobile()) {
    } else {
      maxWidth = MediaQuery.of(context).size.width * 0.5;
      if (maxWidth < 500) {
        maxWidth = 500;
      }
    }

    final editUserId = TextField(
      controller: userIdController,
      keyboardType: TextInputType.name,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        FilteringTextInputFormatter(RegExp("[a-z0-9_]"), allow: true)
      ],
      decoration: InputDecoration(
        // counterText: "帐号",
        counterStyle: const TextStyle(color: Colors.red),
        prefixIcon: const Icon(Icons.account_circle),
        labelText: "帐号",
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
    );
    final editPasswd = TextField(
      controller: pwdController,
      keyboardType: TextInputType.visiblePassword,
      obscureText: pwdEye,
      // maxLength: 20,
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
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
        labelText: "密码",
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        focusedBorder: focusedBorder,
        enabledBorder: enabledBorder,
      ),
    );

    final Widget column = ListView(
      children: <Widget>[
        editUserId,
        const SizedBox(
          height: 15,
        ),
        editPasswd,
        const SizedBox(
          height: 15,
        ),
        // signInBtn,
        MyButton(text: "登陆", onPressed: onPressed)
      ],
    );
    final Container body = Container(
      padding: const EdgeInsets.all(10),
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: column,
    );
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  pushTo(context, const Register());
                },
                child: const Text(
                  "注册",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ))
          ],
        ),
        body: Center(child: body));
  }
}
