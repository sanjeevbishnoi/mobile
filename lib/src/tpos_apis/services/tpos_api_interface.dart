import 'package:flutter/foundation.dart';
import 'package:tpos_mobile/category/mail_template/mail_template.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_model.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_result.dart';
import 'package:tpos_mobile/pos_order/models/pos_make_payment.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/sale_online/models/FacebookWinner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/odata_filter.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/tpos_service_models.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_order/sale_order.dart';
import 'package:tpos_mobile/sale_order/sale_order_line.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_facebook_partner_result.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_saved_facebook_post_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_account_tax.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_application_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_payment.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order_stock_picking_type.dart';
import 'package:tpos_mobile/src/tpos_apis/models/get_product_template_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/get_ship_token_result_model.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_cateogry_for_stock_ware_house_report.dart';
import 'package:tpos_mobile/src/tpos_apis/models/register_tpos_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/status_extra.dart';
import 'package:tpos_mobile/src/tpos_apis/models/stock_report_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_city.dart';
import 'package:tpos_mobile/src/tpos_apis/models/user_activities.dart';
import 'package:tpos_mobile/src/tpos_apis/models/web_app_route.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';

abstract class ITposApiService {
  /// Đăng ký ứng dụng
  Future<RegisterTposResult> registerTpos({
    @required String name,
    String message,
    @required String email,
    String company,
    @required String phone,
    String cityCode,
    String prefix,
    String facebookPhoneValidateToken,
    String facebookUserToken,
  });

  /// Lấy danh sách tỉnh  thành đăng kí ứng dụng
  Future<List<TPosCity>> getTposCity();

  /// Đăng nhập ứng dụng
  Future<LoginInfo> setAuthentiacation(
      {String username, String password, String shopUrl});

  /// Đắng nhập
  Future<LoginInfo> login({
    @required String username,
    @required String password,
  });

  /// Refresh Token
  Future<LoginInfo> getLoginInfoFromRefreshToken(
      {@required String refreshToken});

  /// Cập nhật lại thông tin đang nhập
  Future<void> setAuthenticationInfo({String accessToken, String shopUrl});

  /// Kiểm token còn hiệu lực
  Future<bool> checkTokenIsValid();

  /// Lấy thông tin người đang đăng nhập
  Future<TposUser> getLoginedUserInfo();

  /// Lấy cấu hình người dùng
  Future<WebUserConfig> getWebUserConfig();

  /// Lấy danh sách kênh bán hàng facebook đã lưu
  Future<List<CRMTeam>> getCRMTeamAllFacebook();

  Future<CheckFacebookIdResult> checkFacebookId(
      String asUid, String postId, int teamId,
      {int timeoutSecond});

  Future<String> getFacebookUidFromAsuid(String asuid, int teamId);

  /// Kiểm tra khách hàng theo Asuid
  Future<Map<String, dynamic>> checkPartnerJson({
    @required String aSUId,
  });

  /// Kết quả trả về là một danh sách Partner
  Future<List<Partner>> checkPartner(
      {@required String asuid, @required int crmTeamId});

  /// Lấy danh sách trạng thái đơn hàng
  Future<List<SaleOnlineStatusType>> getSaleOnlineOrderStatus();

  /// Lấy danh sách chiến dịch live còn hoạt động
  Future<List<LiveCampaign>> getAvaibleLiveCampaigns();

  /// Lấy danh sách chiến dịch
  Future<List<LiveCampaign>> getLiveCampaigns();

  /// Lấy chiến dịch của bài đăng hiện tại
  Future<LiveCampaign> getLiveCampaignByPostId(String postId);

  /// Lấy chi chiến dịch live theo Id
  Future<LiveCampaign> getDetailLiveCampaigns(String liveCampaignId);

  /// Thêm chiến dịch live mới
  Future<bool> addLiveCampaign({@required LiveCampaign newLiveCampaign});

  /// Sửa chiến dịch live
  Future<bool> editLiveCampaign(LiveCampaign editLiveCampaign);

