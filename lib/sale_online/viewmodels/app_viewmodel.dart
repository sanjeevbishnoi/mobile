/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 9:44 AM
 *
 */

import 'dart:async';
import 'dart:io';

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/models/app_models/printer_type.dart';
import 'package:tpos_mobile/sale_online/viewmodels/notification_list_viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart' as newDialog;
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company_current_info.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/web_app_route.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/company_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_all.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:device_info/device_info.dart';

abstract class IAppService extends ViewModel {
  List<MenuItem> menus;
  List<MenuGroup> menuGroups;
  WebUserConfig get userConfig;
  List<String> get userPermission;

  /// Luồng thông báo đi của ứng dụng
  Stream<OldDialogMessage> get appDialogStream;

  /// Thêm luồng thông báo của ứng dụng
  Sink<OldDialogMessage> get appDialogSink;

  /// Thông tin đăng nhập
  TposUser get loginUser;

  /// Công ty hiện tại
  Company get selectedCompany;

  /// Thông tin hạn sử dụng và danh sách công ty hiện tại
  CompanyCurrentInfo get companyCurrentInfo;

  /// Phien ban phan mem
  String get version;

  /// App build number
  int get buildNumber;

  /// Danh sách loại máy in hỗ trợ
  List<PrinterType> get avaiablePrinterTypes;

  /// Tên thiết bị hiện tại
  String currentDeviceModel;
  Stream<AppMessage> get appMessengerStream;
  Sink<AppMessage> get appMessengerSink;

  void onAppMessengerAdd(AppMessage message);

  set selectedCompany(Company value);

  Future getCurrentCompanyCommand();
  Future<void> initCommand();
  Future<void> init();

  List<MenuItem> getHomeMenu({bool isGroupByGroup});

  /// Lấy toàn bộ menu có phân quyền
  List<MenuItem> getAllMenu();

  void addMenuSuggest(String id);

  bool getWebPermission(String permissionName);

  Future<void> refreshLoginInfo();
  Future refreshToken();

  /// Gọi để thay đổicông ty
  Future<void> switchCompany(int targetCompanyId);

  /// Đăng xuất phần mềm
  Future<void> logout();

  String lastError;
}

class AppViewModel extends ViewModel implements IAppService {
  ITposApiService _tposApiService;
  TposApi _tposApi;
  ISettingService _setting;
  ICompanyService _companyApi;
  DialogService _dialog;

