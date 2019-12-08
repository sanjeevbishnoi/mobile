/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 2:58 PM
 *
 */

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/tpos_apis/models/base_list_order_by_type.dart';

const String shopUrlKey = "shopUrl";
const String shopUsernameKey = "shopUsername";
const String computerIpKey = "computerIp";
const String computerPortKey = "computerPort";
const String lanPrinterIpKey = "lanPrinterIp";
const String lanPrinterPortKey = "lanPrinterPort";

const String isEnablePrintSaleOnlineKey = "isEnablePrintSaleOnline";
const String isSaleOnlinePrintAddressKey = "isSaleOnlinePrintAddress";
const String isSaleOnlinePrintCommentKey = 'isSaleOnlinePrintComment';
const String isSaleOnlinePrintPartnerNoteKey = "isSaleOnlinePrintPartnerNote";
const String isSaleOnlinePrintAllOrderNoteKey = "isSaleOnlinePrintAllOrderNote";
const String isSaleOnlineConnectFailEnableActionKey =
    "isSaleOnlineConnectFailEnableAction";
const String secondRefreshLiveCommentKey = "secondRefreshLiveComment";
const String isAllowPrintSaleOnlineManyTimeKey =
    "isAllowPrintSaleOnlineManyTime";
const String printSaleOnlineMethodKey = "printSaleOnlineMethod";
const String shopAccessTokenKey = "shopAccessToken";
const String shopRefreshAccessTokenKey = "shopRefreshAccessToken";
const String shopAccessTokendExpireKey = "shopAccessTokenExpire";
const String saleOnlineOrderListFilterByTimeIndexKey =
    "saleOnlineOrderListFilterByTimeIndex";

const String saleOnlineOrderListFilterByStatusIndexKey =
    "saleOnlineOrderListFilterByStatusIndex";

const String productSearchOrderByIndexKey = "productSearchOrderByIndex";
const String isProductSearchViewListKey = "isProductSearchViewList";
const String isSaleOnlinePrintCustomHeaderKey = "isSaleOnlinePrintCustoHeader";
const String saleOnlinePrintCustomHeaderContentKey =
    "saleOnlinePrintCustomHeader";
const String isSaleOnlineViewCommentTimeAgoOnLiveKey =
    "isSaleOnlineViewCommentTimeAgoOnLive";
const String isSaleOnlineViewCommentTimeAgoOnPostKey =
    "isSaleOnlineViewCommentTimeAgoOnPost";
const String isSaleOnlineAutoLoadAllCommentOnLiveKey =
    "isSaleOnlineAutoLoadAllCommentOnLive";
const String isSaleOnlineAutoLoadAllCommentOnPostKey =
    "isSaleOnlineAutoLoadAllCommentOnPost";

const String saleOnlineCommentDefaultOrderByOnLiveKey =
    "saleOnlineDefaultOrderByOnLive";
const String saleOnlineCommentDefaultOrderByOnPostKey =
    "saleOnlineDefaultOrderByOnPost";

const String saleOnlineFetchCommentOnRealtimeRateKey =
    "saleOnlineFetchCommentOnRealtimeRate";
const String addExistsProductWarningKey = "addExistsProductWarning";
const String locateKey = "setting_locate";
const String SETTING_FAST_SALE_ORDER_IS_HIDE_DELIVERY_ADDRESS_KEY =
    "setting_fast_sale_order_is_hide_delivery_address";
const String SETTING_FAST_SALE_ORDER_HIDE_DELIVERY_CARRIER_KEY =
    "setting_fast_sale_order_is_hide_delivery_carrier";
const String
    SETTING_FAST_SALE_ORDER_IS_PAYMENT_IS_NEXT_PAYMENT_TO_COMPLETE_INVOICE_KEY =
    "setting_fast_sale_order_is_next_payment_to_complete_invoice";
const String SETTING_FAST_SALE_ORDER_IS_AUTO_INPUT_PAYMENT_AMOUNT_KEY =
    "setting_fast_sale_order_is_auto_input_payment_amount";

const String SETTING_FAST_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY =
    "setting_fast_sale_order_show_info_after_save";

const String SETTING_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY =
    "setting_sale_order_show_info_after_save";

const String SETTING_IS_HIDE_HOME_PAGE_SUGGESS_KEY =
    "settig_is_hide_home_page_suggess_key";

const String SETTING_HOME_PAGE_MENU_KEY = "setting_home_page_menu";
const String SETTING_LAST_APP_VERSION_KEY = "setting_last_app_version";
const String SETTING_IS_APP_UPDATED_KEY = "setting_is_app_updated";
const String SETTING_PRINTER_LIST_KEY = "setting_printer_list";
const String SETTING_MENU_RECENT_KEY = "setting_menu_recent";
const String SETTING_IS_SHOW_ALL_MENU_IN_HOME_PAGE_KEY =
    "setting_is_show_all_menu_in_home_page";

const String SETTING_IS_SHOW_GROUP_HOME_KEY = "setting_is_show_group_home_key";
const String SETTING_SHIP_NOTE_KEY = "setting_ship_note";
const String SETTING_SHIP_SIZE_KEY = "setting_ship_size";
const String SETTING_FAST_SALE_ORDER_PRINT_SHIP_AFTER_CONFIRM_KEY =
    "setting_fast_sale_order_print_ship_after_confirm";
const String SETTING_FAST_SALE_ORDER_PRINTER_NAME =
    "setting_fast_sale_order_printer_name";
const String SETTING_FAST_SALE_ORDER_PRINT_SIZE =
    "setting_fast_sale_order_print_size";
const String SETTING_SALE_ONLINE_PRINT_NO_SIGN =
    "setting_sale_online_print_no_sign";

const String SETTING_SALE_ONLINE_PRINT_CONTENT_KEY =
    "setting_sale_online_print_content";
const String SETTING_SALE_ONLINE_SAVE_COMMENT_MINUTE_KEY =
    "setting_sale_online_save_comment_minute";

const String SETTING_IS_SHARE_GAME_KEY = "setting_is_share_game";

const String SETTING_IS_COMMENT_GAME_KEY = "setting_is_comment_game";

const String SETTING_IS_DAYS_GAME_KEY = "days";

const String SETTING_IS_ORDER_GAME_KEY = "setting_is_order_game";

const String SETTING_IS_WIN_GAME_KEY = "setting_is_win_game";

const String SETTING_IS_PRIOR_GAME_KEY = "setting_is_prior_game";
const String SETTING_SALE_ONLINE_HIDE_SHORT_COMMENT_KEY =
    "setting_sale_online_hide_short_comment";

const String SETTING_PRINT_SHIP_SHOW_PRODUCT_QUANTITY_KEY =
    "setting_print_ship_show_product_quantity";
const String SETTING_PRINT_SHIP_SHOW_DEPOSIT_AMOUNT_KEY =
    "setting_print_ship_show_deposit_amount";

enum PrintSaleOnlineMethod { LanPrinter, ComputerPrinter }
enum SettingAddExistsProductWarning { ADD_QUANTITY, CONFIRM_QUESTION, SKIP }
enum SaleOnlineCommentOrderBy { DATE_CREATED_ASC, DATE_CREATE_DESC }

