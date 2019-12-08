/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:56 AM
 *
 */

import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/category/company_add_edit_page.dart';
import 'package:tpos_mobile/category/delivery_carrier_partner_add_list_page.dart';
import 'package:tpos_mobile/fast_purchase_order/ui/fast_purchase_order_list.dart';
import 'package:tpos_mobile/pos_order/ui/pos_order_gio_hang_list_page.dart';
import 'package:tpos_mobile/pos_order/ui/pos_order_list_page.dart';
import 'package:tpos_mobile/pos_order/ui/pos_point_sale_list_page.dart';
import 'package:tpos_mobile/reports/stock_report_page.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/about_page.dart';
import 'package:tpos_mobile/sale_online/ui/check_address_page.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_add_edit_full_page.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_delivery_invoice_list_page.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_info_page.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/game_lucky_wheel_page.dart';
import 'package:tpos_mobile/sale_online/ui/home_navigation_page.dart';
import 'package:tpos_mobile/sale_online/ui/home_page.dart';
import 'package:tpos_mobile/sale_online/ui/new_login_page.dart';
import 'package:tpos_mobile/sale_online/ui/not_found_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_category_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_search_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_category_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_template_search_page.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_change_password.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_user_activities.dart';
import 'package:tpos_mobile/sale_online/ui/sale_facebook_create_order_setting_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_channel_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_facebook_channel_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_live_campaign_management_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_list_page.dart';
import 'package:tpos_mobile/settings/setting_company_printer.dart';
import 'package:tpos_mobile/settings/setting_fast_sale_order_add_edit_full_page.dart';
import 'package:tpos_mobile/settings/setting_home_page.dart';
import 'package:tpos_mobile/settings/setting_page.dart';
import 'package:tpos_mobile/settings/setting_printer.dart';
import 'package:tpos_mobile/settings/setting_printer_edit_printer_fast_sale_order_option_page.dart';
import 'package:tpos_mobile/settings/setting_printer_edit_printer_ship_option_page.dart';
import 'package:tpos_mobile/settings/setting_printer_list.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_setting_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_order/sale_order_add_edit_page.dart';
import 'package:tpos_mobile/sale_order/sale_order_info_page.dart';
import 'package:tpos_mobile/sale_order/sale_order_list_page.dart';
import 'package:tpos_mobile/services/navigation_service.dart';
import 'package:tpos_mobile/system/register_page.dart';
import 'package:tpos_mobile/themes.dart';
import 'package:tpos_mobile/widgets/dialog_provider.dart';

import 'app.dart';
import 'category/mail_template/mail_template_list_page.dart';
import 'settings/setting_sale_online_print_ship_via_lan_printer.dart';