  String lastError;
  AppViewModel(
      {ITposApiService tposApiService,
      ISettingService setting,
      ICompanyService companyApi,
      newDialog.DialogService dialog,
      TposApi tposApi}) {
    _tposApiService = tposApiService ?? locator<ITposApiService>();
    _setting = tposApi ?? locator<ISettingService>();
    _dialog = dialog ?? locator<DialogService>();
    _tposApi = tposApi ?? locator<TposApi>();
    _companyApi = companyApi ?? locator<ICompanyService>();
    logger.debug("AppViewModel created");

    menuGroups = [
      MenuGroup(
          id: "1",
          name: "Bán hàng online",
          icon: Icon(FontAwesomeIcons.facebookF)),
      MenuGroup(
          id: "2", name: "Bán hàng nhanh", icon: Icon(FontAwesomeIcons.bold)),
      MenuGroup(id: "3", name: "Kho hàng", icon: Icon(FontAwesomeIcons.box)),
      MenuGroup(id: "4", name: "Danh mục", icon: Icon(FontAwesomeIcons.list)),
    ];
    menus = [
      // Bán hàng facebook
      new MenuItem(
        id: "1",
        groupId: "1",
        icon: Icon(
          FontAwesomeIcons.facebookF,
          color: Colors.indigo,
        ),
        label: "Bán hàng Facebook",
        routeName: AppRoute.sale_online_facebook_channel_list,
        permissionName: PERMISSION_SALE_ONLINE_FACEBOOK_FEED,
      ),
      //Đơn hàng Facebook
      new MenuItem(
          id: "2",
          groupId: "1",
          icon: Icon(
            Icons.assignment,
            color: Colors.indigo,
          ),
          label: "Đơn hàng Facebook",
          routeName: AppRoute.sale_online_order_list,
          permissionName: PERMISSION_SALE_ONLINE_ORDER_READ),

      //Đơn hàng Facebook
      new MenuItem(
          id: "3",
          groupId: "1",
          icon: Icon(
            FontAwesomeIcons.video,
            color: Colors.indigo,
          ),
          label: "Chiến dịch live",
          routeName: AppRoute.sale_online_live_campaign_list,
          permissionName: PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_READ),
      new MenuItem(
        id: "4",
        groupId: "2",
        icon: Icon(
          Icons.add,
          color: Colors.blue,
        ),
        label: "Tạo hóa đơn",
        routeName: AppRoute.fast_sale_order_add_edit_full,
        permissionName: PERMISSION_SALE_FAST_ORDER_INSERT,
      ),
      //Hóa đơn bán hàng
      new MenuItem(
          id: "5",
          groupId: "2",
          icon: Icon(
            FontAwesomeIcons.fileInvoice,
            color: Colors.blue,
          ),
          label: "Hóa đơn bán hàng",
          routeName: AppRoute.fast_sale_order_list,
          permissionName: PERMISSION_SALE_FAST_ORDER_READ),
      //Hóa đơn giao hàng
      new MenuItem(
          id: "6",
          groupId: "2",
          icon: Icon(
            FontAwesomeIcons.car,
            color: Colors.blue,
          ),
          label: "Hóa đơn giao hàng",
          routeName: AppRoute.fast_sale_order_delivery_list,
          permissionName: PERMISSION_SALE_DELIVERY_ORDER_READ),

      new MenuItem(
          id: "7",
          groupId: "3",
          icon: Icon(
            FontAwesomeIcons.box,
            color: Colors.orange,
          ),
          label: "Sản phẩm",
          routeName: AppRoute.product_template_search,
          permissionName: PERMISSION_CATALOG_PRODUCT_TEMPLATE_READ),

      new MenuItem(
          id: "8",
          groupId: "3",
          icon: Icon(
            FontAwesomeIcons.boxes,
            color: Colors.orange,
          ),
          label: "Biến thể",
          routeName: AppRoute.product_search,
          permissionName: PERMISSION_CATALOG_PRODUCT_READ),

      new MenuItem(
        id: "9",
        groupId: "4",
        icon: Icon(
          Icons.image,
          color: Colors.green,
        ),
        label: "Nhóm sản phẩm",
        routeName: AppRoute.product_category_search,
      ),

      new MenuItem(
          id: "10",
          groupId: "4",
          icon: Icon(
            Icons.people,
            color: Colors.green,
          ),
          label: "Khách hàng",
          routeName: AppRoute.partner_search,
          permissionName: PERMISSION_CATALOG_PARTNER_CUSTOMER_READ),
      new MenuItem(
          id: "18",
          groupId: "4",
          icon: Icon(
            FontAwesomeIcons.image,
            color: Colors.green,
          ),
          label: "Nhà cung cấp",
          routeName: AppRoute.supplier_search,
          permissionName: PERMISSION_CATALOG_PARTNER_SUPPLIER_READ),
      new MenuItem(
        id: "11",
        groupId: "4",
        icon: Icon(
          Icons.image,
          color: Colors.green,
        ),
        label: "Nhóm khách hàng",
        routeName: AppRoute.partner_category_list,
      ),

      new MenuItem(
        id: "12",
        groupId: "4",
        icon: Icon(
          Icons.settings,
          color: Colors.green,
        ),
        label: "Cài đặt",
        routeName: AppRoute.setting,
      ),
      new MenuItem(
          id: "13",
          groupId: "2",
          icon: Icon(
            Icons.image,
            color: Colors.blue,
          ),
          label: "Đơn đặt hàng",
          routeName: AppRoute.sale_order_list,
          permissionName: PERMISSION_SALE_ORDER_READ),
      new MenuItem(
          id: "14",
          groupId: "4",
          icon: Icon(
            Icons.add_circle,
            color: Colors.green,
          ),
          label: "Thêm đơn đặt hàng",
          routeName: AppRoute.sale_order_add_edit,
          permissionName: PERMISSION_SALE_ORDER_INSERT),
      new MenuItem(
          id: "15",
          groupId: "3",
          icon: Icon(
            FontAwesomeIcons.fileImport,
            color: Colors.orange,
          ),
          label: "Nhập hàng",
          routeName: AppRoute.fast_purchase_order,
          permissionName: PERMISSION_PURCHASE_FAST_ORDER_READ),
      new MenuItem(
          id: "16",
          groupId: "3",
          icon: Icon(
            FontAwesomeIcons.fileExport,
            color: Colors.orange,
          ),
          label: "Trả hàng NCC",
          routeName: AppRoute.refund_fast_purchase_order,
          permissionName: PERMISSION_PURCHASE_FAST_REFUND_READ),
      new MenuItem(
        id: "17",
        groupId: "4",
        icon: Icon(
          FontAwesomeIcons.stackExchange,
          color: Colors.green,
        ),
        label: "Kênh bán",
        routeName: AppRoute.sale_online_channel_list,
      ),
      new MenuItem(
        id: "17",
        groupId: "4",
        icon: Icon(
          FontAwesomeIcons.mapPin,
          color: Colors.green,
        ),
        label: "Đơn hàng POS",
        routeName: AppRoute.pos_order_list,
      ),
      new MenuItem(
        id: "17",
        groupId: "4",
        icon: Icon(
          FontAwesomeIcons.firstOrder,
          color: Colors.green,
        ),
        label: "Mail Template",
        routeName: AppRoute.mail_template_list,
      ),
      new MenuItem(
        id: "18",
        groupId: "2",
        icon: Icon(
          Icons.image,
          color: Colors.blue,
        ),
        label: "Điểm bán hàng",
        routeName: AppRoute.pos_order,
      )
      //TODO
//      new MenuItem(
//        id: "19",
//        groupId: "4",
//        icon: Icon(
//          FontAwesomeIcons.truck,
//          color: Colors.green,
//        ),
//        label: "Đối tác vận chuyển",
//        routeName: AppRoute.delivery_carier_parnter_list,
//      ),
    ];
  }
  WebUserConfig _userConfig;
  List<MenuItem> menus;
  List<MenuGroup> menuGroups;