const supportPrinterProfiles = {
  "sale_online": {
    "tpos_printer": [
      {"code": "A5Portrait", "name": "A5 dọc"},
      {"code": "A4Portrait", "name": "A4 dọc"},
      {"code": "BILL80", "name": "BILL 80mm"},
    ]
  },
  "ship": {
    "tpos_printer": [
      {"code": "A5Portrait", "name": "A5 dọc"},
      {"code": "A4Portrait", "name": "A4 dọc"},
      {"code": "BILL80", "name": "BILL 80mm"},
    ],
    "esc_pos": [
      {"code": "BILL80", "name": "BILL 80mm (Raw-nhanh)"},
      {"code": "BILL80-IMAGE", "name": "BILL 80mm (Đẹp hơn-chậm)"},
    ],
    "preview": [
      {"code": "AUTO", "name": "Tự động"},
      {"code": "BILL80", "name": "BILL80"},
      {"code": "A5", "name": "A5"},
      {"code": "A4", "name": "A4"},
    ],
  },
  "fast_sale_order": {
    "preview": [
      {"code": "AUTO", "name": "Tự động"},
      {"code": "A5", "name": "A5"},
      {"code": "A4", "name": "A4"},
    ],
    "tpos_printer": [
      {"code": "BILL80", "name": "BILL 80mm"},
      {"code": "A5Lanscape", "name": "A5 ngang"},
      {"code": "A4Portrait", "name": "A4 dọc"},
    ],
    "esc_pos": [
      {"code": "BILL80", "name": "BILL 80mm (Raw-nhanh)"},
      {"code": "BILL80-IMAGE", "name": "BILL 80mm (Đẹp hơn-chậm)"},
    ],
  }
};

final List<PrinterDevice> defaultPrinterDevices = <PrinterDevice>[
  PrinterDevice(
      type: "preview",
      ip: "null",
      port: null,
      name: "Xem và in",
      isDefault: true),
  PrinterDevice(
      type: "tpos_printer",
      ip: "192.168.1.200",
      port: 8123,
      name: "TPos Printer (In qua máy tính)",
      isDefault: true),
  PrinterDevice(
      type: "esc_pos",
      ip: "192.168.1.200",
      port: 9100,
      name: "Máy ESC/POS (In qua Wifi)",
      isDefault: true),
];

abstract class ISettingService {
  bool isAllowPrintSaleOnlineManyTime;
  bool isEnablePrintSaleOnline;
  bool isSaleOnlinePrintAddress;
  bool isSaleOnlinePrintComment;
  bool isSaleOnlinePrintAllOrderNote;
  bool isSaleOnlinePrintPartnerNote;
  bool isSaleOnlineEnableConnectFailAction;
  bool isSaleOnlinePrintCustomHeader;
  String saleOnlinePrintCustomHeaderContent;
  int secondRefreshComment;
  String shopUrl;
  String shopUsername;

  String computerIp;
  String computerPort;
  String lanPrinterIp;
  String lanPrinterPort;
  PrintSaleOnlineMethod printMethod;
  String shopAccessToken;
  String shopRefreshAccessToken;
  DateTime shopAccessTokenExpire;

  int saleOnlineOrderListFilterByTimeIndex;
  int saleOnlineOrderListFilterByStatusIndex;

  int productSearchOrderByIndex;
  bool isProductSearchViewList;
  bool isSaleOnlineViewTimeAgoOnLiveComment;
  bool isSaleOnlineViewTimeAgoOnPostComment;
  bool isSaleOnlineAutoLoadAllCommentOnLive;
  bool isSaleOnlineAutoLoadAllCommentOnPost;
  bool isSaleOnlineHideShortComment;
  SettingAddExistsProductWarning addExistsProductWarning;

  SaleOnlineCommentOrderBy saleOnlineCommentDefaultOrderByOnLive;
  SaleOnlineCommentOrderBy saleOnlineCommentDefaultOrderByOnPost;

  CommentRate saleOnlineFetchCommentOnRealtimeRate;
  bool isHideDeliveryAddressInFastSaleOrder;
  bool isHideDeliveryCarrierInFastSaleOrder;
  bool isNextPaymentForCompleteInvoiceInFastSaleOrder;
  bool isAutoInputPaymentAmountInFastSaleOrder;
  bool isShowInfoInvoiceAfterSaveFastSaleOrder;
  bool isShowInfoInvoiceAfterSaveSaleOrder;
  bool isHideHomePageSuggess;
  Future initService();
  String locate;
  String lastAppVersion;
  bool isAppUpdated;
  List<PrinterDevice> printers;
  List<String> homeMenus;
  List<String> menuRecents;
  bool isShowAllMenuInHomePage;
  bool isShowGroupHeaderOnHome;

  // Game
  bool isShareGame;
  bool isCommentGame;
  bool isOrderGame;
  bool isWinGame;
  bool settingGameIsIgroneRecentWinner;
  int days;
  String isPriorGame;

  String shipPrinterName;
  String shipNote;
  String shipSize;
  String saleOnlineSize;
  bool settingFastSaleOrderPrintShipAfterConfirm;

  String fastSaleOrderInvoicePrinterName;
  String fastSaleOrderInvoicePrintSize;

  /// Check if shop url and token is valid for re login or goto homepage
  bool get isShopTokenValid;

  int settingSaleOnlineAutoSaveCommentMinute;

  List<PrintTemplate> getSuportPrintTemplateByPrinterType(
      String print, String printerType);

  /// save facebook accesstoken only on app run
  String facebookAccessToken;

  /// In không dấu nếu máy in không hỗ trợ
  bool settingPrintSaleOnlineNoSign;
  List<SupportPrintSaleOnlineRow> get supportSaleOnlinePrintRow;
  List<SupportPrintSaleOnlineRow> settingSaleOnlinePrintContents;
  List<SupportPrintSaleOnlineRow> get defaultSaleOnlinePrintRow;

  bool settingPrintShipShowDepositAmount;
  bool settingPrintShipShowProductQuantity;

  /// Cài đặt sale online
  /// Tải bình luận thủ công tự động
  bool saleOnlineFetchDurationEnableOnLive;

  /// Thời gian tự động tải bình luận ẩn trong khi live
  int _saleOnlineFetchDurationOnliveSecond;

  /// Thời gian lọc sẽ lưu
  String saleOnlineOrderListFilterDate;
}

class AppSettingService implements ISettingService {
  SharedPreferences prefs;
  AppSettingService() {
    // initService();
  }
  Future<void> initService() async {
    prefs = await SharedPreferences.getInstance();
  }

  void initCommand() {}

  List<SupportPrintSaleOnlineRow> _supportSaleOnlinePrintRow = [
    new SupportPrintSaleOnlineRow(
        name: "header", description: "Header (Tên công ty, sđt, địa chỉ..."),
    new SupportPrintSaleOnlineRow(
        name: "uid",
        bold: true,
        fontSize: 2,
        description: "UID Facebook khách hàng"),
    new SupportPrintSaleOnlineRow(
        name: "name", bold: true, fontSize: 2, description: "Tên khách hàng"),
    new SupportPrintSaleOnlineRow(
        name: "phone",
        bold: true,
        fontSize: 2,
        description: "Số điện thoại khách hàng"),
    new SupportPrintSaleOnlineRow(
        name: "address", description: "Địa chỉ khách hàng (Nếu có)"),
    new SupportPrintSaleOnlineRow(
        name: "partnerCode", fontSize: 2, description: "Mã khách hàng"),
    new SupportPrintSaleOnlineRow(
        name: "productName", description: "Tên sản phẩm"),
    new SupportPrintSaleOnlineRow(
        name: "orderIndex",
        bold: true,
        fontSize: 2,
        description: "Số thứ tự đơn hàng"),
    new SupportPrintSaleOnlineRow(
        name: "orderCode", bold: true, fontSize: 2, description: "Mã đơn hàng"),
    new SupportPrintSaleOnlineRow(
        name: "orderIndexAndCode",
        bold: true,
        fontSize: 2,
        description: "Số thứ tự và mã đơn hàng"),
    new SupportPrintSaleOnlineRow(
        name: "orderTime", description: "Giờ đặt hàng"),
    new SupportPrintSaleOnlineRow(
        name: "comment", description: "Bình luận (Khi live)"),
    new SupportPrintSaleOnlineRow(
        name: "note", description: "Ghi chú đơn hàng"),
    new SupportPrintSaleOnlineRow(
        name: "printTime", description: "Thời gian in"),
    new SupportPrintSaleOnlineRow(
        name: "partnerStatus", description: "Trạng thái khách hàng"),
    new SupportPrintSaleOnlineRow(
        name: "partnerCodeAndStatus",
        description: "Mã khách hàng và trạng thái"),
  ];

