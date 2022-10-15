import 'package:flutter/material.dart';
import 'package:horopic/hostconfigure/lskyproconfig.dart';
import 'package:horopic/hostconfigure/smmsconfig.dart';
import 'package:horopic/hostconfigure/PShostSelect.dart';
import 'package:horopic/hostconfigure/githubconfig.dart';
import 'package:horopic/hostconfigure/tencentconfig.dart';
import 'package:horopic/hostconfigure/upyunconfig.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/utils/global.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:dio/dio.dart';
import 'package:horopic/pages/loading.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:horopic/hostconfigure/Imgurconfig.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';
import 'package:horopic/hostconfigure/qiniuconfig.dart';
import 'package:horopic/api/qiniu.dart';
import 'package:flutter/services.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:horopic/api/tencent.dart';
import 'package:crypto/crypto.dart';
import 'package:horopic/hostconfigure/aliyunconfig.dart';
import 'package:path/path.dart' as mypath;

//a configure page for user to show configure entry
class AllPShost extends StatefulWidget {
  const AllPShost({Key? key}) : super(key: key);

  @override
  _AllPShostState createState() => _AllPShostState();
}

class _AllPShostState extends State<AllPShost> {
  _scan() async {
    try {
      final result = await BarcodeScanner.scan(
          options: const ScanOptions(
        strings: {
          "cancel": "取消",
          "flash_on": "打开闪光灯",
          "flash_off": "关闭闪光灯",
        },
        restrictFormat: [BarcodeFormat.qr],
        android: AndroidOptions(
          aspectTolerance: 0.00,
          useAutoFocus: true,
        ),
        autoEnableFlash: false,
      ));
      setState(() {
        Global.qrScanResult = result.rawContent.toString();
      });
    } catch (e) {
      setState(() {
        Global.qrScanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.toString(),
        ).rawContent;
      });
    }
  }

  //smms配置
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get smmsFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_smms_config.txt');
  }

//lskypro配置
  Future<File> get lskyFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
  }