  // SaleOnlineLiveCampaign-Update| Cập nhật thông tin chiến dịch
  Future<bool> updateLiveCampaignFacebook(
      {@required LiveCampaign campaign,
      TposFacebookPost tposFacebookPost,
      bool isCancel = false});

  /// Lấy tất cả danh sách khách hàng facebook
  Future<Map<String, GetFacebookPartnerResult>> getFacebookPartners(int teamId);

  /// Lấy danh sách sản phẩm
  Future<List<Product>> getProducts();

  /// Lấy sản phẩm tìm kiếm theo Id
  /// param ProductId, return Product object
  Future<OdataResult<Product>> getProductSearchById(int productId);

  /// Tìm kiếm sản phẩm
  Future<ProductSearchResult<List<Product>>> productSearch(String keyword,
      {ProductSearchType type = ProductSearchType.ALL,
      int top,
      int skip,
      bool isSearchStartWith = false,
      OdataSortItem sortBy,
      int groupId});

  /// Tìm kiếm danh mục sản phẩm
  Future<ProductSearchResult<List<ProductCategory>>> productCategorySearch(
      String keyword,
      {int top,
      int skip,
      OdataSortItem sortBy});

  /// Tìm kiếm Product Template
  Future<ProductSearchResult<List<ProductTemplate>>> productTemplateSearch(
      String keyword,
      {int top,
      int skip,
      OdataSortItem sortBy,
      FilterBase filterItem});

  /// Lấy danh sách sản phẩm (Template)
  Future<GetProductTemplateResult> getProductTemplate(
      {int page,
      int pageSize = 1000,
      int skip = 0,
      int take = 1000,
      OdataFilter filter,
      List<OdataSortItem> sorts});

  /// Tìm kiếm nhóm khách hàng
  Future<ProductSearchResult<List<PartnerCategory>>> partnerCategorySearch(
      String keyword,
      {int top,
      int skip,
      OdataSortItem sortBy,
      FilterBase filterItem});

  Future<List<Product>> getLastProductsVersion2(int version);

  /// Lấy danh sách sản phẩm phân trang
  Future<List<Product>> getProductsPagination(int top, int skip);

  /// Lấy danh sách report sale order general
  Future<ReportSaleOrderGeneral> getReportSaleOrderGeneral(
      int top,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId);

  /// Lấy danh sách report order detail
  Future<List<ReportSaleOrderLine>> getReportSaleOrderDetail(int id);

  /// Lấy danh sách report delivery order line
  Future<List<ReportDeliveryOrderLine>> getReportDeliveryOrderDetail(int id);

  /// Lấy danh sách report sale order general
  Future<SumReportSaleGeneral> getSumReportSaleGeneral(
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId);

  /// Lấy danh sách report sale order general
  Future<SumAmountReportSale> getSumAmountReportSale(
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId);

  /// Lấy danh sách report sale order
  Future<ReportSaleOrder> getReportSaleOrder(
      int top,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String orderType,
      String companyId,
      int partnerId,
      String staffId);

  /// Lấy danh sách thống kê giao hàng
  Future<ReportDelivery> getReportDelivery(
      int take,
      int skip,
      DateTime dateFrom,
      DateTime dateTo,
      String shipState,
      int partnerId,
      int carrierId);

  /// Lấy danh sách thống kê giao hàng
  Future<SumDeliveryReport> getReportSumDelivery(DateTime dateFrom,
      DateTime dateTo, String shipState, int partnerId, int carrierId);

  /// Lấy đơn hàng sale online theo Id
  Future<SaleOnlineOrder> getOrderById(String orderId);

  /// Xóa đơn hàng online
  Future<void> deleteSaleOnlineOrder(String orderId);

  /// Lấy Fast sale order line theo Id
  Future<List<FastSaleOrderLine>> getFastSaleOrderLineById(int orderId);

  /// Lấy Fast sale order line theo Id
  Future<List<SaleOrderLine>> getSaleOrderLineById(int orderId);

  /// Cập nhật trạng thái giao hàng tất cả hóa đơn
  Future<void> refreshFastSaleOnlineOrderDeliveryState();

