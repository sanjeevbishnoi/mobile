/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/application_user.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SaleOrderUserViewModel extends ViewModel {
  //log
  final _log = new Logger("SaleOrderUserViewModel");
  ITposApiService _tposApi;
  SaleOrderUserViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  // List Selected Partner Category
  List<ApplicationUser> selectedUser;

  // List Partner Category
  List<ApplicationUser> _users;
  List<ApplicationUser> tempUsers;
  List<ApplicationUser> get users => _users;
  set users(List<ApplicationUser> value) {
    _users = value;
    _usersController.add(_users);
  }

  BehaviorSubject<List<ApplicationUser>> _usersController =
      new BehaviorSubject();
  Stream<List<ApplicationUser>> get usersStream => _usersController.stream;

  // Key word
  String _keyword = "";
  String get keyword => _keyword;
  set keyword(String value) {
    _keyword = value;
    notifyListeners();
  }

  Future<void> searchOrderCommand(String value) async {
    keyword = value;
    onSearchingOrderHandled(keyword);
    notifyListeners();
  }

  Future<void> onSearchingOrderHandled(String keyword) async {
    if (keyword == null || keyword == "") {
      users = tempUsers;
      notifyListeners();
    }
    try {
      String key = (removeVietnameseMark(keyword));
      users = tempUsers
          .where((f) => f.name != null
              ? removeVietnameseMark(f.name.toLowerCase())
                  .contains(key.toLowerCase())
              : false)
          .toList();
      notifyListeners();
    } catch (ex) {
      onDialogMessageAdd(new OldDialogMessage.error("", ex.toString()));
    }
  }

  Future loadPartnerCategory() async {
    try {
      var result = await _tposApi.getApplicationUsersSaleOrder(keyword);
      users = result.value;
      tempUsers = users;
    } catch (ex, stack) {
      _log.severe("loadUsers fail", ex, stack);
    }
  }

  Future init() async {
    await loadPartnerCategory();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
