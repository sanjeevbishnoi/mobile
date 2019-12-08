/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 9:23 AM
 *
 */

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_facebook_user_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';

class SaleFacebookCommentViewModel implements ViewModelBase {
  //log
  final log = new Logger("SaleFacebookCommentViewModel");
  FacebookComment comment;

  //facebookUser
  SaleFacebookUserViewModel _facebookUser;
  SaleFacebookUserViewModel get facebookUser => _facebookUser;

  BehaviorSubject<SaleFacebookUserViewModel> _facebookUserController =
      new BehaviorSubject();
  Stream<SaleFacebookUserViewModel> get facebookUserStream =>
      _facebookUserController.stream;

  set facebookUser(SaleFacebookUserViewModel value) {
    _facebookUser = value;
    if (_facebookUserController.isClosed == false)
      _facebookUserController.add(value);
  }

  bool _isShowMoreFunction = false;
  bool get isShowMoreFunction => _isShowMoreFunction;
  set isShowMoreFunction(bool value) {
    _isShowMoreFunction = !_isShowMoreFunction;
    if (notifyListennerController.isClosed == false) {
      notifyListennerController.add(true);
    }
  }

  //Status
  String _status = "";
  String get status => _status;

  BehaviorSubject<String> _statusController = new BehaviorSubject();
  Stream<String> get statusStream => _statusController.stream;
  set status(String value) {
    _status = value;
    if (_statusController.isClosed == false) _statusController.add(value);
  }

  // IsBusy
  bool _isBusy = false;
  bool get isBusy => _isBusy;
  BehaviorSubject<bool> _isBusyController = new BehaviorSubject();
  Stream<bool> get isBusyStream => _isBusyController.stream;

  set isBusy(bool value) {
    _isBusy = value;
    if (_isBusyController.isClosed == false) _isBusyController.add(value);
  }

  List<SaleFacebookCommentViewModel> comments =
      new List<SaleFacebookCommentViewModel>();

  bool get isCreatedOrder {
    if (this.facebookUser != null &&
        this.facebookUser.orderNumber != null &&
        this.facebookUser.orderNumber.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  bool isPrintTag = false;

  BehaviorSubject<bool> notifyListennerController = new BehaviorSubject();
  Stream<bool> get notifyListennerStream => notifyListennerController.stream;

  SaleFacebookCommentViewModel(
      {this.comment, SaleFacebookUserViewModel facebookUser, this.comments}) {
    this._facebookUser = facebookUser;
    this.isBusy = false;
  }

  @override
  void dispose() {
    notifyListennerController.close();
    _facebookUserController.close();
    this._isBusyController.close();
    this._statusController.close();
  }
}
