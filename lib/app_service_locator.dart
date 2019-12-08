/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:tpos_mobile/fast_purchase_order/view_model/fast_purchase_order_addedit_viewmodel.dart';
import 'package:tpos_mobile/fast_purchase_order/view_model/fast_purchase_order_viewmodel.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/ui/pos_payment_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_cart_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_money_cart_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_gio_hang_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_info_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_partner_add_edit_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_partner_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_payment_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_point_sale_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_price_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_product_list_viewmodel.dart';
import 'package:tpos_mobile/sale_online/ui/notification_list_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/notification_list_viewmodel.dart';
import 'package:tpos_mobile/services/data_services/data_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/sale_online/services/remote_config_service.dart';
import 'package:tpos_mobile/sale_online/services/report_service.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/product_search.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_setting_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/delivery_carrier_search_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_ship_info_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_line_edit_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_payment_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/home_personal_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/new_login_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/report_dashboard_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_channel_list_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_facebook_post_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_order_edit_products_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/setting_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/HomeViewModel.dart';
import 'package:tpos_mobile/helpers/tmt_flutter_locator.dart';
import 'package:tpos_mobile/services/log_services/log_server_service.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/services/mock_services/notification_api_mock.dart';
import 'package:tpos_mobile/services/multi_instance_service.dart';
import 'package:tpos_mobile/services/navigation_service.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/company_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/notification_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/partner_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/sale_setting_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_all.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_client.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

import 'category/mail_template/mail_template_add_edit_viewmodel.dart';
import 'category/mail_template/mail_template_list_viewmodel.dart';
import 'pos_order/services/pos_tpos_api.dart';
import 'sale_online/viewmodels/sale_online_order_line_edit_viewmodel.dart';
import 'package:tpos_mobile/category/viewmodel/product_search_viewmodel.dart'
    as newProductSearch;

TmtFlutterLocator locator = TmtFlutterLocator.instance;
TmtFlutterLocator saleOnlineViewModelLocator = TmtFlutterLocator.instance;

Future<void> setupLocator() async {
  Logger _log = new Logger("setupLocator");
  locator.allowReassignment = true;
  _log.info("set up Locator");

  /* set up Locator*/
  /// Register app setting service
  locator.registerLazySingleton<ISettingService>(() => new AppSettingService());
  locator.registerLazySingleton<LogServerService>(() => CrashlyticLogService());
  locator.registerLazySingleton<LogService>(() => LoggerLogService());
  locator.registerLazySingleton<DialogService>(() => MainDialogService());
  locator.registerLazySingleton<MultiInstanceService>(
      () => MultiInstanceService());

  locator.registerLazySingleton<NavigationService>(() => NavigationService());

  /// Register App crash report service
  locator.registerLazySingleton<IReportService>(() => new ReportService());

  /// Register TPOS API Client Base
  locator.registerLazySingleton<TposApiClient>(() => new TposApiClient());

  /// Register tpos api client service
  locator.registerLazySingleton<ITposApiService>(() => new TposApiService());

  /* TPOS API SERVICE*/

  locator.registerLazySingleton<TposApi>(() => TposApi());
  locator.registerFactory<ICompanyService>(() => CompanyService());
  locator.registerFactory<IFastSaleOrderApi>(() => FastSaleOrderApi());
  locator.registerFactory<ISaleSettingApi>(() => SaleSettingApi());
  locator.registerFactory<IPartnerApi>(() => PartnerApi());
  locator.registerFactory<INotificationApi>(() => NotificationApi());
  locator.registerFactory<IPosTposApi>(() => PosTposApi());
  locator.registerFactory<IDatabaseFunction>(() => DatabaseFunction());

  //locator.registerFactory<INotificationApi>(() => NotificationApiMock());

  /* TPOS API SERVICE*/
  locator.registerLazySingleton<IFacebookApiService>(
      () => new FacebookApiService());
  locator.registerLazySingleton<ITPosDesktopService>(
      () => new TPosDesktopService());

  /// Register global app service
  /// This save global app state
  locator.registerLazySingleton<IAppService>(() => new AppViewModel());

  /// Register global remote config setting service
  locator.registerLazySingleton<RemoteConfigService>(
      () => new RemoteConfigService());

  ///  Register print service locator
  locator.registerLazySingleton<PrintService>(() => PosPrintService());

  // Lưu cấu hình tạm
  locator.registerLazySingleton<ApplicationSettingViewModel>(() {
    return new ApplicationSettingViewModel();
  });

  /// Data service
  locator.registerLazySingleton<DataService>(() => DataService());
  //register home page
  locator.registerFactory<NewLoginViewModel>(() => new NewLoginViewModel());
  locator.registerLazySingleton<HomeViewModel>(() => new HomeViewModel());
  locator.registerLazySingleton<HomePersonalViewModel>(
      () => HomePersonalViewModel());
  locator.registerLazySingleton<ReportDashboardViewModel>(
      () => ReportDashboardViewModel());
  locator.registerLazySingleton<NotificationListViewModel>(
      () => NotificationListViewModel());

  /// Tìm sản phẩm luôn luôn hoạt động
  locator.registerLazySingleton<ProductSearchViewModel>(
      () => ProductSearchViewModel());

  locator.registerLazySingleton<newProductSearch.ProductSearchViewModel>(
      () => newProductSearch.ProductSearchViewModel());
  //Register homep age

  locator.registerFactory<SaleOnlineFacebookPostViewModel>(
      () => new SaleOnlineFacebookPostViewModel());

  // Viewmodel chức năng
  locator.registerFactory(() => new FastSaleOrderAddEditViewModel());
  locator.registerFactory(() => new FastSaleOrderLineEditViewModel());
  locator.registerFactory(() => new SaleOnlineOrderEditProductsViewModel());
  locator.registerFactory(() => new SaleOnlineOrderLineEditViewModel());
  locator.registerFactory(() => new DeliveryCarrierSearchViewModel());
  locator.registerFactory(() => new SaleOnlineChannelListViewModel());
  locator.registerFactory(() => new FastSaleOrderPaymentViewModel());
  locator
      .registerFactory(() => new FastSaleOrderAddEditFullShipInfoViewModel());
  locator.registerFactory(() => new PosOrderListViewModel());
  locator.registerFactory(() => new PosOrderInfoViewModel());
  locator.registerFactory(() => new MailTemplateListViewModel());
  locator.registerFactory(() => new MailTemplateAddEditViewModel());

  /// Tạo/ Sửa hóa đơn bán hàng nhanh
  locator.registerFactory(() => new FastSaleOrderAddEditFullViewModel());
  // Cài đặt
  locator.registerFactory(() => new SettingViewModel());

  ///viewmodel phiếu bán hàng FastPurchaseViewmodel
  locator.registerFactory<FastPurchaseOrderViewModel>(
    () => FastPurchaseOrderViewModel(),
  );

  ///viewmodel thêm sửa phiếu bán hàng FastPurchaseOrderAddEditViewModel
  locator.registerFactory<FastPurchaseOrderAddEditViewModel>(
    () => FastPurchaseOrderAddEditViewModel(),
  );

  // Xử lý điểm bán hàng
  locator.registerFactory<PosOrderGioHangListViewModel>(
    () => PosOrderGioHangListViewModel(),
  );
  locator.registerFactory<PosPointSaleListViewModel>(
    () => PosPointSaleListViewModel(),
  );
  locator.registerFactory<PosCartViewModel>(
    () => PosCartViewModel(),
  );
  locator.registerFactory<PosProductListViewmodel>(
    () => PosProductListViewmodel(),
  );
  locator.registerFactory<PosMoneyCartViewModel>(() => PosMoneyCartViewModel());
  locator.registerFactory<PosPartnerListViewModel>(
      () => PosPartnerListViewModel());
  locator.registerFactory<PosPartnerAddEditViewModel>(
      () => PosPartnerAddEditViewModel());
  locator.registerFactory<PosPriceListViewModel>(() => PosPriceListViewModel());
  locator.registerFactory<PosPaymentViewModel>(() => PosPaymentViewModel());
  return;
}

