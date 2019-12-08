import 'dart:async';

import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';

import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class NewLoginViewModel extends ViewModel {
  Logger _log = new Logger("NewLoginViewModel");
  ITposApiService _tposApi;
  ISettingService _settingService;

  NewLoginViewModel({ITposApiService tposApi, ISettingService settingService}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _settingService = settingService ?? locator<ISettingService>();
    _loginCommandController.listen((command) {
      login(command);
    });
  }

  Future initCommand() async {
    onStateAdd(true);
    onStateAdd(false);
  }

  PublishSubject<LoginState> _loginStateController = new PublishSubject();
  Observable<LoginState> get loginStateObservable => _loginStateController;
  Function(LoginState) get loginStateAdd => _loginStateController.sink.add;

  BehaviorSubject<LoginCommand> _loginCommandController = new BehaviorSubject();
  Observable<LoginCommand> get loginCommandObservable =>
      _loginCommandController;
  Function(LoginCommand) get loginCommandAdd =>
      _loginCommandController.sink.add;

  Future login(LoginCommand command) async {
    _loginStateController.add(LoginState.logging());
    onIsBusyAdd(true);
    if (command.shopUrl == null ||
        command.shopUrl == "" ||
        command.username == null ||
        command.username == "" ||
        command.password == null ||
        command.password == "") {
      _loginStateController.add(
          LoginState.error("Chưa nhập tên shop, tên đăng nhập hoặc mật khẩu"));
      onIsBusyAdd(false);
      return;
    }
    try {
      var loginResult = await _tposApi.setAuthentiacation(
          shopUrl: command.shopUrl,
          username: command.username,
          password: command.password);
      if (loginResult != null) {
        // save setting
        _settingService.shopUrl = command.shopUrl;
        _settingService.shopUsername = command.username;
        _settingService.shopAccessToken = loginResult.accessToken;
        _settingService.shopRefreshAccessToken = loginResult.refreshToken;
        _settingService.shopAccessTokenExpire = loginResult.expires;

        _loginStateController.add(LoginState.completed());
      }
    } on SocketException catch (e, s) {
      _log.severe("login", e, s);
      _loginStateController.add(LoginState.error("Không kết nối được sv"));
    } catch (e, s) {
      _log.severe("login", e, s);
      _loginStateController
          .add(LoginState.error(e.toString().replaceAll("Exception:", "")));
    }

    onIsBusyAdd(false);
  }

  @override
  void dispose() {
    _loginStateController.close();
    _loginCommandController.close();
    super.dispose();
  }
}

class LoginState {
  bool isLogging;
  bool isCompleted;
  bool isError;
  String message;

  LoginState.logging() {
    this.isLogging = true;
    this.isCompleted = false;
    this.isError = false;
    this.message = "";
  }
  LoginState.completed() {
    this.isLogging = false;
    this.isCompleted = true;
    this.isError = false;
    this.message = "";
  }
  LoginState.error(String errorMesssage) {
    this.isLogging = false;
    this.isCompleted = false;
    this.isError = true;
    this.message = errorMesssage;
  }

  LoginState({this.isLogging, this.isCompleted, this.isError, this.message});
}

class LoginCommand {
  String command;
  String shopUrl;
  String username;
  String password;
  String isSavePassword;

  LoginCommand(
      {this.command,
      this.shopUrl,
      this.username,
      this.password,
      this.isSavePassword});
}