class MainApp extends StatefulWidget {
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: App.analytics);
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ISettingService _settingService = locator<ISettingService>();
  IAppService _app = locator<IAppService>();
  ApplicationSettingViewModel applicationViewModel =
      new ApplicationSettingViewModel();

  @override
  void initState() {
    App.analytics.setUserId(
        _settingService.shopUrl?.replaceAll("https://", "") ?? "N/A");

    App.analytics.logAppOpen();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<IAppService>(
      model: locator<IAppService>(),
      child: MaterialApp(
        title: 'TPos Mobile',
        theme: defaultAppTheme.themeData,
        debugShowCheckedModeBanner: false,
        home: _showHomePage(),
        routes: {
          AppRoute.home: (context) => HomePage(),
          AppRoute.sale_online_order_list: (context) =>
              SaleOnlineOrderListPage(),
          NotFoundPage.routeName: (context) => NotFoundPage(),
          AppRoute.sale_online_channel_list: (context) =>
              SaleOnlineChannelListPage(),
          "/app/partner/customer/search": (context) => PartnerSearchPage(
                isSearchMode: false,
              ),
          "/app/partner/add": (context) => PartnerAddEditPage(),
          AppRoute.sale_online_live_campaign_list: (context) =>
              SaleOnlineLiveCampaignManagementPage(),
          AppRoute.product_search: (context) => ProductListPage(
                closeWhenDone: false,
                isSearchMode: false,
              ),
          AppRoute.product_template_search: (context) =>
              ProductTemplateSearchPage(
                closeWhenDone: false,
                isSearchMode: false,
              ),
          AppRoute.product_category_search: (context) => ProductCategoryPage(
                closeWhenDone: false,
                isSearchMode: false,
              ),
          AppRoute.partner_category_list: (context) =>
              PartnerCategoryPage(isSearchMode: false),
          AppRoute.fast_sale_order_list: (context) => FastSaleOrderListPage(),
          AppRoute.fast_sale_order_delivery_list: (context) =>
              FastSaleDeliveryInvoicePage(),
          AppRoute.setting: (context) => SettingPage(),
          AppRoute.setting_sale_online: (context) =>
              SaleFacebookCreateOrderSettingPage(),
          AppRoute.setting_printer_list: (context) => SettingPrinterListPage(),
          AppRoute.game_lucky_wheel: (context) => GameLuckyWheelPage(),
          AppRoute.setting_home_page: (context) => SettingHomePage(),
          AppRoute.about: (context) => AboutPage(),
          AppRoute.setting_printer: (context) => SettingPrinterPage(),
          AppRoute.setting_printer_edit_option: (context) =>
              SettingPrinterEditPrinterShipOptionPage(),
          AppRoute.setting_company_printer: (context) =>
              SettingCompanyPrinterPage(),
          AppRoute.setting_printer_fast_sale_order_option: (context) =>
              SettingPrinterEditPrinterFastSaleOrderOptionPage(),
          AppRoute.sale_online_facebook_channel_list: (context) =>
              SaleOnlineFacebookChannelListPage(),
          AppRoute.sale_order_list: (context) => SaleOrderListPage(),
          AppRoute.setting_sale_online_print_via_lan: (context) =>
              SettingSaleOnlinePrintShipViaLanPrinter(),
          AppRoute.fast_purchase_order: (context) =>
              FastPurchaseOrderListPage(),
          AppRoute.refund_fast_purchase_order: (context) =>
              FastPurchaseOrderListPage(isRefund: true),
          AppRoute.home_personal_user_history: (context) =>
              UserActivitiesPage(),
          AppRoute.home_personal_change_pass: (context) =>
              ChangePassWordDialog(null),
          AppRoute.register_page: (context) => RegisterPage(),
          AppRoute.report_inventory: (context) => StockReportPage(),
          AppRoute.delivery_carier_parnter_list: (context) =>
              DeliveryCarrierAddListPage(),
          AppRoute.pos_order_list: (context) => PosOrderListPage(),
          AppRoute.mail_template_list: (context) => MailTemplateListPage(),
          AppRoute.pos_order: (context) => PosPointSaleListPage(),
        },
        onUnknownRoute: (setting) {
          return new MaterialPageRoute(builder: (context) => NotFoundPage());
        },
        onGenerateRoute: _generateRoute,
        navigatorObservers: <NavigatorObserver>[MainApp.observer],
        builder: (context, widget) => Navigator(
          onGenerateRoute: (routeSetting) => MaterialPageRoute(
            builder: (context) => DialogProvider(
              child: widget,
            ),
          ),
        ),
        navigatorKey: locator<NavigationService>().navigatorKey,
      ),
    );
  }

  MaterialPageRoute _generateRoute(RouteSettings setting) {
    print("route");
    switch (setting.name) {
      case AppRoute.sale_order_info:
        var param = setting.arguments;
        return MaterialPageRoute(
          builder: (context) => SaleOrderInfoPage(param),
        );
        break;
      case AppRoute.setting_fast_sale_order:
        return MaterialPageRoute(
            builder: (context) => SettingFastSaleOrderAddEditFullPage());
        break;
      case AppRoute.fast_sale_order_info:
        var param = setting.arguments;
        return MaterialPageRoute(
          builder: (context) => FastSaleOrderInfoPage(
            order: param,
          ),
        );
        break;

      case AppRoute.fast_sale_order_add_edit_full:
        Map param = setting.arguments;
        return MaterialPageRoute(
          builder: (context) => FastSaleOrderAddEditFullPage(
            editOrder: param != null ? param["editOrder"] : null,
            saleOnlineIds: param != null ? param["saleOnlineIds"] : null,
            partnerId: param != null ? param["partnerId"] : null,
            onEditCompleted: param != null ? param["onEditCompleted"] : null,
          ),
        );
        break;

      case AppRoute.check_address:
        Map param = setting.arguments;
        return MaterialPageRoute(
            builder: (context) => CheckAddressPage(
                  keyword: param != null ? param["keyword"] : null,
                  selectedAddress:
                      param != null ? param["selectedAddress"] : null,
                ));
        break;

      case AppRoute.home_navigation_page:
        Map param = setting.arguments;
        return MaterialPageRoute(builder: (context) => HomeNavigationPage());
        break;
      case AppRoute.report_dashboard:
        Map param = setting.arguments;
        return MaterialPageRoute(builder: (context) => ReportDashboardPage());
        break;

      case AppRoute.sale_order_add_edit:
        Map param = setting.arguments;

        return MaterialPageRoute(
          builder: (context) => SaleOrderAddEditPage(
            editOrder: param != null ? param["editOrder"] : null,
            saleOnlineIds: param != null ? param["saleOnlineIds"] : null,
            partnerId: param != null ? param["partnerId"] : null,
            onEditCompleted: param != null ? param["onEditCompleted"] : null,
            isCopy: param != null ? param["isCopy"] : true,
          ),
        );
        break;

      case AppRoute.supplier_search:
        var params = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => PartnerSearchPage(
            isCustomer: false,
            isSupplier: true,
            closeWhenDone: true,
            isSearchMode: false,
          ),
        );
      case AppRoute.partner_search:
        var params = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => PartnerSearchPage(
            isCustomer: true,
            isSupplier: false,
            isSearchMode: false,
          ),
        );
      case AppRoute.company_add:
        return MaterialPageRoute(
          builder: (context) => CompanyAddEditPage(),
        );

      case AppRoute.company_edit:
        var params = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => CompanyAddEditPage(
            company: params != null ? params[0] : null,
          ),
        );
      case AppRoute.pos_order:
        var params = setting.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (context) => PosPointSaleListPage(),
        );
      default:
        return null;
        break;
    }
  }

  @override
  void dispose() {
    applicationViewModel.dispose();
    super.dispose();
  }

  Widget _showHomePage() {
    // return TestPrintPosImage();
    if (_settingService.isShopTokenValid) {
      //Goto home page
      return new HomeNavigationPage();
    } else {
      // Goto login page
      return new NewLoginPage();
    }
  }
}