  List<SupportPrintSaleOnlineRow> _defaultSaleOnlinePrintRow = [
    new SupportPrintSaleOnlineRow(
        name: "header", description: "Header (Tên công ty, sđt, địa chỉ..."),
    new SupportPrintSaleOnlineRow(
        name: "orderIndexAndCode", bold: true, fontSize: 2),
    new SupportPrintSaleOnlineRow(
        name: "name", bold: true, fontSize: 2, description: "Tên khách hàng"),
    new SupportPrintSaleOnlineRow(name: "phone", bold: false, fontSize: 2),
    new SupportPrintSaleOnlineRow(name: "uid", bold: true, fontSize: 2),
    new SupportPrintSaleOnlineRow(
      name: "productName",
    ),
    new SupportPrintSaleOnlineRow(name: "printTime", fontSize: 2),
    new SupportPrintSaleOnlineRow(name: "address"),
    new SupportPrintSaleOnlineRow(name: "comment"),
  ];
  List<SupportPrintSaleOnlineRow> get supportSaleOnlinePrintRow =>
      _supportSaleOnlinePrintRow;
  List<SupportPrintSaleOnlineRow> get defaultSaleOnlinePrintRow =>
      _defaultSaleOnlinePrintRow;

  String _shopUrl;
  String _shopUsername;
  String _computerIp;
  String _computerPort;
  String _lanPrinterIp;
  String _lanPrinterPort;
  bool _isEnablePrintSaleOnline;
  bool _isSaleOnlinePrintAddress;
  bool _isSaleOnlinePrintPartnerNote;
  bool _isSaleOnlinePrintComment;
  bool _isAllowPrintSaleOnlineManyTime;
  bool _isSaleOnlineEnableConnectFailAction;
  String _shopAccessToken;
  DateTime _shopAccessTokenExpire;
  String _shopRefreshAccessToken;
  PrintSaleOnlineMethod _printMethod;
  int _secondRefreshComment;
  int _saleOnlineOrderListFilterByTimeIndex;

  String get shopUrl =>
      _shopUrl ??
      (_shopUrl = prefs.get(shopUrlKey)) ??
      "https://tenshop.tpos.vn";
  String get shopUsername =>
      _shopUsername ?? (_shopUsername = prefs.get(shopUsernameKey)) ?? "";
  String get computerIp =>
      _computerIp ?? (_computerIp = prefs.get(computerIpKey)) ?? "192.168.1.1";
  String get computerPort =>
      _computerPort ?? (_computerPort = prefs.get(computerPortKey)) ?? "8123";
  String get lanPrinterIp =>
      _lanPrinterIp ??
      (_lanPrinterIp = prefs.get(lanPrinterIpKey)) ??
      "192.168.1.87";
  String get lanPrinterPort =>
      _lanPrinterPort ??
      (_lanPrinterPort = prefs.get(lanPrinterPortKey)) ??
      "9100";
  PrintSaleOnlineMethod get printMethod =>
      _printMethod ??
      (_printMethod = PrintSaleOnlineMethod.values[
          prefs.get(printSaleOnlineMethodKey) ??
              PrintSaleOnlineMethod.ComputerPrinter.index]) ??
      PrintSaleOnlineMethod.ComputerPrinter;
  bool get isEnablePrintSaleOnline =>
      _isEnablePrintSaleOnline ??
      (_isEnablePrintSaleOnline = prefs.get(isEnablePrintSaleOnlineKey)) ??
      true;

  bool get isSaleOnlinePrintAddress =>
      _isSaleOnlinePrintAddress ??
      (_isSaleOnlinePrintAddress = prefs.get(isSaleOnlinePrintAddressKey)) ??
      false;

  bool get isSaleOnlinePrintPartnerNote =>
      _isSaleOnlinePrintPartnerNote ??
      (_isSaleOnlinePrintPartnerNote =
          prefs.get(isSaleOnlinePrintPartnerNoteKey)) ??
      false;
  bool get isSaleOnlinePrintComment =>
      _isSaleOnlinePrintComment ??
      (_isSaleOnlinePrintComment = prefs.get(isSaleOnlinePrintCommentKey)) ??
      false;
  bool get isAllowPrintSaleOnlineManyTime =>
      _isAllowPrintSaleOnlineManyTime ??
      (_isAllowPrintSaleOnlineManyTime =
          prefs.get(isAllowPrintSaleOnlineManyTimeKey)) ??
      true;

  String get shopAccessToken =>
      _shopAccessToken ??
      (_shopAccessToken = prefs.get(shopAccessTokenKey)) ??
      "";
  String get shopRefreshAccessToken =>
      _shopRefreshAccessToken ??
      (_shopRefreshAccessToken = prefs.get(shopRefreshAccessTokenKey)) ??
      "";
  DateTime get shopAccessTokenExpire {
    if (_shopAccessTokenExpire == null) {
      String valueString = prefs.getString(shopAccessTokendExpireKey);
      if (valueString != null && valueString != "") {
        _shopAccessTokenExpire =
            DateTime.parse(prefs.get(shopAccessTokendExpireKey));
      }
    }
    return _shopAccessTokenExpire;
  }

  @override
  bool get isSaleOnlineEnableConnectFailAction =>
      _isSaleOnlineEnableConnectFailAction ??
      (_isSaleOnlineEnableConnectFailAction =
          prefs.get(isSaleOnlineConnectFailEnableActionKey)) ??
      false;

  @override
  int get secondRefreshComment =>
      _secondRefreshComment ??
      (_secondRefreshComment = prefs.get(secondRefreshLiveCommentKey)) ??
      5;

  int get saleOnlineOrderListFilterByTimeIndex =>
      _saleOnlineOrderListFilterByTimeIndex ??
      (_saleOnlineOrderListFilterByTimeIndex =
          prefs.get(saleOnlineOrderListFilterByTimeIndexKey) ?? 0);

  set shopUrl(String value) {
    _shopUrl = value;
    prefs.setString(shopUrlKey, value);
  }

  set shopUsername(String value) {
    _shopUsername = value;
    prefs.setString(shopUsernameKey, value);
  }

  set shopAccessToken(String value) {
    _shopAccessToken = value;
    prefs.setString(shopAccessTokenKey, value);
  }

  set shopRefreshAccessToken(String value) {
    _shopRefreshAccessToken = value;
    prefs.setString(shopRefreshAccessTokenKey, value);
  }

  set computerIp(String value) {
    _computerIp = value;
    prefs.setString(computerIpKey, value);
  }

  set computerPort(String value) {
    _computerPort = value;
    prefs.setString(computerPortKey, value);
  }

