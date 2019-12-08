/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/live_campaign_detail.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';

class SaleOnlineLiveCampaignSelectProductViewModel extends Model
    implements ViewModelBase {
  LiveCampaign liveCampaign;

  // dialogController -Thông báo dialog
  BehaviorSubject<OldDialogMessage> _dialogController = new BehaviorSubject();
  Stream<OldDialogMessage> get dialogStream => _dialogController.stream;

  List<LiveCampaignDetail> details = new List<LiveCampaignDetail>();

  SaleOnlineLiveCampaignSelectProductViewModel();

  BehaviorSubject<List<LiveCampaignDetail>> _detailsController =
      new BehaviorSubject();
  Stream<List<LiveCampaignDetail>> get detailsStream =>
      _detailsController.stream;

  int index = 1;
  // Select product
  void addNewDetail(Product product) {
    LiveCampaignDetail newDetail = new LiveCampaignDetail();
    newDetail.productId = product.id;
    newDetail.index = index++;
    newDetail.productName = product.name;
    newDetail.uomId = product.uOMId;
    newDetail.uomName = product.uOMName;
    newDetail.quantity = 1;
    newDetail.price = product.price;

    var oldDetail;
    if (details.length > 0) {
      oldDetail = details.firstWhere((f) {
        return f.productId == newDetail.productId;
      }, orElse: () => null);
    }

    if (oldDetail != null) {
      oldDetail.quantity++;
    } else {
      details.add(newDetail);
    }
    _detailsController.add(details);
  }

  /// delete product
  void deleteDetail(LiveCampaignDetail detail) {
    details.remove((detail));
    _detailsController.add(details);
  }

  /// Thay đổi số lượng

  void changeQuantity(LiveCampaignDetail detail, bool isInscrease) {
    if (isInscrease)
      detail.quantity += 1;
    else if (detail.quantity > 1) {
      detail.quantity -= 1;
    }
    _detailsController.add(details);
  }

  /// Thay đổi đơn giá
  void changePrice(LiveCampaignDetail detail, bool isIncrease) {
    if (isIncrease)
      detail.price += 1000;
    else if (detail.price > 1000) {
      detail.price -= 1000;
    }
    _detailsController.add(details);
  }

  void changeProductQuantityCommand(LiveCampaignDetail item, double value) {
    item.quantity = value;
  }

  /// Xóa sản phẩm trong danh sách
  Future<void> deleteOrderLineCommand(LiveCampaignDetail item) async {
    if (details.contains(item)) {
      details.remove(item);
    }
  }

  @override
  void dispose() {
    _detailsController.close();
    _dialogController.close();
  }
}