class PermissionRoute {
  final String appRoute;
  final String permission;
  PermissionRoute({this.appRoute, this.permission});
}

class AppRoute {
  static PermissionRoute saleOnlineOrderList = PermissionRoute(
      appRoute: sale_online_channel_list, permission: "sale_online");

  static const home = "/app/menu";
  static const about = "app/about";
  static const home_navigation_page = "/home_navigation";
  static const not_found = "app/notfound";
  static const sale_online_order_list = "app.saleOnline.order.list";
  static const sale_online_live_campaign_list =
      "app.saleOnline.liveCampaign.list";
  static const sale_online_facebook_post = "app.saleOnline.facebook";
  static const sale_online_facebook_account_select =
      "app.saleOnline.facebook.post";
  static const sale_online_facebook_channel_list = "app.saleOnline.facebook";
  static const sale_online_facebook_comments =
      "app.saleOnline.facebook.post.details";

  static const partner_search = "app.partner.customer";
  static const partner_category_list = "app.partnercategory.list";

  static const supplier_search = "app.partner.supplier";
  static const product_search = "app.product.list";
  static const product_template_search = "app.producttemplate.list";
  static const product_category_search = "app.productcategory.list";

  static const fast_sale_order_list = "app.fastsaleorder.invoicelist";
  static const fast_sale_order_delivery_list =
      "app.fastsaleorder.deliveryinvoice";
  static const fast_sale_order_add_edit = "/app/fastSaleOrder/addedit";
  static const fast_sale_order_add_edit_ship_receiver =
      "/app/fastSaleOrder/addEditShipReceiver";
  static const fast_sale_order_add_edit_full = "app.fastsaleorder.invoiceform1";
  static const fast_sale_order_info = "/app/fastSaleOrder/info";