  /// Cập nhật trạng thái giao hàng hóa đơn được chọn
  Future<void> refreshFastSaleOrderDeliveryState(List<int> ids);

  /// Lấy  sale order theo Id
  Future<SaleOrder> getSaleOrderById(int orderId, {bool getForEdit = false});

  /// Lây danh sách đơn hàng sale online theo Facebook Post Id
  Future<List<SaleOnlineOrder>> getOrdersByFacebookPostId(String postId);

  /// Tạo đơn hàng từ app
  Future<SaleOnlineOrder> insertSaleOnlineOrderFromApp(SaleOnlineOrder order,
      {int timeoutSecond});

  /// Sửa đơn hàng từ app
  Future<void> updateSaleOnlineOrder(SaleOnlineOrder order);

  /// Lấy danh sách bài đăng đã lưu (id, liveCampaignId, liveCampaignName)
  Future<List<SavedFacebookPost>> getSavedFacebookPost(
      String fromId, List<String> postIds);

  /// Lấy danh sách sale order
  Future<SearchResult<List<SaleOrder>>> getSaleOrderList(
      int take, int skip, String keyword, DateTime dateTo, DateTime dateFrom);

  /// Sale order info
  Future<List<SaleOrderLine>> getSaleOrderInfo(int id);

  /// Reset số thứ tự đơn hàng sale online
  Future<bool> resetSaleOnlineOrderSessionIndex();

  /// Lấy khách hàng theo id
  Future<Partner> getPartnerById(int id);

  Future<List<PartnerStatus>> getPartnerStatus();

  /// Cập nhật trạng thái khách hàng
  Future<bool> updatePartnerStatus(int partnerId, String statusString);

  /// Check địa chỉ
  Future<List<CheckAddress>> quickCheckAddress(String keyword);

  /// Lấy
  Future<GetSaleOnlineOrderFromAppResult> getSaleOnlineOrderFromApp(
      List<String> listOrderId);

  ///Insert order from app
  Future<InsertFastSaleOrderFromAppResult> insertFastSaleOrderFromApp(Map data);

  ///Lấy phí ship cho hóa đơn
  Future<CalculateFastOrderFeeResult> calculateFeeFastSaleOrder(Map order);

  Future<bool> changeLiveCampaignStatus(String liveCampaignId);

  /// Lấy danh sách trạng thái giao hàng từ ngày tới ngày
  Future<List<DeliveryStatusReport>> getFastSaleOrderDeliveryStatusReports(
      {@required DateTime startDate, @required DateTime endDate});

  /// Lấy SaleOnlineFacebookPostSummaryUser
  Future<SaleOnlineFacebookPostSummaryUser>
      getSaleOnlineFacebookPostSummaryUser(String id);

  /// Lấy lượt share facebook
  /// /api/facebook
  Future<List<FacebookShareInfo>> getSharedFacebook(
    String postId,
    String uId, {
    bool mapUid = false,
  });

  ///Lấy danh mục sản phẩm
  Future<List<ProductCategory>> getProductCategories();

  /// Lấy danh mục sản phẩm theo Id
  Future<OdataResult<ProductCategory>> getProductCategory(int id);

  /// Lấy nhóm khách hàng parent theo Id
  Future<OdataResult<PartnerCategory>> getPartnerCategory(int id);

  /// Xóa nhóm khách hàng
  Future<void> deletePartnerCategory(int categoryId);

  ///Lấy phương thức thanh toán
  Future<List<PaymentMethod>> getPaymentMethod();

  /// Khởi tạo thông tin bán hàng
  Future<FastSaleOrderAddEditData> prepareFastSaleOrder(saleOnlineIds);

  /// Get status report
  Future<List<StatusReport>> getStatusReport(startDate, endDate);

  /// Tính phí giao hàng
  Future<CalucateFeeResultData> calculateShipingFee({
    int partnerId,
    int companyId,
    int carrierId,
    double weight,
    ShipReceiver shipReceiver,
    List<ShipServiceExtra> shipServiceExtras,
    double shipInsuranceFee,
    String shipServiceId,
    String shipServiceName,
  });