  set lanPrinterIp(String value) {
    _lanPrinterIp = value;
    prefs.setString(lanPrinterIpKey, value);
  }

  set lanPrinterPort(String value) {
    _lanPrinterPort = value;
    prefs.setString(lanPrinterPortKey, value);
  }

  set printMethod(PrintSaleOnlineMethod value) {
    _printMethod = value;
    prefs.setInt(printSaleOnlineMethodKey, value.index);
  }

  set shopAccessTokenExpire(DateTime value) {
    _shopAccessTokenExpire = value;
    prefs.setString(shopAccessTokendExpireKey, value.toString());
  }

  set isAllowPrintSaleOnlineManyTime(bool value) {
    _isAllowPrintSaleOnlineManyTime = value;
    prefs.setBool(isAllowPrintSaleOnlineManyTimeKey, value);
  }

  set isEnablePrintSaleOnline(bool value) {
    _isEnablePrintSaleOnline = value;
    prefs.setBool(isEnablePrintSaleOnlineKey, value);
  }

  set isSaleOnlinePrintAddress(bool value) {
    _isSaleOnlinePrintAddress = value;
    prefs.setBool(isSaleOnlinePrintAddressKey, value);
  }

  set isSaleOnlinePrintComment(bool value) {
    _isSaleOnlinePrintComment = value;
    prefs.setBool(isSaleOnlinePrintCommentKey, value);
  }

  set isSaleOnlinePrintPartnerNote(bool value) {
    _isSaleOnlinePrintPartnerNote = value;
    prefs.setBool(isSaleOnlinePrintPartnerNoteKey, value);
  }

  set isSaleOnlineEnableConnectFailAction(bool value) {
    _isSaleOnlineEnableConnectFailAction = value;
    prefs.setBool(isSaleOnlineConnectFailEnableActionKey, value);
  }

  set secondRefreshComment(int value) {
    _secondRefreshComment = value;
    prefs.setInt(secondRefreshLiveCommentKey, value);
  }

  set saleOnlineOrderListFilterByTimeIndex(int value) {
    _saleOnlineOrderListFilterByTimeIndex = value;
    prefs.setInt(saleOnlineOrderListFilterByTimeIndexKey, value);
  }

  int _saleOnlineOrderListFilterByStatusIndex;
  int get saleOnlineOrderListFilterByStatusIndex =>
      _saleOnlineOrderListFilterByStatusIndex ??
      (_saleOnlineOrderListFilterByStatusIndex =
          prefs.get(saleOnlineOrderListFilterByStatusIndexKey)) ??
      0;

  set saleOnlineOrderListFilterByStatusIndex(int value) {
    _saleOnlineOrderListFilterByStatusIndex = value;
    prefs.setInt(saleOnlineOrderListFilterByStatusIndexKey, value);
  }

  int _productSearchOrderByIndex;
  int get productSearchOrderByIndex =>
      _productSearchOrderByIndex ??
      (_productSearchOrderByIndex = prefs.get(productSearchOrderByIndexKey)) ??
      BaseListOrderBy.NAME_ASC;

  set productSearchOrderByIndex(int value) {
    _productSearchOrderByIndex = value;
    prefs.setInt(productSearchOrderByIndexKey, value);
  }

  bool _isProductSearchViewList;
  bool get isProductSearchViewList =>
      _isProductSearchViewList ??
      (_isProductSearchViewList = prefs.get(isProductSearchViewListKey)) ??
      true;

  set isProductSearchViewList(bool value) {
    _isProductSearchViewList = value;
    prefs.setBool(isProductSearchViewListKey, value);
  }

  bool _isSaleOnlinePrintAllOrderNote;
  bool get isSaleOnlinePrintAllOrderNote =>
      _isSaleOnlinePrintAllOrderNote ??
      (_isSaleOnlinePrintAllOrderNote =
          prefs.get(isSaleOnlinePrintAllOrderNoteKey)) ??
      false;

  set isSaleOnlinePrintAllOrderNote(bool value) {
    _isSaleOnlinePrintAllOrderNote = value;
    prefs.setBool(isSaleOnlinePrintAllOrderNoteKey, value);
  }

  bool _isSaleOnlinePrintCustomHeader;

  bool get isSaleOnlinePrintCustomHeader =>
      _isSaleOnlinePrintCustomHeader ??
      (_isSaleOnlinePrintCustomHeader =
          prefs.get(isSaleOnlinePrintCustomHeaderKey)) ??
      false;

  set isSaleOnlinePrintCustomHeader(bool value) {
    _isSaleOnlinePrintCustomHeader = value;
    prefs.setBool(isSaleOnlinePrintCustomHeaderKey, value);
  }

  String _saleOnlinePrintCustomHeaderContent;

  String get saleOnlinePrintCustomHeaderContent =>
      _saleOnlinePrintCustomHeaderContent ??
      (_saleOnlinePrintCustomHeaderContent =
          prefs.get(saleOnlinePrintCustomHeaderContentKey)) ??
      "";

  set saleOnlinePrintCustomHeaderContent(String value) {
    _saleOnlinePrintCustomHeaderContent = value;
    prefs.setString(saleOnlinePrintCustomHeaderContentKey, value);
  }

  bool _isSaleOnlineViewTimeAgoOnLiveComment;
  bool get isSaleOnlineViewTimeAgoOnLiveComment =>
      _isSaleOnlineViewTimeAgoOnLiveComment ??
      (_isSaleOnlineViewTimeAgoOnLiveComment =
          prefs.getBool(isSaleOnlineViewCommentTimeAgoOnLiveKey)) ??
      true;
  set isSaleOnlineViewTimeAgoOnLiveComment(bool value) {
    _isSaleOnlineViewTimeAgoOnLiveComment = value;
    prefs.setBool(isSaleOnlineViewCommentTimeAgoOnLiveKey, value);
  }

  bool _isSaleOnlineViewTimeAgoOnPostComment;
  bool get isSaleOnlineViewTimeAgoOnPostComment =>
      _isSaleOnlineViewTimeAgoOnPostComment ??
      (_isSaleOnlineViewTimeAgoOnPostComment =
          prefs.getBool(isSaleOnlineViewCommentTimeAgoOnLiveKey)) ??
      true;
  set isSaleOnlineViewTimeAgoOnPostComment(bool value) {
    _isSaleOnlineViewTimeAgoOnPostComment = value;
    prefs.setBool(isSaleOnlineViewCommentTimeAgoOnPostKey, value);
  }

  bool _isSaleOnlineAutoLoadAllCommentOnLive;
  bool get isSaleOnlineAutoLoadAllCommentOnLive =>
      _isSaleOnlineAutoLoadAllCommentOnLive ??
      (_isSaleOnlineAutoLoadAllCommentOnLive =
          prefs.get(isSaleOnlineAutoLoadAllCommentOnLiveKey)) ??
      false;
  set isSaleOnlineAutoLoadAllCommentOnLive(bool value) {
    _isSaleOnlineAutoLoadAllCommentOnLive = value;
    prefs.setBool(isSaleOnlineAutoLoadAllCommentOnLiveKey, value);
  }

  bool _isSaleOnlineAutoLoadAllCommentOnPost;

  bool get isSaleOnlineAutoLoadAllCommentOnPost =>
      _isSaleOnlineAutoLoadAllCommentOnPost ??
      (_isSaleOnlineAutoLoadAllCommentOnPost =
          prefs.getBool(isSaleOnlineAutoLoadAllCommentOnPostKey)) ??
      false;