  static const sale_order_info = "app.saleorder.info";
  static const sale_order_list = "app.saleorder.list";
  static const sale_order_add_edit = "app.saleorder.form";
  static const game_lucky_wheel = "/app/gameLuckyWheel";
  static const setting = "/app/setting";
  static const setting_sale_online = "app.saleonline/setting";
  static const setting_fast_sale_order = "app.fastsaleorder/setting";
  static const setting_printer_list = "/app/setting/printerlist";
  static const setting_company_printer = "/app/setting/companyPrinter";
  static const setting_home_page = "/app/setting/home";
  static const setting_printer = "/app/setting/printer";
  static const setting_printer_edit_option = "/app/setting/printer/editpotion";
  static const setting_printer_fast_sale_order_option =
      "/app/setting/printer/fastsaleorder";
  static const setting_sale_online_print_via_lan =
      "/app/setting/printer/printvialan";
  static const check_address = "app/api/check_address";
  static const report_dashboard = "/app/report/dashboard";
  static const home_personal = "/home/personal";
  static const fast_purchase_order = "app.fastpurchaseorder.invoicelist";
  static const refund_fast_purchase_order = "app.fastpurchaseorder.refundlist";
  static const home_personal_change_pass = "/home/changePassword";
  static const home_personal_user_history = "/home/userHistory";
  static const register_page = "/register";
  static const sale_online_channel_list = "app.historyds.list";
  static const report_inventory = "app.report.inventory";

  static const delivery_carier_parnter_list = "delivery_carier_partner_list";
  static const pos_order_list = "/post_order_list";
  static const mail_template_list = "/mail_template_list";
  static const company_add = "/company_add";
  static const company_edit = "/company_edit";
  static const pos_order = "/pos_order";
}

const PERMISSION_SALE_FAST_ORDER_FACEBOOK_SENDMESSSAGE =
    "App.Sale.Fast.Order.Facebook_SendMessage";
const PERMISSION_SALE_FAST_ORDER_READ = "App.Sale.Fast.Order.Read";
const PERMISSION_SALE_FAST_ORDER_INSERT = "App.Sale.Fast.Order.Insert";
const PERMISSION_SALE_FAST_ORDER_UPDATE = "App.Sale.Fast.Order.Update";
const PERMISSION_SALE_FAST_ORDER_CANCEL = "App.Sale.Fast.Order.Cancel";
const PERMISSION_SALE_FAST_ORDER_SENDELIVERY =
    "App.Sale.Fast.Order.SendDelivery";
const PERMISSION_SALE_FAST_ORDER_EXPORT_EXCEL =
    "App.Sale.Fast.DeliveryOrder.ExportExcel";

const PERMISSION_PURCHASE_FAST_ORDER_READ = "App.Purchase.Fast.Order.Read";
const PERMISSION_PURCHASE_FAST_ORDER_DELETE = "App.Purchase.Fast.Order.Delete";
const PERMISSION_PURCHASE_FAST_ORDER_INSERT = "App.Purchase.Fast.Order.Insert";
const PERMISSION_PURCHASE_FAST_ORDER_UPDATE = "App.Purchase.Fast.Order.Update";
// Hóa đơn giao hàng
const PERMISSION_SALE_DELIVERY_ORDER_READ = "App.Sale.Fast.DeliveryOrder.Read";
const PERMISSION_SALE_DELIVERY_ORDER_RESEND =
    "App.Sale.Fast.DeliveryOrder.Resend";
const PERMISSION_SALE_DELIVERY_ORDER_EXPORT_EXCEL =
    "App.Sale.Fast.DeliveryOrder.ExportExcel";
const PERMISSION_SALE_DELIVERY_ORDER_EXPORT_UPDATE_STATUS =
    "App.Sale.Fast.DeliveryOrder.UpdateStatus";
// Mua hàng
const PERMISSION_PURCHASE_FAST_REFUND_READ = "App.Purchase.Fast.Refund.Read";
const PERMISSION_PURCHASE_FAST_REFUND_DELETE =
    "App.Purchase.Fast.Refund.Delete";
const PERMISSION_PURCHASE_FAST_REFUND_INSERT =
    "App.Purchase.Fast.Refund.Insert";
const PERMISSION_PURCHASE_FAST_REFUND_UPDATE =
    "App.Purchase.Fast.Refund.Update";
const PERMISSION_PURCHASE_FAST_REFUND_CANCEL =
    "App.Sale.Fast.DeliveryOrder.Cancel";