  /// Tạo hóa đơn bán hàng
  Future<TPosApiResult<FastSaleOrderAddEditData>> createFastSaleOrder(
      FastSaleOrderAddEditData order,
      [bool isDraft = false]);

  /// SaleOnlineFacebookCommment  | Lây danh sách bình luận từ post
  Future<List<SaleOnlineFacebookComment>> getCommentsByUserAndPost(
      {String userId, String postId});

  Future<CRMTeam> insertCRMTeam(CRMTeam data);

  /// Delete CRMTeam
  Future<void> deleteCRMTeam(int id);
  Future<bool> checkSaleOnlineFacebookAccount(
      {String facebookId,
      String facebookName,
      String facebookAvatar,
      String token});

  Future<List<CompanyOfUser>> getCompanyOfUser();
  Future<List<UserReportStaff>> getUserReportStaff();

  Future<int> getAppDateExpired();
  Future<CompanyCurrentInfo> getCompanyCurrentInfo();

  /// Thêm sản phẩm template
  Future<ProductTemplate> quickInsertProductTemplate(
      ProductTemplate newProduct);

  /// Thêm sản phẩm
  Future<Product> quickInsertProduct(Product newProduct);

  /// Thêm danh mục sản phẩm
  Future<ProductCategory> insertProductCategory(
      ProductCategory productCategory);

  /// Thêm nhóm khách hàng
  Future<PartnerCategory> insertPartnerCategory(
      PartnerCategory partnerCategory);

  /// Get SaleOnlineOrders
  Future<List<SaleOnlineOrder>> getSaleOnlineOrders(
      {int take,
      int skip,
      int partnerId,
      String facebookPostId,
      int crmTeamId,
      DateTime fromDate,
      DateTime toDate});

  /// Lấy sanh sách đơn hàng online filter
  Future<List<SaleOnlineOrder>> getSaleOnlineOrdersFilter(
      {int take, int skip, OdataFilter filter, OdataSortItem sort});

  /// Lấy danh sách đơn hàng online view
  Future<List<ViewSaleOnlineOrder>> getViewSaleOnlineOrderWithFitter(
      {int take, int skip, OdataFilter filter, OdataSortItem sort});

  /// Lấy đơn vị sản phẩm
  Future<List<ProductUOM>> getProductUOM({uomCateogoryId});

  /// Lấy Product UOMLine
  Future<List<ProductUOMLine>> getProductUOMLine(int productId);

  /// Lấy ProductAttribute
  Future<List<ProductAttributeLine>> getProductAttribute(int productId);

  /// Lấy danh sách khách hàng
  Future<List<Partner>> getPartners(keyWord);

  /// Lấy danh sách khách hàng for search
  Future<List<Partner>> getPartnersForSearch(keyWord, int take,
      {bool isCustomer, bool isSupplier, bool onlyActive = false});

  /// Lấy nhóm khách hàng
  Future<List<PartnerCategory>> getPartnerCategories();

  ///  Lấy bảng giá khách hàng
  Future<List<ProductPrice>> getProductPrices();

  /// Lấy bảng giá còn hiệu lực theo ngày
  Future<List<ProductPrice>> getPriceListAvaible(DateTime dateTime);

  /// Lấy bảng giá mặc định
  Future<TPosApiResult<ProductPrice>> getDefaultProductPrice();

  /// Lấy điều khoản thanh toán
  Future<List<AccountPaymentTerm>> getAccountPayments();

  // Thêm khách hàng
  Future<TPosApiResult<Partner>> addPartner(Partner newPartner);

  // Lấy thông tin khách hàng theo Id
  Future<Partner> loadPartner(int id);

  // Lấy thông tin product template theo Id
  Future<ProductTemplate> loadProductTemplate(int id);

  // Lấy thông tin product theo Id
  Future<Product> loadProduct(int id);

  // Edit khách hàng
  Future<TPosApiResult<bool>> editPartner(Partner newPartner);

  /// Edit Product Template
  Future<TPosApiResult<bool>> editProductTemplate(
      ProductTemplate productTemplate);

  /// Edit Product
  Future<TPosApiResult<bool>> editProduct(Product product);