  CompanyCurrentInfo _companyCurrentInfo;
  CompanyCurrentInfo get companyCurrentInfo => _companyCurrentInfo;
  WebUserConfig get userConfig => _userConfig;
  List<String> get userPermission => _userConfig?.functions;

  TposUser _loginUser;
  TposUser get loginUser => _loginUser;

  /// Danh sách loại máy in khả dụng
  List<PrinterType> _avaiablePrinterTypes = [
    PrinterType(
        code: "tpos_printer",
        port: 8123,
        name: "Ứng dụng TPosPrinter trên windows",
        description: "Thông qua phần mềm in trên máy tính"),
    PrinterType(
        code: "esc_pos",
        port: 9100,
        name: "Máy in bill ESC/POS",
        description: "Máy in hóa đơn/ bill 80, 57mm"),
  ];
  var _appDialogController = BehaviorSubject<OldDialogMessage>();
  var _appMessengerCenterController = PublishSubject<AppMessage>();
  List<PrinterType> get avaiablePrinterTypes => _avaiablePrinterTypes;

  Stream<OldDialogMessage> get appDialogStream => _appDialogController.stream;

  Sink<OldDialogMessage> get appDialogSink => _appDialogController.sink;

  void dispose() {
    _appDialogController.close();
    _appMessengerCenterController.close();
    super.dispose();
  }

  Sink<AppMessage> get appMessengerSink => _appMessengerCenterController.sink;