  set isSaleOnlineAutoLoadAllCommentOnPost(bool value) {
    _isSaleOnlineAutoLoadAllCommentOnPost = value;
    prefs.setBool(isSaleOnlineAutoLoadAllCommentOnPostKey, value);
  }

  SaleOnlineCommentOrderBy _saleOnlineCommentDefaultOrderByOnLive;
  SaleOnlineCommentOrderBy get saleOnlineCommentDefaultOrderByOnLive {
    if (_saleOnlineCommentDefaultOrderByOnLive != null) {
      return _saleOnlineCommentDefaultOrderByOnLive;
    }

    String value = prefs.getString(saleOnlineCommentDefaultOrderByOnLiveKey);
    return SaleOnlineCommentOrderBy.values
            .firstWhere((f) => f.toString() == value, orElse: () => null) ??
        SaleOnlineCommentOrderBy.DATE_CREATE_DESC;
  }

  set saleOnlineCommentDefaultOrderByOnLive(SaleOnlineCommentOrderBy value) {
    _saleOnlineCommentDefaultOrderByOnLive = value;
    prefs.setString(saleOnlineCommentDefaultOrderByOnLiveKey, value.toString());
  }

  SaleOnlineCommentOrderBy _saleOnlineCommentDefaultOrderByOnPost;
  SaleOnlineCommentOrderBy get saleOnlineCommentDefaultOrderByOnPost {
    if (_saleOnlineCommentDefaultOrderByOnPost != null) {
      return _saleOnlineCommentDefaultOrderByOnPost;
    }

    String value = prefs.getString(saleOnlineCommentDefaultOrderByOnPostKey);
    return SaleOnlineCommentOrderBy.values.firstWhere(
        (f) => f.toString() == value,
        orElse: () => SaleOnlineCommentOrderBy.DATE_CREATE_DESC);
  }

  set saleOnlineCommentDefaultOrderByOnPost(SaleOnlineCommentOrderBy value) {
    _saleOnlineCommentDefaultOrderByOnPost = value;
    prefs.setString(saleOnlineCommentDefaultOrderByOnPostKey, value.toString());
  }

  CommentRate _saleOnlineFetchCommentOnRealtimeRate;
  CommentRate get saleOnlineFetchCommentOnRealtimeRate {
    if (_saleOnlineFetchCommentOnRealtimeRate != null) {
      return _saleOnlineFetchCommentOnRealtimeRate;
    }

    String value = prefs.getString(saleOnlineFetchCommentOnRealtimeRateKey);
    if (value != null) {
      return CommentRate.values
              .firstWhere((f) => f.toString() == value, orElse: () => null) ??
          CommentRate.one_hundred_per_second;
    } else {
      return CommentRate.one_hundred_per_second;
    }
  }

  set saleOnlineFetchCommentOnRealtimeRate(CommentRate value) {
    _saleOnlineFetchCommentOnRealtimeRate = value;
    prefs.setString(saleOnlineFetchCommentOnRealtimeRateKey, value.toString());
  }

  SettingAddExistsProductWarning _addExistsProductWarning;
  SettingAddExistsProductWarning get addExistsProductWarning {
    if (_addExistsProductWarning == null) {
      String value = prefs.getString(addExistsProductWarningKey);
      _addExistsProductWarning = SettingAddExistsProductWarning.values
          .firstWhere((f) => f.toString() == value,
              orElse: () => SettingAddExistsProductWarning.ADD_QUANTITY);
    }

    return _addExistsProductWarning;
  }

  set addExistsProductWarning(SettingAddExistsProductWarning value) {
    _addExistsProductWarning = value;
    prefs.setString(addExistsProductWarningKey, value.toString());
  }

  String _locate;
  String get locate => _locate ?? (_locate = prefs.get(locateKey)) ?? "vi_VN";
  set locate(String value) {
    _locate = value;
    prefs.setString(locateKey, value);
  }

  bool _isHideDeliveryAddressInFastSaleOrder;
  bool get isHideDeliveryAddressInFastSaleOrder =>
      _isHideDeliveryAddressInFastSaleOrder ??
      (_isHideDeliveryAddressInFastSaleOrder = prefs
          .getBool(SETTING_FAST_SALE_ORDER_IS_HIDE_DELIVERY_ADDRESS_KEY)) ??
      false;

  set isHideDeliveryAddressInFastSaleOrder(bool value) {
    _isHideDeliveryAddressInFastSaleOrder = value;
    prefs.setBool(SETTING_FAST_SALE_ORDER_IS_HIDE_DELIVERY_ADDRESS_KEY, value);
  }

  bool _isHideDeliveryCarrierInFastSaleOrder;
  bool get isHideDeliveryCarrierInFastSaleOrder =>
      _isHideDeliveryCarrierInFastSaleOrder ??
      (_isHideDeliveryCarrierInFastSaleOrder =
          prefs.getBool(SETTING_FAST_SALE_ORDER_HIDE_DELIVERY_CARRIER_KEY)) ??
      false;

  set isHideDeliveryCarrierInFastSaleOrder(bool value) {
    _isHideDeliveryCarrierInFastSaleOrder = value;
    prefs.setBool(SETTING_FAST_SALE_ORDER_HIDE_DELIVERY_CARRIER_KEY, value);
  }

  bool _isNextPaymentForCompleteInvoiceInFastSaleOrder;
  bool get isNextPaymentForCompleteInvoiceInFastSaleOrder =>
      _isNextPaymentForCompleteInvoiceInFastSaleOrder ??
      (prefs.getBool(
          SETTING_FAST_SALE_ORDER_IS_PAYMENT_IS_NEXT_PAYMENT_TO_COMPLETE_INVOICE_KEY)) ??
      false;

  set isNextPaymentForCompleteInvoiceInFastSaleOrder(bool value) {
    _isNextPaymentForCompleteInvoiceInFastSaleOrder = value;
    prefs.setBool(
        SETTING_FAST_SALE_ORDER_IS_PAYMENT_IS_NEXT_PAYMENT_TO_COMPLETE_INVOICE_KEY,
        value);
  }

  bool _isAutoInputPaymentAmountInFastSaleOrder;
  bool get isAutoInputPaymentAmountInFastSaleOrder =>
      _isAutoInputPaymentAmountInFastSaleOrder ??
      (_isAutoInputPaymentAmountInFastSaleOrder = prefs
          .getBool(SETTING_FAST_SALE_ORDER_IS_AUTO_INPUT_PAYMENT_AMOUNT_KEY)) ??
      false;

  set isAutoInputPaymentAmountInFastSaleOrder(bool value) {
    _isAutoInputPaymentAmountInFastSaleOrder = value;
    prefs.setBool(
        SETTING_FAST_SALE_ORDER_IS_AUTO_INPUT_PAYMENT_AMOUNT_KEY, value);
  }

  bool _isShowInfoInvoiceAfterSaveFastSaleOrder;
  bool get isShowInfoInvoiceAfterSaveFastSaleOrder =>
      _isShowInfoInvoiceAfterSaveFastSaleOrder ??
      (_isShowInfoInvoiceAfterSaveFastSaleOrder =
          prefs.getBool(SETTING_FAST_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY)) ??
      true;

  set isShowInfoInvoiceAfterSaveFastSaleOrder(bool value) {
    _isShowInfoInvoiceAfterSaveFastSaleOrder = value;
    prefs.setBool(SETTING_FAST_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY, value);
  }

