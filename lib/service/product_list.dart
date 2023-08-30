import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:myoption/service/req_get.dart';
import 'package:myoption/util/global.dart';
import 'package:myoption/util/util.dart';

import 'dio_try.dart';
import 'model/model.dart';

Future<RespData<ProductData>> reqProductList(BuildContext context) async {
  return dioTryGet(context, Global.apiHost.productList,
      fromJson: ProductData.fromJson);
}


// 假设客户端发出请求时本地时间为now1，服务器时间为updateTime，客户端收到服务响应时本地时间为now2，时间校准同步方案如下：
//
// 在客户端发出请求时，将本地时间now1一并发送到服务器。
//
// 在服务器端收到请求后，将服务器当前时间updateTime和客户端发送的本地时间now1打包成响应数据，一并返回给客户端。
//
// 在客户端收到服务响应后，记录下本地时间now2，计算出客户端与服务器之间的时间差deltaTime，即：
//
// deltaTime = (now2 - now1) - (updateTime - now1)
//
// 其中，(now2 - now1)表示客户端请求和响应的网络延迟，(updateTime - now1)表示服务器与客户端发送请求的时间差。
//
// 将时间差deltaTime应用到本地时间now2上，即可校准本地时间，得到校准后的时间：
// correctedTime = now2 - deltaTime
//
// 需要注意的是，由于时间校准过程中可能会出现网络延迟、时钟漂移等因素，因此为了提高校准的准确性，可以多次进行时间校准，或者使用更为精确的时间同步协议，例如NTP（网络时间协议）。

Future<RespData<GeneralConfigData>> reqGeneralConfig(BuildContext? context) async {
  return dioTryGet(context, Global.apiHost.generalConfig,
      fromJson: GeneralConfigData.fromJson);
}
