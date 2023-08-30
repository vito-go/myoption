import 'package:flutter/material.dart';
import 'package:myoption/pages/general_table.dart';
import 'package:myoption/pages/login.dart';
import 'package:myoption/pages/register.dart';
import 'package:myoption/util/navigator.dart';
import 'package:myoption/util/prefs/prefs.dart';
import 'package:myoption/util/sstorage/sstorage.dart';
import 'package:myoption/util/util.dart';
import 'package:myoption/widgets/restart_app.dart';

import '../service/model/model.dart';
import '../service/req_get_login.dart';
import '../util/global.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
  });

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

void aboutOnTap(BuildContext context) async {
  String version = Global.appVersion;
  if (context.mounted) {
    showAboutDialog(
      context: context,
      applicationName: Global.appConfig.appName,
      applicationIcon: InkWell(
        child: const FlutterLogo(),
        onTap: () async {},
      ),
      applicationVersion: "${Global.appConfig.clientName} version: $version",
      applicationLegalese: '© All rights reserved',
      children: [
        const SizedBox(
          height: 5,
        ),
        const Text("author:liushihao888@gmail.com"),
        const SizedBox(
          height: 2,
        ),
        const Text("address: Beijing, China"),
      ],
    );
  }
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
    initBalance();
  }

  Future<void> initBalance() async {
    if (Global.isLogin) {
      final respData = await reqMyBalance(context);
      if (respData.success) {
        setState(() {
          ss.setBalance(Global.getCurUserId, respData.data!.balance);
          balance = respData.data!.balance;
        });
      }
    }
  }

  int? balance;

  @override
  Widget build(BuildContext context) {
    String appBarTitle = Global.isLogin ? "@${Global.getCurUserId}" : "未登录";

    final Widget widgetBalance = Row(
      children: [
        const Text(
          "金币:  ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        balance != null
            ? Text(
                "$balance",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              )
            : const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
              ),
      ],
    );

    final ListView listView = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text("")),
                  IconButton(
                      onPressed: () {
                        switch (prefs.themeMode) {
                          case ThemeMode.system:
                            break;
                          case ThemeMode.light:
                            prefs.themeMode = ThemeMode.dark;
                            RestartApp.restart(context);
                            break;
                          case ThemeMode.dark:
                            prefs.themeMode = ThemeMode.light;
                            RestartApp.restart(context);
                            break;
                        }
                      },
                      icon: const Icon(
                        Icons.sunny,
                        color: Colors.white70,
                      ))
                ],
              ),
              InkWell(
                child: Text(
                  appBarTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!Global.isLogin) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return const Register();
                    }));
                  }
                },
              ),
              const SizedBox(height: 10),
              Global.isLogin ? widgetBalance : const Text(""),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.history),
          title: Text('交易历史'),
          onTap: () {
            Navigator.pop(context);
            if (!Global.isLogin) {
              pushTo(context, const Login());
              return;
            }
            pushTo(
                context,
                GeneralTable<TradeOrder>(
                  title: "交易历史",
                  getFiledNames: ss.getOrderListColumns,
                  setFiledNames: ss.setOrderListColumns,
                  reqDataList: reqOrderList,
                ));
            // TODO: Navigate to Transactions page
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('钱包明细'),
          onTap: () {
            Navigator.pop(context);
            if (!Global.isLogin) {
              pushTo(context, const Login());
              return;
            }
            pushTo(
                context,
                GeneralTable<WalletDetail>(
                  title: "钱包明细",
                  getFiledNames: ss.getKeyWalletDetails,
                  setFiledNames: ss.setKeyWalletDetails,
                  reqDataList: reqWalletDetails,
                ));
            // TODO: Navigate to Funds page
          },
        ),
        const Divider(),
        /*
       ListTile(
          leading: Icon(Icons.person),
          title: Text('个人资料'),
          onTap: () {
            myToast(context, "功能开发中,敬请期待");
            if (!Global.isLogin) {
              pushTo(context, const Login());
              return;
            }
            Navigator.pop(context);
            // TODO: Navigate to Profile page
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('账户管理'),
          onTap: () {
            myToast(context, "功能开发中,敬请期待");
            if (!Global.isLogin) {
              pushTo(context, const Login());
              return;
            }
            Navigator.pop(context);
            // TODO: Navigate to Settings page
          },
        ),
        ListTile(
          leading: Icon(Icons.help),
          title: Text('帮助与支持'),
          onTap: () {
            myToast(context, "功能开发中,敬请期待");
            if (!Global.isLogin) {
              pushTo(context, const Login());
              return;
            }
            Navigator.pop(context);
            // TODO: Navigate to Help & Support page
          },
        ),
        */
        ListTile(
          leading: Icon(Icons.info),
          title: const Text('关于'),
          onTap: () {
            Navigator.pop(context);
            aboutOnTap(context);
          },
        ),
        Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: !Global.isLogin
                    ? null
                    : () {
                        myPrint("${Global.isLogin} ${Global.getCurUserId}");
                        myPrint("退出登录");
                        Navigator.pop(context);
                        ss.logOut(Global.getCurUserId);
                        Global.getCurUserId = "";
                        RestartApp.restart(context);
                      },
                child: const Text("登  出"),
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
    // TODO 广告链接
    return Drawer(
      child: listView,
    );
  }
}