// Chiến dịch live
const PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_UPDATE =
    "App.SaleOnline.LiveCampaign.Update";
const PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_READ =
    "App.SaleOnline.LiveCampaign.Read";
const PERMISSION_SALE_ONLINE_FACEBOOK_FEED = "App.SaleOnline.Facebook.Feed";
const PERMISSION_SALE_ONLINE_LIVE_CAMPAIGN_INSERT =
    "App.SaleOnline.LiveCampaign.Insert";
const PERMISSION_SALE_ONLINE_FACEBOOK_ENABLE_SESSION =
    "App.SaleOnline.Facebook.EnableSession";
const PERMISSION_SALE_ONLINE_FACEBOOK_REFRESH_SESSION =
    "App.SaleOnline.Facebook.RefreshSession";

const PERMISSION_SALE_ONLINE_ORDER_READ = "App.SaleOnline.Order.Read";
const PERMISSION_SALE_ONLINE_ORDER_INSERT = "App.SaleOnline.Order.Insert";
const PERMISSION_SALE_ONLINE_ORDER_CREATEFSO = "App.SaleOnline.Order.CreateFSO";
const PERMISSION_SALE_ONLINE_ORDER_UPDATE = "App.SaleOnline.Order.Update";
const PERMISSION_SALE_ONLINE_ORDER_DELETE = "App.SaleOnline.Order.Delete";
const PERMISSION_SALE_ONLINE_ORDER_EXCEL = "App.SaleOnline.Order.Excel";

// Product template
const PERMISSION_CATALOG_PRODUCT_TEMPLATE_INSERT =
    "App.Catalog.ProductTemplate.Insert";
const PERMISSION_CATALOG_PRODUCT_TEMPLATE_DELETE =
    "App.Catalog.ProductTemplate.Delete";
const PERMISSION_CATALOG_PRODUCT_TEMPLATE_READ =
    "App.Catalog.ProductTemplate.Read";
const PERMISSION_CATALOG_PRODUCT_TEMPLATE_CHANGE_QUANTITY =
    "App.Catalog.ProductTemplate.ChangeQty";
const PERMISSION_CATALOG_PRODUCT_TEMPLATE_UPDATE =
    "App.Catalog.ProductTemplate.Update";
// Product
const PERMISSION_CATALOG_PRODUCT_INSERT = "App.Catalog.Product.Insert";
const PERMISSION_CATALOG_PRODUCT_DELETE = "App.Catalog.Product.Delete";
const PERMISSION_CATALOG_PRODUCT_READ = "App.Catalog.Product.Read";
const PERMISSION_CATALOG_PRODUCT_UPDATE = "App.Catalog.Product.Update";
// Partner
const PERMISSION_CATALOG_PARTNER_CUSTOMER_INSERT =
    "App.Catalog.Partner.Customer.Insert";
const PERMISSION_CATALOG_PARTNER_CUSTOMER_READ = "App.Catalog.Product.Read";
const PERMISSION_CATALOG_PARTNER_CUSTOMER_DELETE = "App.Catalog.Product.Delete";
const PERMISSION_CATALOG_PARTNER_CUSTOMER_TRANSFER =
    "App.Catalog.Partner.Customer.Transfer";
const PERMISSION_CATALOG_PARTNER_CUSTOMER_UPDATE =
    "App.Catalog.Partner.Customer.Update";

// Supplier

const PERMISSION_CATALOG_PARTNER_SUPPLIER_READ =
    "App.Catalog.Partner.Supplier.Read";
const PERMISSION_CATALOG_PARTNER_SUPPLIER_UPDATE =
    "App.Catalog.Partner.Supplier.Update";
const PERMISSION_CATALOG_PARTNER_SUPPLIER_DELETE =
    "App.Catalog.Partner.Supplier.Delete";
//Đơn đặt hàng
const PERMISSION_SALE_ORDER_READ = "App.Sale.Order.Read";
const PERMISSION_SALE_ORDER_INSERT = "App.Sale.Order.Insert";
const PERMISSION_SALE_ORDER_UPDATE = "App.Sale.Order.Update";
const PERMISSION_SALE_ORDER_DELETE = "App.Sale.Order.Delete";
