import 'dart:convert';

import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_model.dart';
import 'package:tpos_mobile/sale_online/services/tpos_api_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_result.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_service_base.dart';

abstract class IFastSaleOrderApi {
  /// Lấy danh sách hóa đơn giao hàng
  Future<TPosApiListResult<FastSaleOrder>> getDeliveryInvoices(
      {take, skip, page, pageSize, sort, filter});

  /// Lấy danh sách hóa đơn bán hàng
  Future<TPosApiListResult<FastSaleOrder>> getInvoices(
      {take, skip, page, pageSize, sort, filter});

  /// Lấy theo id
  Future<FastSaleOrder> getById(int id);

  /// Lấy thông tin hóa đơn khi thay đổi khách hàng
  /// Cập nhật lại bảng giá, Cấu hình giao hàng
  /// Dùng cho chức năng tạo hóa đơn bán hàng nhanh
  Future<OdataResult<FastSaleOrder>> getFastSaleOrderWhenChangePartner(
      FastSaleOrder order);

  /// Lấy giá trị mặc định để tạo hóa đơn bán hàng nhanh
  /// Mở rộng các giá trị Warehouse, User, PriceList, Company, Journal, PaymentJournal, Carrier, Tax
  Future<OdataResult<FastSaleOrder>> getFastSaleOrderDefault(
      {List<int> saleOrderIds, String type = "invoice"});
}

class FastSaleOrderApi extends ApiServiceBase implements IFastSaleOrderApi {
  @override
  Future<TPosApiListResult<FastSaleOrder>> getDeliveryInvoices(
      {take, skip, page, pageSize, sort, filter}) async {
    var body;
    Map temp = {
      "take": take,
      "skip": skip,
      "page": page,
      "pageSize": pageSize,
      "sort": sort,
      "filter": filter,
    }..removeWhere((key, value) => value == null);
    body = jsonEncode(temp);
    var response = await apiClient.httpPost(
      path: "/FastSaleOrder/DeliveryInvoiceList",
      body: body,
    );

    var json = jsonDecode(response.body);
    if (response.statusCode == 200)
      return TPosApiListResult<FastSaleOrder>(
        count: json["Total"],
        data: (json["Data"] as List)
            .map((f) => FastSaleOrder.fromJson(f))
            .toList(),
      );

    throwTposApiException(response);
    return null;
  }

  @override
  Future<TPosApiListResult<FastSaleOrder>> getInvoices(
      {take, skip, page, pageSize, sort, filter}) async {
    var body;
    Map temp = {
      "take": take,
      "skip": skip,
      "page": page,
      "pageSize": pageSize,
      "sort": sort,
      "filter": filter,
    }..removeWhere((key, value) => value == null);
    body = jsonEncode(temp);
    var response = await apiClient.httpPost(
      path: "/FastSaleOrder/List",
      body: body,
    );

    var json = jsonDecode(response.body);
    if (response.statusCode == 200)
      return TPosApiListResult<FastSaleOrder>(
        count: json["Total"],
        data: (json["Data"] as List)
            .map((f) => FastSaleOrder.fromJson(f))
            .toList(),
      );

    throwTposApiException(response);
    return null;
  }

  @override
  Future<FastSaleOrder> getById(int orderId, {bool getForEdit = false}) async {
    var response = await apiClient.httpGet(
        path:
            "/odata/FastSaleOrder($orderId)?\$expand=Partner,User,Warehouse,Company,PriceList,RefundOrder,Account,Journal,PaymentJournal,Carrier,Tax,SaleOrder,OrderLines(\$expand%3DProduct,ProductUOM,Account,SaleLine)");
    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return FastSaleOrder.fromJson(jsonMap);
    }

    throwTposApiException(response);
    return null;
  }

  @override
  Future<OdataResult<FastSaleOrder>> getFastSaleOrderWhenChangePartner(
      FastSaleOrder order) async {
    Map<String, dynamic> model = {"model": order.toJson(removeIfNull: true)};
    String body = jsonEncode(model);
    var response = await apiClient.httpPost(
      path: "/odata/FastSaleOrder/ODataService.OnChangePartner_PriceList",
      params: {"\$expand": "PartnerShipping,PriceList,Account"},
      body: body,
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return OdataResult.fromJson(jsonMap, parseValue: () {
        if (response.statusCode.toString().startsWith("2"))
          return FastSaleOrder.fromJson(jsonMap);
        else
          return null;
      });
    }
    throwTposApiException(response);
    return null;
  }

  @override
  Future<OdataResult<FastSaleOrder>> getFastSaleOrderDefault(
      {List<int> saleOrderIds = const <int>[], String type = "invoice"}) async {
    var model = {
      "model": {"Type": type, "SaleOrderIds": saleOrderIds ?? []}
    };

    String body = jsonEncode(model);

    var response = await apiClient.httpPost(
      path: "/odata/FastSaleOrder/ODataService.DefaultGet",
      params: {
        "\$expand":
            "Warehouse,User,PriceList,Company,Journal,PaymentJournal,Partner,Carrier,Tax"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      var jsonMap = jsonDecode(response.body);
      return OdataResult.fromJson(jsonMap, parseValue: () {
        return FastSaleOrder.fromJson(jsonMap);
      });
    }
    throwTposApiException(response);
    return null;
  }
}
