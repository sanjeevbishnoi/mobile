/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 3:20 PM
 *
 */

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';

abstract class ViewModelBase {
  void dispose() {}
}

class ViewModel extends Model implements ViewModelBase {
  bool _isBusy = false;
  bool get isBusy => _isBusy;
  bool isInit = false;
  bool isInitData = false;
  LogService _log;

  ViewModel({LogService logService}) {
    _log = logService ?? locator<LogService>();
  }

  LogService get logger => _log;

  ViewModelState _viewModelState;
  ViewModelState get state => _viewModelState;
  PublishSubject<String> notifyPropertyChangedController =
      new PublishSubject<String>();

  PublishSubject<OldDialogMessage> dialogMessageController =
      new PublishSubject<OldDialogMessage>();

  BehaviorSubject<bool> isBusyController = new BehaviorSubject<bool>();
  BehaviorSubject<String> viewModelStatusController = new BehaviorSubject();

  BehaviorSubject<ViewModelState> stateController = new BehaviorSubject();
  BehaviorSubject<ViewModelEvent> eventController =
      new BehaviorSubject<ViewModelEvent>();

  void onPropertyChanged(String name) {
    if (!notifyPropertyChangedController.isClosed) {
      notifyPropertyChangedController.sink.add(name);
      print("***On PropertyChanged " + name);
    }
  }

  void onStatusAdd(String value) {
    if (viewModelStatusController != null &&
        viewModelStatusController.isClosed == false) {
      viewModelStatusController.add(value);
    }
  }

  void onDialogMessageAdd(OldDialogMessage message) {
    if (!dialogMessageController.isClosed) {
      dialogMessageController.sink.add(message);
    }
  }

  void onIsBusyAdd(bool value) {
    _isBusy = value;
    if (!isBusyController.isClosed) {
      isBusyController.add(value);
    }
  }

  void onStateAdd(bool isBusy, {String message = "", ViewModelState state}) {
    _viewModelState =
        state ?? new ViewModelState(isBusy: isBusy, message: message);
    if (stateController.isClosed == false) {
      stateController.add(_viewModelState);
    }

    onIsBusyAdd(isBusy);
    onStatusAdd(message);
  }

  /// Ghi nhận sự kiện xuất phát từ Viewmodel
  /// Các sự kiện có thể là sự kiện nội bộ giữa Viewmodel và view hoặc sự kiện publish toàn phần mềm
  void onEventAdd(String eventName, Object param,
      {bool isAnalyticEvent, bool isGlobalEvent}) {
    if (eventController != null && eventController.isClosed == false) {
      eventController
          .add(new ViewModelEvent(eventName: eventName, param: param));
      _log.debug('VIEWMODEL EVENT [$eventName] ADDED with param [$param]');
    }
  }

  /// Thêm giá trị vào BehaverSubject một cách an toàn
  void addSubject<T>(Subject<T> subject, T value) {
    if (subject != null && subject.isClosed == false) {
      subject.add(value);
    }
  }

  /// Thêm lỗi vào BehaverSbject một cách an toàn
  void addErrorSubject<T>(Subject<T> subject, Object e, [StackTrace s]) {
    if (subject != null && subject.isClosed == false) {
      subject.addError(e, s);
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    notifyPropertyChangedController.close();
    dialogMessageController.close();
    isBusyController.close();
    stateController.close();
    viewModelStatusController.close();
    eventController.close();
  }
}

class ViewModelState {
  String message;
  bool isBusy;
  bool isError;

  ViewModelState({this.message, this.isBusy = false, this.isError = false});

  ViewModelState.error(String message) {
    this.isBusy = false;
    this.isError = true;
    this.message = message;
  }
}

class ViewModelEvent {
  String eventName;
  Object param;

  ViewModelEvent({this.eventName, this.param});
}

class ListViewModel extends ViewModel {
  IAppService _appService;
  ListViewModel(IAppService appService, {LogService logService})
      : super(logService: logService) {
    _appService = appService ?? locator<IAppService>();
  }
  bool permissionRead = false;
  bool permissionAdd = false;
  bool permissionEdit = false;
  bool permissionDelete = false;
  bool permissionCancel = false;

  void _setupBasicPermission() {}

  //TODO setupPermission;
}
