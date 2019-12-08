//import 'package:tpos_mobile/app_service_locator.dart';
//import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
//import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
//import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
//import 'package:tpos_mobile/src/tpos_apis/models/sale_online_status_type.dart';
//import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
//
//class NewSaleOnlineOrderListViewModel extends ViewModel {
//  ITposApiService _tposApi;
//
//  // Param
//  String _facebookPostId;
//  int _partnerId;
//  NewSaleOnlineOrderListViewModel({ITposApiService tposApi}) {
//    _tposApi = tposApi ?? locator<ITposApiService>();
//  }
//
//  // ViewModel
//  List<SaleOnlineOrder> _orders;
//  int _take = 1000;
//  int _skip = 0;
//
//  /*LỌC THEO ĐIỀU KIỆN*/
//  List<SaleOnlineStatusType> _orderStatus;
//  CRMTeam _crmTeam;
//  DateTime _fromDate;
//  DateTime _toDate;
//
//  /// init param
//  /// String facebookPostId (Lọc theo facebook post id)
//  /// String partnerid (Lọc theo khách hàng)
//  void init({String facebookPostId, int partnerId}) {
//    this._facebookPostId = facebookPostId;
//    this._partnerId = partnerId;
//  }
//
//  Future<void> _fetchOrder() async {
//    _orders = await _tposApi.getSaleOnlineOrders(
//      take: _take,
//      skip: _skip,
//    );
//  }
//
//  /// Khởi tạo dữ liệu ban đầu
//  Future<void> initData() {}
//}