  bool _isShowInfoInvoiceAfterSaveSaleOrder;
  bool get isShowInfoInvoiceAfterSaveSaleOrder =>
      _isShowInfoInvoiceAfterSaveSaleOrder ??
      (_isShowInfoInvoiceAfterSaveSaleOrder =
          prefs.getBool(SETTING_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY)) ??
      true;

  set isShowInfoInvoiceAfterSaveSaleOrder(bool value) {
    _isShowInfoInvoiceAfterSaveSaleOrder = value;
    prefs.setBool(SETTING_SALE_ORDER_SHOW_INFO_AFTER_SAVE_KEY, value);
  }

  bool _isHideHomePageSuggess;
  bool get isHideHomePageSuggess =>
      _isHideHomePageSuggess ??
      (_isHideHomePageSuggess =
          prefs.getBool(SETTING_IS_HIDE_HOME_PAGE_SUGGESS_KEY)) ??
      false;

  set isHideHomePageSuggess(bool value) {
    _isHideHomePageSuggess = value;
    prefs.setBool(SETTING_IS_HIDE_HOME_PAGE_SUGGESS_KEY, value);
  }

  List<String> _homeMenus;
  List<String> get homeMenus {
    if (_homeMenus == null) {
      _homeMenus = prefs.getStringList(SETTING_HOME_PAGE_MENU_KEY);
    }
    return _homeMenus ?? ["1", "2", "3", "4", "5", "6", "7", "15", "12", "10"];
  }

  set homeMenus(List<String> value) {
    _homeMenus = value;
    prefs.setStringList(SETTING_HOME_PAGE_MENU_KEY, value);
  }

  String _lastAppVersion;
  String get lastAppVersion =>
      _lastAppVersion ??
      (_lastAppVersion = prefs.getString(SETTING_LAST_APP_VERSION_KEY)) ??
      "";

  set lastAppVersion(String value) {
    _lastAppVersion = value;
    prefs.setString(SETTING_LAST_APP_VERSION_KEY, value);
  }

  bool _isAppUpdate;
  bool get isAppUpdated =>
      _isAppUpdate ??
      (_isAppUpdate = prefs.getBool(SETTING_IS_APP_UPDATED_KEY)) ??
      true;

  set isAppUpdated(bool value) {
    _isAppUpdate = value;
    prefs.setBool(SETTING_IS_APP_UPDATED_KEY, value);
  }

  List<PrinterDevice> _printers;
  List<PrinterDevice> get printers {
    if (_printers == null) {
      try {
        var json = prefs.getString(SETTING_PRINTER_LIST_KEY);
        if (json != null && json != "") {
          _printers = (jsonDecode(json) as List)
              .map((f) => PrinterDevice.fromJson(f))
              .toList();
        }
      } catch (e, s) {
        print(s);
      }
    }
    return _printers ?? defaultPrinterDevices;
  }

  set printers(List<PrinterDevice> value) {
    if (value != null) {
      defaultPrinterDevices.forEach(
        (printer) {
          if (!value.any((f) => f.type == printer.type)) {
            value.add(printer);
          }
        },
      );

      var json = value.map((f) => f.toJson()).toList();
      var jsonHasEncode = jsonEncode(json);
      prefs.setString(SETTING_PRINTER_LIST_KEY, jsonHasEncode);
    }
  }

  List<String> _menuRecents = new List<String>();
  List<String> get menuRecents =>
      _menuRecents ??
      (_menuRecents = prefs.getStringList(SETTING_MENU_RECENT_KEY)) ??
      ["1", "2"];

  set menuRecents(List<String> value) {
    _menuRecents = value;
    prefs.setStringList(SETTING_MENU_RECENT_KEY, value);
  }

  bool _isShowAllMenuInHomePage;
  bool get isShowAllMenuInHomePage =>
      _isShowAllMenuInHomePage ??
      (_isShowAllMenuInHomePage =
          prefs.getBool(SETTING_IS_SHOW_ALL_MENU_IN_HOME_PAGE_KEY)) ??
      false;

  set isShowAllMenuInHomePage(bool value) {
    _isShowAllMenuInHomePage = value;
    prefs.setBool(SETTING_IS_SHOW_ALL_MENU_IN_HOME_PAGE_KEY, value);
  }

  bool _isShowGroupHeaderOnHome;
  bool get isShowGroupHeaderOnHome =>
      _isShowGroupHeaderOnHome ??
      (_isShowGroupHeaderOnHome =
          prefs.getBool(SETTING_IS_SHOW_GROUP_HOME_KEY)) ??
      false;

  set isShowGroupHeaderOnHome(bool value) {
    _isShowGroupHeaderOnHome = value;
    prefs.setBool(SETTING_IS_SHOW_GROUP_HOME_KEY, value);
  }

  String _shipPrinterName;
  String get shipPrinterName =>
      _shipPrinterName ??
      (_shipPrinterName = prefs.getString("shipPrinterName")) ??
      "Xem và in";

  set shipPrinterName(String value) {
    _shipPrinterName = value;
    prefs.setString("shipPrinterName", value);
  }

  String _shipNote;
  String get shipNote =>
      _shipNote ?? (_shipNote = prefs.getString(SETTING_SHIP_NOTE_KEY)) ?? "";

  set shipNote(String value) {
    _shipNote = value;
    prefs.setString(SETTING_SHIP_NOTE_KEY, value);
  }

  String _shipSize;
  String get shipSize =>
      _shipSize ??
      (_shipSize = prefs.getString(SETTING_SHIP_SIZE_KEY)) ??
      "BILL80-IMAGE";
  set shipSize(String value) {
    _shipSize = value;
    prefs.setString(SETTING_SHIP_SIZE_KEY, value);
  }

  bool get isShopTokenValid {
    if (this.shopUrl != null &&
        this.shopUrl != "" &&
        this.shopAccessToken != null &&
        this.shopAccessToken != "" &&
        this.shopAccessTokenExpire != null &&
        this.shopAccessTokenExpire.isAfter(
              DateTime.now(),
            )) {
      return true;
    } else {
      return false;
    }
  }

  bool _settingFastSaleOrderPrintShipAfterConfirm;
  bool get settingFastSaleOrderPrintShipAfterConfirm =>
      _settingFastSaleOrderPrintShipAfterConfirm ??
      (_settingFastSaleOrderPrintShipAfterConfirm = prefs
          .getBool(SETTING_FAST_SALE_ORDER_PRINT_SHIP_AFTER_CONFIRM_KEY)) ??
      false;

  set settingFastSaleOrderPrintShipAfterConfirm(bool value) {
    _settingFastSaleOrderPrintShipAfterConfirm = value;
    prefs.setBool(SETTING_FAST_SALE_ORDER_PRINT_SHIP_AFTER_CONFIRM_KEY, value);
  }

  List<PrintTemplate> getSuportPrintTemplateByPrinterType(
      String print, String printerType) {
    Map printProfile = supportPrinterProfiles[print];
    if (printProfile != null) {
      return (printProfile[printerType] as List)
          ?.map((f) => PrintTemplate.fromJson(f))
          ?.toList();
    } else {
      return null;
    }
  }

  String _fastSaleOrderInvoicePrinterName;
  String get fastSaleOrderInvoicePrinterName =>
      _fastSaleOrderInvoicePrinterName ??
      (_fastSaleOrderInvoicePrinterName =
          prefs.getString(SETTING_FAST_SALE_ORDER_PRINTER_NAME)) ??
      "Xem và in";
  set fastSaleOrderInvoicePrinterName(String value) {
    _fastSaleOrderInvoicePrinterName = value;
    prefs.setString(SETTING_FAST_SALE_ORDER_PRINTER_NAME, value);
  }

