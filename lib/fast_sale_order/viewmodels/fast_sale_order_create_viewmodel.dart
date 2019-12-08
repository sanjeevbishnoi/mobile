///*
// * *
// *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
// *  * Copyright (c) 2019 . All rights reserved.
// *  * Last modified 4/9/19 9:53 AM
// *
// */
//
//import 'package:logging/logging.dart';
//import 'package:rxdart/rxdart.dart';
//import 'package:scoped_model/scoped_model.dart';
//import 'package:tpos_mobile/sale_online/models/tpos/fast_sale_order.dart';
//import 'package:tpos_mobile/sale_online/repositories/Repository.dart';
//import 'package:tpos_mobile/sale_online/viewmodels/viewmodel_base.dart';
//
//class FastSaleOrderCreateViewModel extends Model implements ViewModelBase {
//  //log
//  final _log = new Logger("FastSaleOrderViewModel");
//  Repository _repo;
//  FastSaleOrderCreateViewModel({Repository rep}) {
//    _repo = rep ?? Repository.instance;
//  }
//
//  //FastSaleOrder
//  FastSaleOrder _fastSaleOrder;
//  FastSaleOrder get fastSaleOrder => _fastSaleOrder;
//  set fastSaleOrder(FastSaleOrder value) {
//    _fastSaleOrder = value;
//    _fastSaleOrderController.add(_fastSaleOrder);
//  }
//
//  BehaviorSubject<FastSaleOrder> _fastSaleOrderController =
//      new BehaviorSubject();
//  Stream<FastSaleOrder> get fastSaleOrderStream =>
//      _fastSaleOrderController.stream;
//
//  //DeliveryCarrierList
//  List<DeliveryCarriers> _deliveryCarriers = new List<DeliveryCarriers>();
//  List<DeliveryCarriers> get deliveryCarriers => _deliveryCarriers;
//  set deliveryCarriers(List<DeliveryCarriers> value) {
//    _deliveryCarriers = value;
//    _deliveryCarriersController.add(value);
//  }
//
//  BehaviorSubject<List<DeliveryCarriers>> _deliveryCarriersController =
//      new BehaviorSubject();
//  Stream<List<DeliveryCarriers>> get deliveryCarriersStraem =>
//      _deliveryCarriersController.stream;
//
//  // selectedDeliveryCarrier
//  DeliveryCarriers _selectedDeliveryCarrier;
//  DeliveryCarriers get selectedDeliveryCarrier => _selectedDeliveryCarrier;
//  set selectedDeliveryCarrier(DeliveryCarriers value) {
//    _selectedDeliveryCarrier = value;
//    _selectedDeliveryCarrierController.add(value);
//  }
//
//  BehaviorSubject<DeliveryCarriers> _selectedDeliveryCarrierController =
//      new BehaviorSubject();
//  Stream<DeliveryCarriers> get selectedDeliveryCarrierStream =>
//      _selectedDeliveryCarrierController.stream;
//
//  Future<void> createFastSaleOrders() async {
//    try {} catch (ex, st) {
//      _log.severe("createFastSaleOrders", ex, st);
//    }
//  }
//
//  void init() {
//    createFastSaleOrders();
//  }
//
//  @override
//  void dispose() {
//    // TODO: implement dispose
//  }
//}