  /// Edit Product Category
  Future<TPosApiResult<bool>> editProductCategory(
      ProductCategory productCategory);

  /// Edit Partner Category
  Future<TPosApiResult<bool>> editPartnerCategory(
      PartnerCategory partnerCategory);

  /// Lấy thông tin hóa đơn để chỉnh sửa
  Future<FastSaleOrderAddEditData> getFastSaleOrderForEdit(int id);

  /// Lấy thông tin hóa đơn pdf
  Future<FastSaleOrder> getFastSaleOrderForPDF(int id);

  /// Lấy barcode phiếu ship
  Future<String> getBarcodeShip(String id);

  /// Lấy danh sách kênh bán hàng facebook
  Future<List<CRMTeam>> getSaleChannelList();

  /// Kiểm tra địa chỉ nhanh
  Future<List<CheckAddress>> checkAddress(String text);

  /// Sửa kênh bán hàng facebook
  Future<bool> editSaleChannelById({CRMTeam crmTeam});

  /// Thêm kênh bán hàng facebook
  Future<bool> addSaleChannel({CRMTeam crmTeam});

  /// Lấy danh sách PrinterConfigs
  Future<List<PrinterConfigs>> getPrinterConfigs();

  /// Cancel ship, Hủy vận đơn giao hàng
  Future<TPosApiResult<bool>> fastSaleOrderCancelShip(int orderId);

  /// Hủy hóa đơn giao/ bán hàng
  Future<TPosApiResult<bool>> fastSaleOrderCancelOrder(List<int> orderIds);

  /// Xác nhận hóa đơn bán hàng nhanh/ hóa đơn giao hàng
  Future<TPosApiResult<bool>> fastSaleOrderConfirmOrder(List<int> orderIds);

  /// Xác nhận sale order
  Future<bool> confirmSaleOrder(int orderId);

  /// Xóa sale order
  Future<TPosApiResult<bool>> deleteSaleOrder(int id);

  /// hủy sale order
  Future<TPosApiResult<bool>> cancelSaleOrder(int orderId);

  /// Tạo hóa đơn sale order
  Future<TPosApiResult<bool>> createSaleOrderInvoice(int orderId,
      {List<int> orderIds});

  /// Chuẩn bị thanh toán đơn hàng
  Future<TPosApiResult<AccountPayment>> accountPaymentPrepairData(int orderId);

  /// Thanh toán hóa đơn
  Future<TPosApiResult<int>> accountPaymentCreatePost(AccountPayment data);

  /// Lấy danh sách phương thức thanh toán
  Future<TPosApiResult<List<AccountJournal>>> accountJournalGetWithCompany();

  Future<OdataResult<List<PaymentInfoContent>>> getPaymentInfoContent(
      int orderId);

  Future<OdataResult<AccountPayment>> accountPaymentOnChangeJournal(
      int journalId, String paymentType);

  /// Xóa khách hàng
  Future<void> deletePartner(int id);

  /// Xóa danh mục sản phẩm
  Future<TPosApiResult<bool>> deleteProductCategory(int id);

  /// Lấy danh sách người dùng ứng dụng
  Future<OdataResult<List<ApplicationUser>>> getApplicationUsers();

  Future<OdataResult<List<ApplicationUser>>> getApplicationUsersSaleOrder(
      String keyword);

  /// Lấy danh sách kho hàng
  /// Tạo hóa đơn bán hàng nhanh
  Future<OdataResult<List<StockWareHouse>>>
      getStockWareHouseWithCurrentCompany();

  /// Lấy danh sách tất cả kho hàng
  Future<List<StockWareHouse>> getStockWarehouse();

  /// Lấy danh sách tồn kho sản phẩm
  /// Kết quả trả về ở dạng MapEntry <int, int> . Ví dụ: <IdSanPham, Tồn kho>
  Future<Map<String, dynamic>> getProductInventory();

  /// Lấy tồn kho 1 sản phẩm kết quả trả về là danh sách tồn kho theo công ty
  /// Input tmplId
  /// Return GetInventoryProductResult
  Future<GetInventoryProductResult> getProductInventoryById({int tmplId});
  Future<OdataResult<SaleOrder>> getSaleOrderWhenChangePartner(SaleOrder order);