  String _fastSaleOrderInvoicePrintSize;
  String get fastSaleOrderInvoicePrintSize =>
      _fastSaleOrderInvoicePrintSize ??
      (_fastSaleOrderInvoicePrintSize =
          prefs.getString(SETTING_FAST_SALE_ORDER_PRINT_SIZE)) ??
      "BILL80-IMAGE";

  set fastSaleOrderInvoicePrintSize(String value) {
    _fastSaleOrderInvoicePrintSize = value;
    prefs.setString(SETTING_FAST_SALE_ORDER_PRINT_SIZE, value);
  }

  String facebookAccessToken;

  bool _settingPrintSaleOnlineNoSign;
  bool get settingPrintSaleOnlineNoSign =>
      _settingPrintSaleOnlineNoSign ??
      (_settingPrintSaleOnlineNoSign =
          prefs.getBool(SETTING_SALE_ONLINE_PRINT_NO_SIGN)) ??
      false;

  set settingPrintSaleOnlineNoSign(bool value) {
    _settingPrintSaleOnlineNoSign = value;
    prefs.setBool(SETTING_SALE_ONLINE_PRINT_NO_SIGN, value);
  }

  List<SupportPrintSaleOnlineRow> _settingSaleOnlinePrintContents;
  List<SupportPrintSaleOnlineRow> get settingSaleOnlinePrintContents {
    if (_settingSaleOnlinePrintContents == null) {
      String value = prefs.getString(SETTING_SALE_ONLINE_PRINT_CONTENT_KEY);
      if (value != null) {
        try {
          _settingSaleOnlinePrintContents = (jsonDecode(value) as List)
              .map((f) => SupportPrintSaleOnlineRow.fromJson(f))
              .toList();
        } catch (e, s) {
          print(s);
        }
      }
    }
    return _settingSaleOnlinePrintContents ?? _defaultSaleOnlinePrintRow;
  }

  set settingSaleOnlinePrintContents(List<SupportPrintSaleOnlineRow> value) {
    _settingSaleOnlinePrintContents = value;

    if (value != null && value.length > 0) {
      List<Map<String, dynamic>> jsonMap =
          value.map((f) => f.toJson()).toList();
      var json = jsonEncode(jsonMap);
      prefs.setString(SETTING_SALE_ONLINE_PRINT_CONTENT_KEY, json);
    }
  }

  int _settingSaleOnlineAutoSaveCommentMinute;
  int get settingSaleOnlineAutoSaveCommentMinute =>
      _settingSaleOnlineAutoSaveCommentMinute ??
      (_settingSaleOnlineAutoSaveCommentMinute =
          prefs.getInt(SETTING_SALE_ONLINE_SAVE_COMMENT_MINUTE_KEY)) ??
      5;

  set settingSaleOnlineAutoSaveCommentMinute(int value) {
    _settingSaleOnlineAutoSaveCommentMinute = value;
    prefs.setInt(SETTING_SALE_ONLINE_SAVE_COMMENT_MINUTE_KEY, value);
  }

  // Game
  bool _isShareGame;
  bool get isShareGame =>
      _isShareGame ??
      (_isShareGame = prefs.getBool(SETTING_IS_SHARE_GAME_KEY)) ??
      true;

  set isShareGame(bool value) {
    _isShareGame = value;
    prefs.setBool(SETTING_IS_SHARE_GAME_KEY, value);
  }

  bool _isCommentGame;
  bool get isCommentGame =>
      _isCommentGame ??
      (_isCommentGame = prefs.getBool(SETTING_IS_COMMENT_GAME_KEY)) ??
      true;

  set isCommentGame(bool value) {
    _isCommentGame = value;
    prefs.setBool(SETTING_IS_COMMENT_GAME_KEY, value);
  }

  /// Bao gồm người đã thắng trước đó
  bool _isOrderGame;
  bool get isOrderGame =>
      _isOrderGame ??
      (_isOrderGame = prefs.getBool(SETTING_IS_ORDER_GAME_KEY)) ??
      false;

  set isOrderGame(bool value) {
    _isOrderGame = value;
    prefs.setBool(SETTING_IS_ORDER_GAME_KEY, value);
  }

  /// Bao gồm cả người đã thắng
  bool _isWinGame;
  bool get isWinGame =>
      _isWinGame ??
      (_isWinGame = prefs.getBool(SETTING_IS_WIN_GAME_KEY)) ??
      true;

  set isWinGame(bool value) {
    _isWinGame = value;
    prefs.setBool(SETTING_IS_WIN_GAME_KEY, value);
  }

  bool _settingGameIsIgroneRecentWinner;
  bool get settingGameIsIgroneRecentWinner =>
      _settingGameIsIgroneRecentWinner ??
      (_settingGameIsIgroneRecentWinner =
          prefs.getBool("settingGameIsIgroneRecentWinner") ?? true);

  set settingGameIsIgroneRecentWinner(bool value) {
    _settingGameIsIgroneRecentWinner = value;
    prefs.setBool("settingGameIsIgroneRecentWinner", value);
  }

  int _days;
  int get days =>
      _days ?? (_days = prefs.getInt(SETTING_IS_DAYS_GAME_KEY)) ?? 14;

  set days(int value) {
    _days = value;
    prefs.setInt(SETTING_IS_DAYS_GAME_KEY, value);
  }

  String _isPriorGame;
  String get isPriorGame =>
      _isPriorGame ??
      (_isPriorGame = prefs.getString(SETTING_IS_PRIOR_GAME_KEY)) ??
      "share";

  set isPriorGame(String value) {
    _isPriorGame = value;
    prefs.setString(SETTING_IS_PRIOR_GAME_KEY, value);
  }

  bool _isSaleOnlineHideShortComment;
  bool get isSaleOnlineHideShortComment =>
      _isSaleOnlineHideShortComment ??
      (_isSaleOnlineHideShortComment =
          prefs.getBool(SETTING_SALE_ONLINE_HIDE_SHORT_COMMENT_KEY)) ??
      false;

  set isSaleOnlineHideShortComment(bool value) {
    _isSaleOnlineHideShortComment = value;
    prefs.setBool(SETTING_SALE_ONLINE_HIDE_SHORT_COMMENT_KEY, value);
  }

  bool _settingPrintShipShowDepositAmount;
  bool get settingPrintShipShowDepositAmount =>
      _settingPrintShipShowDepositAmount ??
      (_settingPrintShipShowDepositAmount =
          prefs.getBool(SETTING_PRINT_SHIP_SHOW_DEPOSIT_AMOUNT_KEY)) ??
      false;

  set settingPrintShipShowDepositAmount(bool value) {
    _settingPrintShipShowDepositAmount = value;
    prefs.setBool(SETTING_PRINT_SHIP_SHOW_DEPOSIT_AMOUNT_KEY, value);
  }

  bool _settingPrintShipShowProductQuantity;
  bool get settingPrintShipShowProductQuantity =>
      _settingPrintShipShowProductQuantity ??
      (_settingPrintShipShowProductQuantity =
          prefs.getBool(SETTING_PRINT_SHIP_SHOW_PRODUCT_QUANTITY_KEY)) ??
      false;

  set settingPrintShipShowProductQuantity(bool value) {
    _settingPrintShipShowProductQuantity = value;
    prefs.setBool(SETTING_PRINT_SHIP_SHOW_PRODUCT_QUANTITY_KEY, value);
  }

