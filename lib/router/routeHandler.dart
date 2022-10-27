import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:horopic/pages/pichoroAPP.dart';

import 'package:horopic/pages/homePage.dart';

import 'package:horopic/album/albumPage.dart';
import 'package:horopic/album/albumPreview.dart';
import 'package:horopic/album/EmptyDatabase.dart';

import 'package:horopic/configurePage/configurePage.dart';
import 'package:horopic/configurePage/commonConfigure/commonConfig.dart';
import 'package:horopic/configurePage/commonConfigure/selectLinkFormat.dart';
import 'package:horopic/configurePage/commonConfigure/selectPShost.dart';
import 'package:horopic/configurePage/commonConfigure/RenameFile.dart';
import 'package:horopic/configurePage/others/UpdateLog.dart';
import 'package:horopic/configurePage/others/author.dart';
import 'package:horopic/configurePage/others/selectTheme.dart';
import 'package:horopic/configurePage/userManage/APPpassword.dart';

import 'package:horopic/hostconfigure/Imgurconfig.dart';
import 'package:horopic/hostconfigure/smmsconfig.dart';
import 'package:horopic/hostconfigure/lskyproconfig.dart';
import 'package:horopic/hostconfigure/githubconfig.dart';
import 'package:horopic/hostconfigure/aliyunconfig.dart';
import 'package:horopic/hostconfigure/tencentconfig.dart';
import 'package:horopic/hostconfigure/qiniuconfig.dart';
import 'package:horopic/hostconfigure/upyunconfig.dart';
import 'package:horopic/hostconfigure/PShostSelect.dart';

import 'package:horopic/PShostFileManage/tencent/tencentBucketList.dart';
import 'package:horopic/PShostFileManage/tencent/tencentbucketInformation.dart';
import 'package:horopic/PShostFileManage/tencent/tencentNewBucketConfig.dart';
import 'package:horopic/PShostFileManage/tencent/tencentFileExplorer.dart';
import 'package:horopic/PShostFileManage/tencent/tencentUpDownloadManagePage.dart';

import 'package:horopic/PShostFileManage/commonPage/file_explorer/fileExplorer.dart';
import 'package:horopic/PShostFileManage/commonPage/file_explorer/localImagePreview.dart';

import 'package:horopic/PShostFileManage/smms/smmsManageHomePage.dart';
import 'package:horopic/PShostFileManage/smms/smmsFileExplorer.dart';
import 'package:horopic/PShostFileManage/smms/smmsUpDownloadManagePage.dart';

//root
Handler rootHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return PicHoroAPP();
});

//主页
var homePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return HomePage();
});

//相册
var albumUploadedImagesHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UploadedImages();
});

//相册预览
var albumImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return ImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//本地文件相册预览
var localImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return LocalImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//配置页面
var configurePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return ConfigurePage();
});

//用户登录页面
var appPasswordHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return APPPassword();
});

//图床配置页面
var allPShostHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return AllPShost();
});

//默认图床配置页面
var defaultPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return DefaultPShostSelect();
});

//兰空图床配置页面
var lskyproPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return HostConfig();
});

//sm.ms图床配置页面
var smmsPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SmmsConfig();
});

//github图床配置页面
var githubPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return GithubConfig();
});

//Imgur图床配置页面
var imgurPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return ImgurConfig();
});

//阿里云图床配置页面
var aliyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return AliyunConfig();
});

//腾讯云图床配置页面
var tencentPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return TencentConfig();
});

//七牛云图床配置页面
var qiniuPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return QiniuConfig();
});

//又拍云图床配置页面
var upyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UpyunConfig();
});

//通用配置页面
var commonConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return CommonConfig();
});

//文件重命名格式配置页面
var renameFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return RenameFile();
});

//链接格式配置页面
var linkFormatSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return LinkFormatSelect();
});

//主题配置页面
var changeThemeHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return ChangeTheme();
});

//清空数据库页面
var emptyDatabaseHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return EmptyDatabase();
});

//作者页面
var authorInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return AuthorInformation();
});

//更新日志页面
var updateLogHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UpdateLog();
});

//腾讯云存储桶列表页面
var tencentBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return TencentBucketList();
});

//腾讯云存储桶详情页面
var tencentBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return BucketInformation(
    bucketMap: bucketMap,
  );
});

//腾讯云新建存储桶页面
var newTencentBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return NewBucketConfig();
});

//腾讯云存储桶文件列表页面
var tencentFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return TencentFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//腾讯云存储下载文件页面
var tencentDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  List<String> downloadList =
      json.decode(params['downloadList']!.first).cast<String>();
  String downloadPath = params['downloadPath']!.first;
  return TencentUpDownloadManagePage(
      bucketName: bucketName,
      downloadList: downloadList,
      downloadPath: downloadPath);
});

//文件浏览页面
var fileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var currentDirPath = params['currentDirPath']!.first;
  var rootPath = params['rootPath']!.first;
  return FileExplorer(
    currentDirPath: currentDirPath,
    rootPath: rootPath,
  );
});

//SMMS图床管理首页
var smmsManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SmmsManageHomePage();
});

//SMMS图床管理文件列表页面
var smmsFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return SmmsFileExplorer();
});

//SM.MS存储下载文件页面
var smmsUpDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  List<String> savedFileNameList =
      json.decode(params['savedFileNameList']!.first).cast<String>();
  List<String> downloadList =
      json.decode(params['downloadList']!.first).cast<String>();
  String downloadPath = params['downloadPath']!.first;
  return SmmsUpDownloadManagePage(
      savedFileNameList: savedFileNameList,
      downloadList: downloadList,
      downloadPath: downloadPath);
});