  /// Lấy giá trị mặc định tạo hóa đơn bán hàng nhanh từ đơn hàng sale online mà không cần chọn sản phẩm
  Future<CreateQuickFastSaleOrderModel> getQuickCreateFastSaleOrderDefault(
      List<String> saleOnlineIds);

  Future<CreateQuickFastSaleOrderResult> createQuickFastSaleOrder(
      CreateQuickFastSaleOrderModel model);

  /// Xóa hóa đơn bán hàng
  Future<void> deleteFastSaleOrder(int orderId);

  Future<OdataResult<SaleOrder>> getSaleOrderDefault();

  /// Lấy chi tiết đơn hàng nếu tạo hóa đơn từ đơn hàng online
  Future<OdataResult<FastSaleOrderSaleLinePrepareResult>>
      getDetailsForCreateInvoiceFromOrder(List<String> saleOnlineIds);

  /// Thêm hóa đơn mới
  Future<FastSaleOrder> insertFastSaleOrder(FastSaleOrder order, bool isDraft);

  /// Thêm Sale Order
  Future<SaleOrder> insertSaleOrder(SaleOrder order, bool isDraft);

  /// Sửa hóa đơn
  Future<void> updateFastSaleOrder(FastSaleOrder order);

  /// Sửa sale order
  Future<void> updateSaleOrder(SaleOrder order);

  Future<FastSaleOrderLine> getFastSaleOrderLineProductForCreateInvoice({
    FastSaleOrderLine orderLine,
    FastSaleOrder order,
  });

  Future<SaleOrderLine> getSaleOrderLineProductForCreateInvoice({
    SaleOrderLine orderLine,
    SaleOrder order,
  });