void _registerApiService() {}

void clearLocator() {
  locator.reset();
}

String _appVersion;

Future<void> logoutLocator() async {
  /// Register tpos api client service
  locator.registerLazySingleton<ITposApiService>(() => new TposApiService());

  /// Register facebook api client service
  locator.registerLazySingleton<IFacebookApiService>(
      () => new FacebookApiService());

  /// Register windows app client service
  locator.registerLazySingleton<ITPosDesktopService>(
      () => new TPosDesktopService());

  // Lưu cấu hình tạm
  locator.registerLazySingleton<ApplicationSettingViewModel>(() {
    return new ApplicationSettingViewModel();
  });

  locator.registerLazySingleton<HomeViewModel>(() => new HomeViewModel());
  locator.registerLazySingleton<HomePersonalViewModel>(
      () => HomePersonalViewModel());
  locator.registerLazySingleton<ReportDashboardViewModel>(
      () => ReportDashboardViewModel());
  locator.registerLazySingleton<NotificationListViewModel>(
      () => NotificationListViewModel());

  locator.registerLazySingleton<PrintService>(() => PosPrintService());
  locator.registerLazySingleton<newProductSearch.ProductSearchViewModel>(
      () => newProductSearch.ProductSearchViewModel());

  locator.registerLazySingleton<IAppService>(() => AppViewModel());
  locator.registerLazySingleton<DataService>(() => DataService());
  locator.registerFactory<PosOrderGioHangListViewModel>(
    () => PosOrderGioHangListViewModel(),
  );
  locator.registerFactory<PosPointSaleListViewModel>(
    () => PosPointSaleListViewModel(),
  );
  locator.registerFactory<PosCartViewModel>(
    () => PosCartViewModel(),
  );
  locator.registerFactory<PosProductListViewmodel>(
      () => PosProductListViewmodel());
  locator.registerFactory<PosMoneyCartViewModel>(() => PosMoneyCartViewModel());
  locator.registerFactory<PosPartnerListViewModel>(
      () => PosPartnerListViewModel());
  locator.registerFactory<PosPartnerAddEditViewModel>(
      () => PosPartnerAddEditViewModel());
  locator.registerFactory<PosPriceListViewModel>(() => PosPriceListViewModel());
  locator.registerFactory<PosPaymentViewModel>(() => PosPaymentViewModel());
}