  Stream<AppMessage> get appMessengerStream =>
      _appMessengerCenterController.stream;

  void onAppMessengerAdd(AppMessage message) {
    if (_appMessengerCenterController != null &&
        !_appMessengerCenterController.isClosed) {
      _appMessengerCenterController.sink.add(message);
    }
  }

  Company _selectedCompany;

  Company get selectedCompany {
    if (_selectedCompany == null) {
      getCurrentCompanyCommand().whenComplete(() {
        return _selectedCompany;
      });
    } else {
      return _selectedCompany;
    }
    return _selectedCompany;
  }

  @override
  set selectedCompany(Company value) {
    _selectedCompany = value;
  }

  String _version;
  int _buildNumber;
  int get buildNumber => _buildNumber;
  String get version => _version;
  String currentDeviceModel;

  bool _isInit = false;
  bool _isInitWithServer = false;
  Future<void> init() async {
    logger.debug("app service init comand");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    this._version = packageInfo.version;
    this._buildNumber = int.tryParse(packageInfo.buildNumber);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      currentDeviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      currentDeviceModel = iosInfo.model;
    }
    menus.forEach((f) => f.visible = false);
  }

  Future<void> _fetchNotification() async {
    try {
      await locator<NotificationListViewModel>().fetchNotReadNotification();
      notifyListeners();
    } catch (e, s) {
      logger.error("", e, s);
      _dialog.showNotify(
          message: "Không tải được thông báo",
          type: newDialog.DialogType.NOTIFY_ERROR);
    }
  }

  Future<void> initCommand() async {
    onStateAdd(true, message: "Vui lòng đợi...");

    if (!_isInitWithServer) {
      try {
        _userConfig = await _tposApiService.getWebUserConfig();
        // Hide menu

        _companyCurrentInfo = await _tposApiService.getCompanyCurrentInfo();
        await _loadCompanyInfo();
        _isInitWithServer = true;
        lastError = null;
      } catch (e, s) {
        logger.error("init App fail", e, s);

        if (e is SocketException) {
          lastError =
              "Không có kết nối internet. Kiểm tra kết nối mạng và thử lại";
        } else {
          lastError = e.toString();
        }

        notifyListeners();
      }
    }

    if (_userConfig != null) {
      menus.forEach(
        (f) {
          if (_userConfig.functions != null &&
              _userConfig.functions.any((route) =>
                  route == f.permissionName || f.permissionName == null)) {
            f.visible = true;
          } else {
            f.visible = false;
            if (f.permissionName == null) f.visible = true;
          }
        },
      );
    }

    onStateAdd(false);
//
//    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//
//    void iOS_Permission() {
//      _firebaseMessaging.requestNotificationPermissions(
//          IosNotificationSettings(sound: true, badge: true, alert: true));
//      _firebaseMessaging.subscribeToTopic('all');
//      _firebaseMessaging.onIosSettingsRegistered
//          .listen((IosNotificationSettings settings) {
//        print("Settings registered: $settings");
//      });
//    }
//
//    if (Platform.isIOS) iOS_Permission();
//
//    _firebaseMessaging.getToken().then((token) {
//      print(token);
//    });
//
//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print('on message $message');
//        _dialog.showNotify(
//            title: "Thông mới báo từ máy chủ", message: message.toString());
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print('on resume $message');
//        _dialog.showNotify(
//            title: "Resume Thông mới báo từ máy chủ",
//            message: message.toString());
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print('on launch $message');
//        _dialog.showNotify(
//            title: "Launch Thông mới báo từ máy chủ",
//            message: message.toString());
//      },
//    );
  }

  /// Refresh shop access token
  Future refreshToken() async {
    if (_setting.shopRefreshAccessToken != null &&
        _setting.shopAccessTokenExpire != null &&
        _setting.shopAccessTokenExpire.isAfter(DateTime.now())) {
      try {
        var result = await _tposApiService.getLoginInfoFromRefreshToken(
            refreshToken: _setting.shopRefreshAccessToken);
        if (result != null) {
          _setting.shopAccessToken = result.accessToken;
          _setting.shopRefreshAccessToken = result.refreshToken;
          _setting.shopAccessTokenExpire = result.expires;
          _tposApiService.setAuthenticationInfo(
              accessToken: result.accessToken);
        }
      } catch (ex, stack) {
        logger.error("refreshToken fail", ex, stack);
        this.logout();
      }
    }
  }

  Future<void> switchCompany(int targetCompanyId) async {
    try {
      // call switch company
      await _tposApiService.switchCompany(targetCompanyId);
      // refresh access token
      await refreshToken();
      // refresh company info
      _companyCurrentInfo = await _tposApiService.getCompanyCurrentInfo();
      // Refresh current company info
      _loadCompanyInfo();
      notifyListeners();
    } catch (e, s) {
      logger.error("switchCompany", e, s);
    }
  }

  Future getCurrentCompanyCommand() async {
    try {
      await _loadCompanyInfo();
    } catch (e, s) {
      logger.error("get compnay current", e, s);
    }
  }

  /// get current company id and refresh information
  Future _loadCompanyInfo() async {
    var result = await _companyApi.getCompanyCurrent();
    _selectedCompany = await _tposApi.company.getById(result.companyId);
    notifyListeners();
  }

  /// Cập nhật lại  thông tin người đang đăng nhập
  Future refreshLoginInfo() async {
    this._loginUser = await _tposApiService.getLoginedUserInfo();
    notifyListeners();
  }

  /// Lấy danh sách menu homepage
  List<MenuItem> getHomeMenu({bool isGroupByGroup}) {
    var results = this
        .getAllMenu()
        .where((f) => _setting.homeMenus.any((s) => s == f.id))
        .toList();

    return results;
  }

  /// Lấy permission
  bool getWebPermission(String permissionName) {
    if (userPermission == null) return true;
    return userPermission.any((f) => f == permissionName);
  }

  /// Lấy menu có phân quyền
  List<MenuItem> getAllMenu() {
    var results = this.menus.where((f) => f.visible).toList();

    return results;
  }

  //  Thêm menu đã dùng  gần đây
  void addMenuSuggest(String id) {
    if (_setting.menuRecents.any((f) => f == id)) {
      _setting.menuRecents.remove(id);
    }
    _setting.menuRecents.insert(0, id);
  }

  /// Đăng xuất
  @override
  Future<void> logout() async {
    locator<ISettingService>().shopAccessToken = null;
    locator<ISettingService>().shopAccessTokenExpire = null;

    await logoutLocator();
    _isInitWithServer = false;
    _isInit = false;
  }
}