//github配置
  Future<File> get githubFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_github_config.txt');
  }

  //imgur配置
  Future<File> get imgurFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_imgur_config.txt');
  }

  //qiniu配置
  Future<File> get qiniuFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_qiniu_config.txt');
  }

  //tencent配置
  Future<File> get tencentFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_tencent_config.txt');
  }

  //aliyun配置
  Future<File> get aliyunFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_aliyun_config.txt');
  }

  //upyun配置
  Future<File> get upyunFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_upyun_config.txt');
  }

  exportConfiguration(String pshost) async {
    try {
      String configPath = await _localPath;
      String defaultUser = await Global.getUser();
      Map<String, dynamic> configFilePath = {
        "smms": "$configPath/${defaultUser}_smms_config.txt",
        "lankong": "$configPath/${defaultUser}_host_config.txt",
        "github": "$configPath/${defaultUser}_github_config.txt",
        "imgur": "$configPath/${defaultUser}_imgur_config.txt",
        "qiniu": "$configPath/${defaultUser}_qiniu_config.txt",
        "tcyun": "$configPath/${defaultUser}_tencent_config.txt",
        "aliyun": "$configPath/${defaultUser}_aliyun_config.txt",
        "upyun": "$configPath/${defaultUser}_upyun_config.txt",
      };
      String config = await File(configFilePath[pshost]!).readAsString();
      Map<String, dynamic> configMap = jsonDecode(config);
      Map configMap2 = {pshost: configMap};
      String configJson = jsonEncode(configMap2);
      configJson = configJson.replaceAll('None', '');
      configJson = configJson.replaceAll('keyId', 'accessKeyId');
      configJson = configJson.replaceAll('keySecret', 'accessKeySecret');
      await Clipboard.setData(ClipboardData(text: configJson));
      Fluttertoast.showToast(
          msg: "$pshost配置已复制到剪贴板",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "导出失败",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }

  processingQRCodeResult() async {
    String result = Global.qrScanResult;
    Global.qrScanResult = "";
    if (!(result.contains('smms')) &&
        !(result.contains('github')) &&
        !(result.contains('lankong')) &&
        !(result.contains('imgur')) &&
        !(result.contains('qiniu')) &&
        !(result.contains('tcyun')) &&
        !(result.contains('aliyun')) &&
        !(result.contains('upyun'))) {
      return Fluttertoast.showToast(
          msg: "不包含支持的图床配置信息",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
    Map<String, dynamic> jsonResult = jsonDecode(result);

    if (jsonResult['smms'] != null) {
      final smmsToken = jsonResult['smms']['token'];
      try {
        List sqlconfig = [];
        sqlconfig.add(smmsToken);
        String defaultUser = await Global.getUser();
        sqlconfig.add(defaultUser);
        var querysmms = await MySqlUtils.querySmms(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);
        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        String validateURL = "https://smms.app/api/v2/profile";
        // String validateURL = "https://sm.ms/api/v2/profile";被墙了
        BaseOptions options = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        options.headers = {
          "Content-Type": 'multipart/form-data',
          "Authorization": smmsToken,
        };
        //需要加一个空的formdata，不然会报错
        FormData formData = FormData.fromMap({});
        Dio dio = Dio(options);
        String sqlResult = '';
        try {
          var validateResponse = await dio.post(validateURL, data: formData);
          if (validateResponse.statusCode == 200 &&
              validateResponse.data['success'] == true) {
            if (querysmms == 'Empty') {
              sqlResult = await MySqlUtils.insertSmms(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateSmms(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final smmsConfig = SmmsConfigModel(smmsToken);
              final smmsConfigJson = jsonEncode(smmsConfig);
              final smmsConfigFile = await smmsFile;
              await smmsConfigFile.writeAsString(smmsConfigJson);
              Fluttertoast.showToast(
                  msg: "smms配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "smms数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "Smms验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "SM.MS配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['github'] != null) {
      try {
        String token = jsonResult['github']['token'];
        String githubUserApi = 'https://api.github.com/user';
        String usernameRepo = jsonResult['github']['repo'];
        String githubusername =
            usernameRepo.substring(0, usernameRepo.indexOf('/'));
        String repo = usernameRepo.substring(usernameRepo.indexOf('/') + 1);
        String storePath = jsonResult['github']['path'];
        if (storePath == null || storePath == '' || storePath.isEmpty) {
          storePath = 'None';
        } else if (!storePath.endsWith('/')) {
          storePath = '$storePath/';
        }
        String branch = jsonResult['github']['branch'];
        if (branch == '' || branch == null || branch.isEmpty) {
          branch = 'main';
        }
        String customDomain = jsonResult['github']['customUrl'];
        if (customDomain == '' ||
            customDomain == null ||
            customDomain.isEmpty) {
          customDomain = 'None';
        }
        if (customDomain != 'None') {
          if (!customDomain.startsWith('http') &&
              !customDomain.startsWith('https')) {
            customDomain = 'http://$customDomain';
          }
          if (customDomain.endsWith('/')) {
            customDomain = customDomain.substring(0, customDomain.length - 1);
          }
        }

        if (token.startsWith('Bearer ')) {
        } else {
          token = 'Bearer $token';
        }

        try {
          List sqlconfig = [];
          sqlconfig.add(githubusername);
          sqlconfig.add(repo);
          sqlconfig.add(token);
          sqlconfig.add(storePath);
          sqlconfig.add(branch);
          sqlconfig.add(customDomain);
          //添加默认用户
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);

          var queryGithub = await MySqlUtils.queryGithub(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);

          if (queryuser == 'Empty') {
            Fluttertoast.showToast(
                msg: "请先登录",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
          BaseOptions options = BaseOptions(
            //连接服务器超时时间，单位是毫秒.
            connectTimeout: 30000,
            //响应超时时间。
            receiveTimeout: 30000,
            sendTimeout: 30000,
          );
          options.headers = {
            "Accept": 'application/vnd.github+json',
            "Authorization": token,
          };
          //需要加一个空的formdata，不然会报错
          Map<String, dynamic> queryData = {};
          Dio dio = Dio(options);
          String sqlResult = '';
          try {
            var validateResponse =
                await dio.get(githubUserApi, queryParameters: queryData);
            if (validateResponse.statusCode == 200 &&
                validateResponse.data.toString().contains("email")) {
              //验证成功
              if (queryGithub == 'Empty') {
                sqlResult = await MySqlUtils.insertGithub(content: sqlconfig);
              } else {
                sqlResult = await MySqlUtils.updateGithub(content: sqlconfig);
              }
              if (sqlResult == "Success") {
                final githubConfig = GithubConfigModel(githubusername, repo,
                    token, storePath, branch, customDomain);
                final githubConfigJson = jsonEncode(githubConfig);
                final githubConfigFile = await githubFile;
                await githubConfigFile.writeAsString(githubConfigJson);
                Fluttertoast.showToast(
                    msg: "Github配置成功",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              } else {
                Fluttertoast.showToast(
                    msg: "Github数据库错误",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Github验证失败",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } catch (e) {
            Fluttertoast.showToast(
                msg: "Github验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Github配置错误",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Github配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      if (jsonResult['lankong'] != null) {
        try {
          String lankongVersion = jsonResult['lankong']['lskyProVersion'];
          if (lankongVersion == 'V2') {
            String lankongVtwoHost = jsonResult['lankong']['server'];
            if (lankongVtwoHost.endsWith('/')) {
              lankongVtwoHost =
                  lankongVtwoHost.substring(0, lankongVtwoHost.length - 1);
            }
            String lankongToken = jsonResult['lankong']['token'];
            if (lankongToken.startsWith('Bearer ')) {
            } else {
              lankongToken = 'Bearer $lankongToken';
            }
            String lanKongstrategyId = jsonResult['lankong']['strategyId'];
            if (lanKongstrategyId == '' ||
                lanKongstrategyId == null ||
                lanKongstrategyId.isEmpty) {
              lanKongstrategyId = 'None';
            }

            BaseOptions options = BaseOptions(
              //连接服务器超时时间，单位是毫秒.
              connectTimeout: 30000,
              //响应超时时间。
              receiveTimeout: 30000,
              sendTimeout: 30000,
            );
            options.headers = {
              "Accept": "application/json",
              "Authorization": lankongToken,
            };
            String profileUrl = "$lankongVtwoHost/api/v1/profile";
            Dio dio = Dio(options);

            String sqlResult = '';
            try {
              var response = await dio.get(
                profileUrl,
              );
              if (response.statusCode == 200 &&
                  response.data['status'] == true) {
                try {
                  List sqlconfig = [];
                  sqlconfig.add(lankongVtwoHost);
                  sqlconfig.add(lanKongstrategyId.toString());
                  sqlconfig.add(lankongToken);
                  String defaultUser = await Global.getUser();
                  sqlconfig.add(defaultUser);

                  var querylankong =
                      await MySqlUtils.queryLankong(username: defaultUser);
                  var queryuser =
                      await MySqlUtils.queryUser(username: defaultUser);

                  if (queryuser == 'Empty') {
                    Fluttertoast.showToast(
                        msg: "请先登录",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0);
                  } else if (querylankong == 'Empty') {
                    sqlResult =
                        await MySqlUtils.insertLankong(content: sqlconfig);
                  } else {
                    sqlResult =
                        await MySqlUtils.updateLankong(content: sqlconfig);
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "LanKong数据库错误",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
                if (sqlResult == "Success") {
                  HostConfigModel hostConfig = HostConfigModel(
                      lankongVtwoHost, lankongToken, lanKongstrategyId);
                  final hostConfigJson = jsonEncode(hostConfig);
                  final hostConfigFile = await lskyFile;
                  hostConfigFile.writeAsString(hostConfigJson);

                  Fluttertoast.showToast(
                      msg: "LanKong配置成功",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                } else {
                  Fluttertoast.showToast(
                      msg: "LanKong数据库错误",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
              } else {
                Fluttertoast.showToast(
                    msg: "LanKong验证失败",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              }
            } catch (e) {
              Fluttertoast.showToast(
                  msg: "LanKong配置错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "不支持兰空V1",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: "兰空配置错误",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      }
    }

    if (jsonResult['imgur'] != null) {
      final imgurclientId = jsonResult['imgur']['clientId'];
      String imgurProxy = jsonResult['imgur']['proxy'];
      if (imgurProxy.isEmpty || imgurProxy == null) {
        imgurProxy = 'None';
      }
      try {
        List sqlconfig = [];
        sqlconfig.add(imgurclientId);
        sqlconfig.add(imgurProxy);
        String defaultUser = await Global.getUser();
        sqlconfig.add(defaultUser);

        var queryimgur = await MySqlUtils.queryImgur(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        String baiduPicUrl =
            "https://dss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white-d0c9fe2af5.png";
        String validateURL = "https://api.imgur.com/3/image";

        BaseOptions options = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        options.headers = {
          "Authorization": "Client-ID $imgurclientId",
        };
        //需要加一个空的formdata，不然会报错
        FormData formData = FormData.fromMap({
          "image": baiduPicUrl,
        });
        Dio dio = Dio(options);
        String proxyClean = '';

        if (imgurProxy != 'None') {
          if (imgurProxy.startsWith('http://') ||
              imgurProxy.startsWith('https://')) {
            proxyClean = imgurProxy.split('://')[1];
          } else {
            proxyClean = imgurProxy;
          }
          dio.useProxy(proxyClean);
        }

        String sqlResult = '';
        try {
          var validateResponse = await dio.post(validateURL, data: formData);
          if (validateResponse.statusCode == 200 &&
              validateResponse.data['success'] == true) {
            if (queryimgur == 'Empty') {
              sqlResult = await MySqlUtils.insertImgur(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateImgur(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final imgurConfig = ImgurConfigModel(imgurclientId, imgurProxy);
              final imgurConfigJson = jsonEncode(imgurConfig);
              final imgurConfigFile = await smmsFile;
              await imgurConfigFile.writeAsString(imgurConfigJson);
              Fluttertoast.showToast(
                  msg: "Imgur配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "Imgur数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "Imgur验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Imgur配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['qiniu'] != null) {
      String qiniuAccessKey = jsonResult['qiniu']['accessKey'];
      String qiniuSecretKey = jsonResult['qiniu']['secretKey'];
      String qiniuBucket = jsonResult['qiniu']['bucket'];
      String qiniuUrl = jsonResult['qiniu']['url'];
      String qiniuArea = jsonResult['qiniu']['area'];
      String qiniuOptions = jsonResult['qiniu']['options'];
      String qiniuPath = jsonResult['qiniu']['path'];

      try {
        String defaultUser = await Global.getUser();
        var queryqiniu = await MySqlUtils.queryQiniu(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }

        if (!qiniuUrl.startsWith('http') && !qiniuUrl.startsWith('https')) {
          qiniuUrl = 'http://$qiniuUrl';
        }
        if (qiniuUrl.endsWith('/')) {
          qiniuUrl = qiniuUrl.substring(0, qiniuUrl.length - 1);
        }

        if (qiniuPath.isEmpty || qiniuPath == null) {
          qiniuPath = 'None';
        } else {
          if (qiniuPath.startsWith('/')) {
            qiniuPath = qiniuPath.substring(1);
          }
          if (!qiniuPath.endsWith('/')) {
            qiniuPath = '$qiniuPath/';
          }
        }

        if (qiniuOptions.isEmpty || qiniuOptions == null) {
          qiniuOptions = 'None';
        } else {
          if (!qiniuOptions.startsWith('?')) {
            qiniuOptions = '?$qiniuOptions';
          }
        }
        List sqlconfig = [];
        sqlconfig.add(qiniuAccessKey);
        sqlconfig.add(qiniuSecretKey);
        sqlconfig.add(qiniuBucket);
        sqlconfig.add(qiniuUrl);
        sqlconfig.add(qiniuArea);
        sqlconfig.add(qiniuOptions);
        sqlconfig.add(qiniuPath);

        sqlconfig.add(defaultUser);
        //save asset image to app dir
        String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
        String appDir = await getApplicationDocumentsDirectory().then((value) {
          return value.path;
        });
        String assetFilePath = '$appDir/PicHoroValidate.jpeg';
        File assetFile = File(assetFilePath);

        if (!assetFile.existsSync()) {
          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await assetFile.writeAsBytes(bytes);
        }
        String key = 'PicHoroValidate.jpeg';
        String urlSafeBase64EncodePutPolicy =
            QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(
                qiniuBucket, key, qiniuPath);
        String uploadToken = QiniuImageUploadUtils.getUploadToken(
            qiniuAccessKey, qiniuSecretKey, urlSafeBase64EncodePutPolicy);
        Storage storage = Storage(
            config: Config(
          retryLimit: 5,
        ));

        String sqlResult = '';
        try {
          PutResponse putresult =
              await storage.putFile(File(assetFilePath), uploadToken);
          if (putresult.key == key || putresult.key == '$qiniuPath$key') {
            if (queryqiniu == 'Empty') {
              sqlResult = await MySqlUtils.insertQiniu(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateQiniu(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final qiniuConfig = QiniuConfigModel(
                  qiniuAccessKey,
                  qiniuSecretKey,
                  qiniuBucket,
                  qiniuUrl,
                  qiniuArea,
                  qiniuOptions,
                  qiniuPath);
              final qiniuConfigJson = jsonEncode(qiniuConfig);
              final qiniuConfigFile = await qiniuFile;
              await qiniuConfigFile.writeAsString(qiniuConfigJson);
              Fluttertoast.showToast(
                  msg: "七牛云配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "七牛云数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "七牛云验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "七牛云配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['tcyun'] != null) {
      String tencentVersion = jsonResult['tcyun']['version'];
      if (tencentVersion == 'v5') {
        String tencentSecretId = jsonResult['tcyun']['secretId'];
        String tencentSecretKey = jsonResult['tcyun']['secretKey'];
        String tencentBucket = jsonResult['tcyun']['bucket'];
        String tencentAppId = jsonResult['tcyun']['appId'];
        String tencentArea = jsonResult['tcyun']['area'];
        String tencentPath = jsonResult['tcyun']['path'];
        String tencentCustomUrl = jsonResult['tcyun']['customUrl'];
        String tencentOptions = jsonResult['tcyun']['options'];

        try {
          String defaultUser = await Global.getUser();
          var querytencent =
              await MySqlUtils.queryTencent(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);

          if (queryuser == 'Empty') {
            Fluttertoast.showToast(
                msg: "请先登录",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
          if (tencentCustomUrl.isNotEmpty) {
            if (!tencentCustomUrl.startsWith('http') &&
                !tencentCustomUrl.startsWith('https')) {
              tencentCustomUrl = 'http://$tencentCustomUrl';
            }
            if (tencentCustomUrl.endsWith('/')) {
              tencentCustomUrl =
                  tencentCustomUrl.substring(0, tencentCustomUrl.length - 1);
            }
          } else {
            tencentCustomUrl = 'None';
          }

          if (tencentPath.isEmpty || tencentPath == null) {
            tencentPath = 'None';
          } else {
            if (tencentPath.startsWith('/')) {
              tencentPath = tencentPath.substring(1);
            }
            if (!tencentPath.endsWith('/')) {
              tencentPath = '$tencentPath/';
            }
          }

          if (tencentOptions.isEmpty || tencentOptions == null) {
            tencentOptions = 'None';
          } else {
            if (!tencentOptions.startsWith('?')) {
              tencentOptions = '?$tencentOptions';
            }
          }
          List sqlconfig = [];
          sqlconfig.add(tencentSecretId);
          sqlconfig.add(tencentSecretKey);
          sqlconfig.add(tencentBucket);
          sqlconfig.add(tencentAppId);
          sqlconfig.add(tencentArea);
          sqlconfig.add(tencentPath);
          sqlconfig.add(tencentCustomUrl);
          sqlconfig.add(tencentOptions);

          sqlconfig.add(defaultUser);
          //save asset image to app dir
          String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
          String appDir =
              await getApplicationDocumentsDirectory().then((value) {
            return value.path;
          });
          String assetFilePath = '$appDir/PicHoroValidate.jpeg';
          File assetFile = File(assetFilePath);

          if (!assetFile.existsSync()) {
            ByteData data = await rootBundle.load(assetPath);
            List<int> bytes =
                data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await assetFile.writeAsBytes(bytes);
          }
          String key = 'PicHoroValidate.jpeg';
          String host = '$tencentBucket.cos.$tencentArea.myqcloud.com';
          String urlpath = '';
          if (tencentPath != 'None') {
            urlpath = '$tencentPath$key';
          } else {
            urlpath = key;
          }
          int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          int endTimestamp = startTimestamp + 86400;
          String keyTime = '$startTimestamp;$endTimestamp';
          Map<String, dynamic> uploadPolicy = {
            "expiration": "2033-03-03T09:38:12.414Z",
            "conditions": [
              {"acl": "default"},
              {"bucket": tencentBucket},
              {"key": urlpath},
              {"q-sign-algorithm": "sha1"},
              {"q-ak": tencentSecretId},
              {"q-sign-time": keyTime}
            ]
          };
          String uploadPolicyStr = jsonEncode(uploadPolicy);
          String singature = TencentImageUploadUtils.getUploadAuthorization(
              tencentSecretKey, keyTime, uploadPolicyStr);
          //policy中的字段，除了bucket，其它的都要在formdata中添加
          FormData formData = FormData.fromMap({
            'key': urlpath,
            'policy': base64Encode(utf8.encode(uploadPolicyStr)),
            'acl': 'default',
            'q-sign-algorithm': 'sha1',
            'q-ak': tencentSecretId,
            'q-key-time': keyTime,
            'q-sign-time': keyTime,
            'q-signature': singature,
            'file': await MultipartFile.fromFile(assetFilePath, filename: key),
          });

          BaseOptions baseoptions = BaseOptions(
            //连接服务器超时时间，单位是毫秒.
            connectTimeout: 30000,
            //响应超时时间。
            receiveTimeout: 30000,
            sendTimeout: 30000,
          );
          String contentLength = await assetFile.length().then((value) {
            return value.toString();
          });
          baseoptions.headers = {
            'Host': host,
            'Content-Type':
                'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
            'Content-Length': contentLength,
          };
          Dio dio = Dio(baseoptions);
          String tencentSqlResult = '';

          var response = await dio.post(
            'http://$host',
            data: formData,
          );

          if (response.statusCode == 204) {
            if (querytencent == 'Empty') {
              tencentSqlResult =
                  await MySqlUtils.insertTencent(content: sqlconfig);
            } else {
              tencentSqlResult =
                  await MySqlUtils.updateTencent(content: sqlconfig);
            }
            if (tencentSqlResult == "Success") {
              final tencentConfig = TencentConfigModel(
                tencentSecretId,
                tencentSecretKey,
                tencentBucket,
                tencentAppId,
                tencentArea,
                tencentPath,
                tencentCustomUrl,
                tencentOptions,
              );
              final tencentConfigJson = jsonEncode(tencentConfig);
              final tencentConfigFile = await tencentFile;
              await tencentConfigFile.writeAsString(tencentConfigJson);
              Fluttertoast.showToast(
                  msg: "腾讯云配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "腾讯云数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "腾讯云验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: "腾讯云配置错误",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "不支持腾讯V4",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['aliyun'] != null) {
      String aliyunKeyId = jsonResult['aliyun']['accessKeyId'];
      String aliyunKeySecret = jsonResult['aliyun']['accessKeySecret'];
      String aliyunBucket = jsonResult['aliyun']['bucket'];
      String aliyunArea = jsonResult['aliyun']['area'];
      String aliyunPath = jsonResult['aliyun']['path'];
      String aliyunCustomUrl = jsonResult['aliyun']['customUrl'];
      String aliyunOptions = jsonResult['aliyun']['options'];

      try {
        String defaultUser = await Global.getUser();
        var queryaliyun = await MySqlUtils.queryAliyun(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        if (aliyunCustomUrl.isNotEmpty) {
          if (!aliyunCustomUrl.startsWith('http') &&
              !aliyunCustomUrl.startsWith('https')) {
            aliyunCustomUrl = 'http://$aliyunCustomUrl';
          }
          if (aliyunCustomUrl.endsWith('/')) {
            aliyunCustomUrl =
                aliyunCustomUrl.substring(0, aliyunCustomUrl.length - 1);
          }
        } else {
          aliyunCustomUrl = 'None';
        }

        if (aliyunPath.isEmpty || aliyunPath == null) {
          aliyunPath = 'None';
        } else {
          if (aliyunPath.startsWith('/')) {
            aliyunPath = aliyunPath.substring(1);
          }
          if (!aliyunPath.endsWith('/')) {
            aliyunPath = '$aliyunPath/';
          }
        }

        if (aliyunOptions.isEmpty || aliyunOptions == null) {
          aliyunOptions = 'None';
        } else {
          if (!aliyunOptions.startsWith('?')) {
            aliyunOptions = '?$aliyunOptions';
          }
        }
        List sqlconfig = [];
        sqlconfig.add(aliyunKeyId);
        sqlconfig.add(aliyunKeySecret);
        sqlconfig.add(aliyunBucket);
        sqlconfig.add(aliyunArea);
        sqlconfig.add(aliyunPath);
        sqlconfig.add(aliyunCustomUrl);
        sqlconfig.add(aliyunOptions);
        sqlconfig.add(defaultUser);
        //save asset image to app dir
        String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
        String appDir = await getApplicationDocumentsDirectory().then((value) {
          return value.path;
        });
        String assetFilePath = '$appDir/PicHoroValidate.jpeg';
        File assetFile = File(assetFilePath);

        if (!assetFile.existsSync()) {
          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await assetFile.writeAsBytes(bytes);
        }
        String key = 'PicHoroValidate.jpeg';
        String host = '$aliyunBucket.$aliyunArea.aliyuncs.com';
        String urlpath = '';
        if (aliyunPath != 'None') {
          urlpath = '$aliyunPath$key';
        } else {
          urlpath = key;
        }
        Map<String, dynamic> uploadPolicy = {
          "expiration": "2034-12-01T12:00:00.000Z",
          "conditions": [
            {"bucket": aliyunBucket},
            ["content-length-range", 0, 104857600],
            {"key": urlpath}
          ]
        };
        String base64Policy =
            base64.encode(utf8.encode(json.encode(uploadPolicy)));
        String singature = base64.encode(
            Hmac(sha1, utf8.encode(aliyunKeySecret))
                .convert(utf8.encode(base64Policy))
                .bytes);
        FormData formData = FormData.fromMap({
          'key': urlpath,
          'OSSAccessKeyId': aliyunKeyId,
          'policy': base64Policy,
          'Signature': singature,
          //阿里默认的content-type是application/octet-stream，这里改成image/xxx
          'x-oss-content-type':
              'image/${mypath.extension(assetFilePath).replaceFirst('.', '')}',
          'file': await MultipartFile.fromFile(assetFilePath, filename: key),
        });

        BaseOptions baseoptions = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        String contentLength = await assetFile.length().then((value) {
          return value.toString();
        });
        baseoptions.headers = {
          'Host': host,
          'Content-Type':
              'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
          'Content-Length': contentLength,
        };
        Dio dio = Dio(baseoptions);
        String aliyunSqlResult = '';

        var response = await dio.post(
          'https://$host',
          data: formData,
        );

        if (response.statusCode == 204) {
          if (queryaliyun == 'Empty') {
            aliyunSqlResult = await MySqlUtils.insertAliyun(content: sqlconfig);
          } else {
            aliyunSqlResult = await MySqlUtils.updateAliyun(content: sqlconfig);
          }
          if (aliyunSqlResult == "Success") {
            final aliyunConfig = AliyunConfigModel(
              aliyunKeyId,
              aliyunKeySecret,
              aliyunBucket,
              aliyunArea,
              aliyunPath,
              aliyunCustomUrl,
              aliyunOptions,
            );
            final aliyunConfigJson = jsonEncode(aliyunConfig);
            final aliyunConfigFile = await aliyunFile;
            await aliyunConfigFile.writeAsString(aliyunConfigJson);
            Fluttertoast.showToast(
                msg: "阿里云配置成功",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: "阿里云数据库错误",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } else {
          Fluttertoast.showToast(
              msg: "阿里云验证失败",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "阿里云配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['upyun'] != null) {
      String upyunBucket = jsonResult['upyun']['bucket'];
      String upyunOperator = jsonResult['upyun']['operator'];
      String upyunPassword = jsonResult['upyun']['password'];
      String upyunUrl = jsonResult['upyun']['url'];
      String upyunOptions = jsonResult['upyun']['options'];
      String upyunPath = jsonResult['upyun']['path'];
      try {
        String defaultUser = await Global.getUser();
        var queryupyun = await MySqlUtils.queryUpyun(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        if (!upyunUrl.startsWith('http') && !upyunUrl.startsWith('https')) {
          upyunUrl = 'http://$upyunUrl';
        }

        if (upyunUrl.endsWith('/')) {
          upyunUrl = upyunUrl.substring(0, upyunUrl.length - 1);
        }

        if (upyunPath.isEmpty || upyunPath == null) {
          upyunPath = 'None';
        } else {
          if (upyunPath.startsWith('/')) {
            upyunPath = upyunPath.substring(1);
          }

          if (!upyunPath.endsWith('/')) {
            upyunPath = '$upyunPath/';
          }
        }

        List sqlconfig = [];
        sqlconfig.add(upyunBucket);
        sqlconfig.add(upyunOperator);
        sqlconfig.add(upyunPassword);
        sqlconfig.add(upyunUrl);
        sqlconfig.add(upyunOptions);
        sqlconfig.add(upyunPath);
        sqlconfig.add(defaultUser);
        //save asset image to app dir
        String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
        String appDir = await getApplicationDocumentsDirectory().then((value) {
          return value.path;
        });
        String assetFilePath = '$appDir/PicHoroValidate.jpeg';
        File assetFile = File(assetFilePath);

        if (!assetFile.existsSync()) {
          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await assetFile.writeAsBytes(bytes);
        }
        String key = 'PicHoroValidate.jpeg';
        String host = 'http://v0.api.upyun.com';
        String urlpath = '';
        if (upyunPath != 'None') {
          urlpath = '/$upyunPath$key';
        } else {
          urlpath = '/$key';
        }
        String date = HttpDate.format(DateTime.now());
        String assetFileMd5 = await assetFile.readAsBytes().then((value) {
          return md5.convert(value).toString();
        });
        Map<String, dynamic> uploadPolicy = {
          'bucket': upyunBucket,
          'save-key': urlpath,
          'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
          'date': date,
          'content-md5': assetFileMd5,
        };
        String base64Policy =
            base64.encode(utf8.encode(json.encode(uploadPolicy)));
        String stringToSign =
            'POST&/$upyunBucket&$date&$base64Policy&$assetFileMd5';
        String passwordMd5 = md5.convert(utf8.encode(upyunPassword)).toString();
        String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
            .convert(utf8.encode(stringToSign))
            .bytes);
        String authorization = 'UPYUN $upyunOperator:$signature';
        FormData formData = FormData.fromMap({
          'authorization': authorization,
          'policy': base64Policy,
          'file': await MultipartFile.fromFile(assetFilePath, filename: key),
        });

        BaseOptions baseoptions = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        String contentLength = await assetFile.length().then((value) {
          return value.toString();
        });
        baseoptions.headers = {
          'Host': 'v0.api.upyun.com',
          'Content-Type':
              'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
          'Content-Length': contentLength,
          'Date': date,
          'Authorization': authorization,
          'Content-MD5': assetFileMd5,
        };
        Dio dio = Dio(baseoptions);
        String upyunSqlResult = '';

        var response = await dio.post(
          '$host/$upyunBucket',
          data: formData,
        );

        if (response.statusCode == 200) {
          if (queryupyun == 'Empty') {
            upyunSqlResult = await MySqlUtils.insertUpyun(content: sqlconfig);
          } else {
            upyunSqlResult = await MySqlUtils.updateUpyun(content: sqlconfig);
          }
          if (upyunSqlResult == "Success") {
            final upyunConfig = UpyunConfigModel(
              upyunBucket,
              upyunOperator,
              upyunPassword,
              upyunUrl,
              upyunOptions,
              upyunPath,
            );
            final upyunConfigJson = jsonEncode(upyunConfig);
            final upyunConfigFile = await upyunFile;
            await upyunConfigFile.writeAsString(upyunConfigJson);
            Fluttertoast.showToast(
                msg: "又拍云配置成功",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: "又拍云数据库错误",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } else {
          Fluttertoast.showToast(
              msg: "又拍云验证失败",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "又拍云配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '图床设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(children: [
        ListTile(
          tileColor: const Color.fromARGB(255, 188, 187, 238),
          textColor: const Color.fromARGB(255, 11, 173, 19),
          title: const Text('二维码扫描导入PicGo配置'),
          onTap: () async {
            await _scan();

            showDialog(
                context: this.context,
                barrierDismissible: false,
                builder: (context) {
                  return NetLoadingDialog(
                    outsideDismiss: false,
                    loading: true,
                    loadingText: "配置中...",
                    requestCallBack: processingQRCodeResult(),
                  );
                });
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const Divider(
          height: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: const Text('默认图床选择'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const defaultPShostSelect()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('兰空图床V2'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HostConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('SM.MS图床'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SmmsConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('Github图床'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GithubConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('Imgur图床（需翻墙）'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ImgurConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('七牛云'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const QiniuConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('腾讯云COS V5'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TencentConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('阿里云OSS'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AliyunConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('又拍云'),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UpyunConfig()));
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ]),
      floatingActionButton: Container(
          height: 40,
          width: 40,
          child: FloatingActionButton(
            heroTag: 'copyConfig',
            backgroundColor: Color.fromARGB(255, 198, 135, 235),
            //select host menu
            onPressed: () async {
              await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text(
                      '选择要复制配置的图床',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SimpleDialogOption(
                        child: const Text('兰空图床', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('lankong');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('SM.MS', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('smms');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child:
                            const Text('Github', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('github');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('Imgur', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('imgur');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('七牛云', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('qiniu');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('腾讯云', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('tcyun');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('阿里云', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('aliyun');
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        child: const Text('又拍云', textAlign: TextAlign.center),
                        onPressed: () {
                          exportConfiguration('upyun');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.outbox_outlined,
              size: 30,
            ),
          )),
    );
  }
}