  /// Lấy thống kê tổng quan trang chủ
  Future<DashboardReport> getDashboardReport(
      {String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"});

  /// Lấy thống kê overview trang chủ
  Future<DashboardReportOverView> getDashboardReportOverview(
      {String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"});

  /// Lấy danh sách phường /xã
  Future<List<WardAddress>> getWardAddress(String districtCode);

  /// Hàm lấy Danh sách District
  Future<List<DistrictAddress>> getDistrictAddress(String cityCode);

  /// Lấy danh sách thành phố
  Future<List<CityAddress>> getCityAddress();

  /// Lấy danh sách chiến dịch live
  Future<List<SaleOnlineLiveCampaign>> getSaleOnlineLiveCampaign();

  /// Lấy nội dung in html
  /// type (ship,orderA4, orderA5)
  Future<String> getFastSaleOrderPrintDataAsHtml(
      {@required fastSaleOrderId, String type, int carrierId});

  /// Lấy cấu hình công ty
  Future<CompanyConfig> getCompanyConfig();

  /// Lưu cấu hình công ty
  Future<CompanyConfig> saveCompanyConfig(CompanyConfig config);

  ///Chuyển công ty
  Future<void> switchCompany(int companyId);

  /// Lấy danh sách mẫu trả lời comment, tin nhắn facebook
  Future<List<MailTemplate>> getMailTemplates();

  /// Thêm mẫu tin nhắn
  Future<void> addMailTemplate(MailTemplate template);

  /// Lấy puid facebook theo asuid và page id
  /// /api/facebook
  Future<String> getFacebookPSUID(
      {@required String asuid, @required String pageId});

  /// Lưu bình luận facebook
  /// Param post
  /// Return String: id Của bài viết
  Future<String> insertFacebookPostComment(
      List<TposFacebookPost> posts, int crmTeamId);

  /// Gửi lại vận đơn của hóa đơn giao hàng nhah
  Future<void> sendFastSaleOrderToShipper(int fastSaleOrderId);

  /// Tắt mở tính năng số  thứ tự đơn hàng sale online
  Future<ApplicationConfigCurrent> updateSaleOnlineSessionEnable();

  /// Kiểm tra phiên bán hàng online có mở hay không
  Future<ApplicationConfigCurrent> getCheckSaleOnlineSessionEnable();

  ///Lấy danh sách Phiếu nhập hàng
  Future<List<FastPurchaseOrder>> getFastPurchaseOrderList(
      take, skip, page, pageSize, sort, filter);

  ///Xóa nhiều Phiếu nhập hàng
  Future<String> unlinkPurchaseOrder(List<int> ids);

  Future<void> sendFacebookPageInbox(
      {@required String message,
      @required int cmrTeamid,
      @required FacebookComment comment,
      @required String facebookPostId});

  ///xem chi tiết hóa đơn nhập hàng bằng ID
  Future<FastPurchaseOrder> getDetailsPurchaseOrderById(int id);

  ///Lấy form mẫu payment
  Future<FastPurchaseOrderPayment> getPaymentFastPurchaseOrderForm(int id);

  ///thanh toán hóa đơn
  Future<Map<String, dynamic>> doPaymentFastPurchaseOrder(
      FastPurchaseOrderPayment fastPurchaseOrder);

  ///lấy danh sách phương thức thanh toán nhập hàng
  Future<List<JournalFPO>> getJournalOfFastPurchaseOrder();

  ///hủy hóa đơn nhập hàng
  Future<String> cancelFastPurchaseOrder(List<int> ids);

  ///lấy mẫu hóa đơn nhập hàng mặc định
  Future<FastPurchaseOrder> getDefaultFastPurchaseOrder();

  ///Lấy danh sách thuế của hóa đơn nhập hàng
  Future<List<AccountTaxFPO>> getListAccountTaxFPO();

  ///Lấy danh sách nhà cung cấp
  Future<List<PartnerFPO>> getListPartnerFPO();

  ///Lấy danh sách loại hoạt động
  Future<List<StockPickingTypeFPO>> getStockPickingTypeFPO();

  ///Tìm kiếm nhà cung cấp
  Future<List<PartnerFPO>> getListPartnerByKeyWord(String text);

  ///Lấy danh sách Application User FPO
  Future<List<ApplicationUserFPO>> getApplicationUserFPO();

  ///Lấy model Account khi thay đổi partner trong hóa đơn gia hàng
  Future<Account> onChangePartnerFPO(FastPurchaseOrder fastPurchaseOrder);

  ///Lấy ProductUOM và Account của product khi thay đẩy orderlines của hóa đơn nhập hàng
  Future<OrderLine> onChangeProductFPO(
      FastPurchaseOrder fastPurchaseOrder, OrderLine orderLine);

  ///Lấy danh sách sản phẩm
  Future<List<Product>> getProductsFPO();

  ///Lấy UOM của  product
  Future<ProductUOM> getUomFPO(int id);

  ///Lấy thuế
  Future<List<AccountTaxFPO>> getTextFPO();

  /// /odata/SaleSettings/ODataService.DefaultGet?$expand=SalePartner,DeliveryCarrier,Tax
  /// Lấy setting cấu hình cho hiện CK-Giảm tiền

  ///Lưu hóa đơn nhập hàng
  Future<FastPurchaseOrder> actionInvoiceDraftFPO(FastPurchaseOrder item);

  /// Xác nhận hóa đơn nhập hàng bằng id
  Future<bool> actionInvoiceOpenFPO(FastPurchaseOrder item);

  /// Sửa hóa đơn nhập hàng
  Future<FastPurchaseOrder> actionEditInvoice(FastPurchaseOrder item);

  ///input id phiếu nhập hàng , output phiếu trả hàng
  Future<int> createRefundOrder(int id);

  ///tìm kiếm sản phẩm
  Future<List<Product>> actionSearchProduct(String text);

  /// Lấy thống kê overview trang chủ
  Future<dynamic> getDashBoardChart(
      {@required String chartType,
      String columnChartValue = "W",
      String columnCharText = "TUẦN NÀY",
      String barChartValue = "W",
      String barChartText = "TUẦN NÀY",
      int barChartOrderValue = 1,
      String barChartOrderText = "THEO DOANH SỐ",
      String lineChartValue = "WNWP",
      String lineChartText = "TUẦN NÀY",
      String overViewValue = "T",
      String overViewText = "HÔM NAY"});

  /// Xóa sản phẩm trong danh mục
  Future<void> deleteProductTemplate(int id);

  Future<Map<String, dynamic>> getPriceListItems(int priceListId);

  /// Lấy doanh số khách hàng
  Future<PartnerRevenue> getPartnerRevenue(int id);

  /// Lấy danh sách hóa đơn khách hàng
  Future<List<FastSaleOrder>> getInvoicePartner(int id, int top, int skip);

  /// Lấy danh sách hóa đơn giao hàng khách hàng
  Future<List<FastSaleOrder>> getDeliveryInvoicePartner(
      int take, int skip, sort, filter, int page, int pageSize);

  /// Lấy chi tiết nợ khách hàng
  Future<List<CreditDebitCustomerDetail>> getCreditDebitCustomerDetail(
      int id, int top, int skip);

  ///Lấy dữ liệu hoạt động của user hiện tại
  Future<UserActivities> getUserActivities({int skip, int limit});

  ///Đổi mật khẩu user
  Future<bool> doChangeUserPassWord(
      {String oldPassword, String newPassword, String confirmPassWord});

  Future<List<String>> getCommentIdsByPostId(String postId);

  Future<FacebookWinner> updateFacebookWinner(FacebookWinner facebookWinner);

  Future<List<FacebookWinner>> getFacebookWinner();

  /// Lấy báo cáo nhập xuất tồn
  Future<StockReport> getStockReport({
    DateTime fromDate,
    DateTime toDate,
    bool isIncludeCanceled = false,
    bool isIncludeReturned = false,
    int wareHouseId,
    int productCategoryId,
  });

  Future<List<ProductCategoryForStockWareHouseReport>>
      getProductCategoryForStockReport();

  Future<PosOrderResult> getPosOrders(
      {int page,
      int pageSize,
      int skip,
      int take,
      OdataFilter filter,
      List<OdataSortItem> sorts});

  Future<TPosApiResult<bool>> deletePosOrder(int id);

  Future<PosOrder> getPosOrderInfo(int id);

  Future<List<PosOrderLine>> getPosOrderLines(int id);

  Future<List<PosAccountBankStatement>> getPosAccountBankStatement(int id);

  Future<TPosApiResult<String>> refundPosOrder(int id);

  Future<TPosApiResult<PosMakePayment>> getPosMakePayment(int id);

  Future<TPosApiResult<bool>> posMakePayment(
      PosMakePayment payment, int posOrderId);

  // MAIL TEMPLATE
  Future<MailTemplateResult> getMailTemplateResult();
  Future<MailTemplate> getMailTemplateById(int id);
  Future<TPosApiResult<bool>> deleteMailTemplate(int id);
  Future<List<MailTemplateType>> getMailTemplateType();
  Future<bool> updateMailTemplate(MailTemplate template);

  /*DELIVERY CARRIER*/
  Future<List<DeliveryCarrier>> getDeliveryCarriers();
  Future<DeliveryCarrier> getDeliveryCarrierById(int id);
  Future<void> deleteDeliveryCarrier(int carrierId);
  Future<void> updateDeliveryCarrier(DeliveryCarrier edit);
  Future<void> createDeliveryCarrier(DeliveryCarrier item);

  /// Lấy danh sách đối tác giao hàng cho thêm mới, chỉnh sửa...
  Future<List<DeliveryCarrier>> getDeliveryCarriersList();

  /// Lấy giá trị mặc định khi thêm đối tác giao hàng mới
  Future<DeliveryCarrier> getDeliverCarrierCreateDefault();

  /*DELIVERY CARRIER*/

/* ASHIP API*/
  Future<GetShipTokenResultModel> getShipToken(
      {String apiKey,
      String email,
      String host,
      String password,
      String provider});

  Future<String> getTokenShip();
/* ASHIP API*/

  /// Lấy danh sách trạng thái sale online tùy chỉnh
  Future<List<StatusExtra>> getStatusExtra();

  Future<bool> saveChangeStatus(List<String> ids, String status);
}