  bool _saleOnlineFetchDurationEnableOnLive;
  bool get saleOnlineFetchDurationEnableOnLive =>
      _saleOnlineFetchDurationEnableOnLive ??
      (_saleOnlineFetchDurationEnableOnLive =
          prefs.getBool("saleOnlineFetchDurationEnableOnLive")) ??
      true;

  set saleOnlineFetchDurationEnableOnLive(bool value) {
    _saleOnlineFetchDurationEnableOnLive = value;
    prefs.setBool("saleOnlineFetchDurationEnableOnLive", value);
  }

  // 0 is auto
  int _saleOnlineFetchDurationOnliveSecond;
  int get saleOnlineFetchDurationOnliveSecond =>
      _saleOnlineFetchDurationOnliveSecond ??
      (_saleOnlineFetchDurationOnliveSecond =
          prefs.getInt("saleOnlineFetchDurationOnliveSecond")) ??
      0;

  String _saleOnlineSize;
  String get saleOnlineSize =>
      _saleOnlineSize ??
      (_saleOnlineSize = prefs.getString("saleOnlineSize")) ??
      "BILL80-RAW";

  set saleOnlineSize(String value) {
    _saleOnlineSize = value;
    prefs.setString("saleOnlineSize", value);
  }

  String _saleOnlineOrderListFilterDate;

  String get saleOnlineOrderListFilterDate =>
      _saleOnlineOrderListFilterDate ??
      (_saleOnlineOrderListFilterDate =
          prefs.get("saleOnlineOrderListFilterDate")) ??
      "Hôm nay";

  set saleOnlineOrderListFilterDate(String value) {
    _saleOnlineOrderListFilterDate = value;
    prefs.setString("saleOnlineOrderListFilterDate", value);
  }
}

class MockSettingService implements ISettingService {
  @override
  SettingAddExistsProductWarning addExistsProductWarning =
      SettingAddExistsProductWarning.ADD_QUANTITY;

  @override
  String computerIp = "192.168.1.1";

  @override
  String computerPort;

  @override
  bool isAllowPrintSaleOnlineManyTime;

  @override
  bool isEnablePrintSaleOnline;

  @override
  bool isProductSearchViewList;

  @override
  bool isSaleOnlineAutoLoadAllCommentOnLive;

  @override
  bool isSaleOnlineAutoLoadAllCommentOnPost;

  @override
  bool isSaleOnlineEnableConnectFailAction;

  @override
  bool isSaleOnlinePrintAddress;

  @override
  bool isSaleOnlinePrintAllOrderNote;

  @override
  bool isSaleOnlinePrintComment;

  @override
  bool isSaleOnlinePrintCustomHeader;

  @override
  bool isSaleOnlinePrintPartnerNote;

  @override
  bool isSaleOnlineViewTimeAgoOnLiveComment;

  @override
  bool isSaleOnlineViewTimeAgoOnPostComment;

  @override
  String lanPrinterIp;

  @override
  String lanPrinterPort;

  @override
  String locate;

  @override
  PrintSaleOnlineMethod printMethod;

  @override
  int productSearchOrderByIndex;

  @override
  SaleOnlineCommentOrderBy saleOnlineCommentDefaultOrderByOnLive;

  @override
  SaleOnlineCommentOrderBy saleOnlineCommentDefaultOrderByOnPost;

  @override
  CommentRate saleOnlineFetchCommentOnRealtimeRate;

  @override
  int saleOnlineOrderListFilterByStatusIndex;

  @override
  int saleOnlineOrderListFilterByTimeIndex;

  @override
  String saleOnlinePrintCustomHeaderContent;

  @override
  int secondRefreshComment;

  @override
  String shopAccessToken;

  @override
  DateTime shopAccessTokenExpire;

  @override
  String shopRefreshAccessToken;

  @override
  String shopUrl;

  @override
  String shopUsername;

  @override
  Future initService() {
    return null;
  }

  @override
  bool isHideDeliveryAddressInFastSaleOrder;

  @override
  bool isHideDeliveryCarrierInFastSaleOrder;

  @override
  bool isNextPaymentForCompleteInvoiceInFastSaleOrder;

  @override
  bool isAutoInputPaymentAmountInFastSaleOrder;

  @override
  bool isShowInfoInvoiceAfterSaveFastSaleOrder;

  @override
  bool isHideHomePageSuggess;

  @override
  String lastAppVersion;

  @override
  bool isAppUpdated;

  @override
  List<PrinterDevice> printers;

  @override
  List<String> homeMenus;

  @override
  List<String> menuRecents;

  @override
  bool isShowAllMenuInHomePage;

  @override
  bool isShowGroupHeaderOnHome;

  @override
  String shipPrinterName;

  @override
  String shipNote;

  @override
  String shipSize;

  @override
  bool isShowInfoInvoiceAfterSaveSaleOrder;

  @override
  // TODO: implement isShopTokenValid
  bool get isShopTokenValid => null;

  @override
  bool settingFastSaleOrderPrintShipAfterConfirm;

  @override
  List<PrintTemplate> getSuportPrintTemplateByPrinterType(
      String print, String printerType) {
    // TODO: implement getSuportPrintTemplateByPrinterType
    return null;
  }

  @override
  String fastSaleOrderInvoicePrinterName;

  @override
  String fastSaleOrderInvoicePrintSize;

  @override
  String facebookAccessToken;

  @override
  bool settingPrintSaleOnlineNoSign;

  @override
  // TODO: implement supportSaleOnlinePrintRow
  List<SupportPrintSaleOnlineRow> get supportSaleOnlinePrintRow => null;

  @override
  List<SupportPrintSaleOnlineRow> settingSaleOnlinePrintContents;

  @override
  // TODO: implement defaultSaleOnlinePrintRow
  List<SupportPrintSaleOnlineRow> get defaultSaleOnlinePrintRow => null;

  @override
  int settingSaleOnlineAutoSaveCommentMinute;

  @override
  bool isShareGame;

  @override
  bool isCommentGame;

  @override
  String isPriorGame;

  @override
  bool isWinGame;

  @override
  bool isSaleOnlineHideShortComment;

  @override
  bool isOrderGame;

  @override
  int days;

  @override
  bool settingPrintShipShowDepositAmount;

  @override
  bool settingPrintShipShowProductQuantity;

  @override
  bool settingGameIsIgroneRecentWinner;

  @override
  int _saleOnlineFetchDurationOnliveSecond;

  @override
  bool saleOnlineFetchDurationEnableOnLive;

  @override
  String saleOnlineSize;

  @override
  String _saleOnlineOrderListFilterDate;

  @override
  String saleOnlineOrderListFilterDate;
}

class PrintTemplate {
  String code;
  String name;

  PrintTemplate({this.code, this.name});
  PrintTemplate.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    name = json["name"];
  }
}

class SupportPrintSaleOnlineRow {
  String name;
  String description;
  bool isPrint;
  bool bold;
  bool itanic;
  int fontSize;
  SupportPrintSaleOnlineRow(
      {this.name,
      this.description,
      this.isPrint = true,
      this.bold = false,
      this.itanic = false,
      this.fontSize = 1});

  SupportPrintSaleOnlineRow.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    description = json["description"];
    bold = json["bold"] ?? false;
    itanic = json[itanic] ?? false;
    fontSize = json["fontSize"] ?? 1;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["bold"] = this.bold;
    data["itanic"] = this.itanic;
    data["fontSize"] = this.fontSize;
    data["description"] = this.description;

    return data;
  }
}