class AppMessage {
  Object sender;
  Object receiver;
  String message;
  Type senderType;
  Type receiverType;

  AppMessage(
      {this.sender,
      this.receiver,
      this.message,
      this.senderType,
      this.receiverType});
}

class ObjectChangedMessage extends AppMessage {
  Object value;
  Type valueType;

  ObjectChangedMessage(
      {Object sender,
      Object receiver,
      String message,
      Type senderType,
      Type receiverType,
      this.value,
      this.valueType}) {
    this.sender = sender;
    this.receiver = receiver;
    this.message = message;
    this.senderType = senderType;
    this.receiverType = receiverType;
  }
}

class ActionMessage extends AppMessage {
  String action;
}

class MenuItem {
  final String id;
  final String groupId;
  final Widget icon;
  final String label;
  final Function onPressed;
  final String routeName;
  final String parentRouteName;
  bool visible;
  final String permissionName;

  MenuItem(
      {this.id,
      this.groupId,
      this.icon,
      this.label,
      this.onPressed,
      this.routeName,
      this.visible = true,
      this.parentRouteName,
      this.permissionName});
}

class MenuGroup {
  final String id;

  final String routeName;
  final Widget icon;
  final String name;

  MenuGroup({this.id, this.name, this.routeName, this.icon});
}
