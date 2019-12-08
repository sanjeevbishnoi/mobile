import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/services/remote_config_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';

class SaleOnlineFacebookChannelListViewModel extends ViewModel {
  IFacebookApiService _fbApi;
  ITposApiService _tposApi;
  ISettingService _setting;
  RemoteConfigService _remoteConfig;
  DialogService _dialog;
  Logger _log = new Logger("SaleOnlineFacebookChannelListViewModel");
  SaleOnlineFacebookChannelListViewModel(
      {IFacebookApiService fbApi,
      ITposApiService tposApi,
      ISettingService setting,
      RemoteConfigService remoteConfig,
      DialogService dialog}) {
    _fbApi = fbApi ?? locator<IFacebookApiService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
    _setting = setting ?? locator<ISettingService>();
    _remoteConfig = remoteConfig ?? locator<RemoteConfigService>();
    _dialog = dialog ?? locator<DialogService>();
    _initCommand =
        new ViewModelCommand(name: "Init", executeFunction: (param) => _init());

    _refreshCommand = new ViewModelCommand(
        name: "Refresh", executeFunction: (param) => _refresh());

    _loginFacebookCommand = new ViewModelCommand(
        name: "Loggin facebook",
        executeFunction: (param) => _loginFacebook(param));

    _deleteFacebookChannelCommand = new ViewModelCommand(
        name: "Delete facebook channel",
        executeFunction: (param) => _deleteFacebookChannel(param));

    _insertFacebookChannelCommand = new ViewModelCommand(
        name: "Insert facebook channel",
        executeFunction: (param) => _insertFacebookChannel(param));
    _insertFacebookPageChanelCommand = new ViewModelCommand(
        name: "Insert facebook page channel",
        executeFunction: (param) => _insertFacebookPageChannel(
            (param as List)[0], (param as List)[1], (param as List)[2]));

    _refreshTokenCommand = new ViewModelCommand(
        name: "Refresh facebook token",
        executeFunction: (param) => _refreshFacebookTokenCommandAction(param),
        visible: (param) =>
            this.isFacebookLoggined && this._loginedFacebookUser != null);

    _facebookLogin = new FacebookLogin();
  }

  List<CRMTeam> _crmTeams;
  FacebookUser _loginedFacebookUser;
  FacebookLogin _facebookLogin;

  ViewModelCommand _initCommand;
  ViewModelCommand _refreshCommand;
  ViewModelCommand _addPageCommand;
  ViewModelCommand _refreshTokenCommand;
  ViewModelCommand _loginFacebookCommand;
  ViewModelCommand _deleteFacebookChannelCommand;
  ViewModelCommand _insertFacebookChannelCommand;
  ViewModelCommand _insertFacebookPageChanelCommand;

  List<CRMTeam> get crmTeams => _crmTeams;
  ViewModelCommand get initCommand => _initCommand;
  ViewModelCommand get refreshCommand => _refreshCommand;
  ViewModelCommand get addPageCommand => _addPageCommand;
  ViewModelCommand get refreshTokenCommand => _refreshTokenCommand;
  ViewModelCommand get loginFacebookCommand => _loginFacebookCommand;
  ViewModelCommand get deleteFacebookChannelCommand =>
      _deleteFacebookChannelCommand;
  ViewModelCommand get insertFacebookChannelCommand =>
      _insertFacebookChannelCommand;
  ViewModelCommand get insertFacebookPageChannelCommand =>
      _insertFacebookPageChanelCommand;
  bool get isFacebookLoggined => _setting.facebookAccessToken != null;
  bool get isFacebookNotInCrmteams =>
      _crmTeams
              ?.where((f) => f.facebookASUserId == _loginedFacebookUser?.id)
              ?.length ==
          0 &&
      isFacebookLoggined;
  FacebookUser get loginedFacebookUser => _loginedFacebookUser;
  Future<void> _init() async {
    onStateAdd(true);
    try {
      await _refreshFacebookChannel();
      await _refreshFacebookLoginUser();
      _log.fine("init sale online facebook channle");
      notifyListeners();
    } catch (e, s) {
      _log.severe("init", e, s);
      _dialog.showError(error: e, isRetry: true).then(
        (result) {
          if (result != null && result.type == DialogResultType.RETRY) {
            _init();
          } else if (result != null && result.type == DialogResultType.GOBACK) {
            onEventAdd("GO_BACK", null);
          }
        },
      );
    }
    onStateAdd(false);
  }

  Future<void> _refresh() async {
    onStateAdd(true);
    try {
      await _refreshFacebookChannel();
      await _refreshFacebookLoginUser();
      notifyListeners();
    } catch (e, s) {
      _log.severe("init", e, s);
      onDialogMessageAdd(
          OldDialogMessage.error("", "", error: e, isRetryRequired: true));
    }
    onStateAdd(false);
  }

  /// Refresh Facebook channel
  Future<void> _refreshFacebookChannel() async {
    _crmTeams = await _tposApi.getCRMTeamAllFacebook();
  }

  Future<void> _refreshFacebookLoginUser() async {
    if (_setting.facebookAccessToken != null) {
      _loginedFacebookUser = await _fbApi.getFacebookUserInfo(
          accessToken: _setting.facebookAccessToken);
    }
  }

  Future<void> _tryRefreshFacebookLoginUser() async {
    try {
      await _refreshFacebookLoginUser();
      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
    }
  }

  Future<void> _loginFacebook(bool native) async {
    try {
      if (isFacebookLoggined) {
        await _logoutFacebook();
        return;
      }
      await _logoutFacebook();

      _facebookLogin = new FacebookLogin();
      if (native == false) {
        _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      } else {
        _facebookLogin.loginBehavior = FacebookLoginBehavior.nativeOnly;
      }
      var result = await _facebookLogin.logIn(
        _remoteConfig.facebookOption.permissions,
      );

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          _setting.facebookAccessToken = result.accessToken.token;
          _tryRefreshFacebookLoginUser();
          notifyListeners();
          break;
        case FacebookLoginStatus.cancelledByUser:
          break;
        case FacebookLoginStatus.error:
          onDialogMessageAdd(OldDialogMessage.error(
              "Đăng nhập facebook thất bại", result.errorMessage));
          break;
      }

      //_facebookLogin.logOut();
//      var result1 = await _facebookLogin.loginWithPublishPermissions([
//        "public_profile",
//        "publish_video",
//        "publish_pages",
//        "ads_management"
//      ]);
    } catch (e, s) {
      _log.severe("login facebook", e, s);
      onDialogMessageAdd(
          OldDialogMessage.error("Đã có lỗi xảy ra", "", error: e));
    }
  }

  Future<void> _insertFacebookChannel([String name]) async {
    assert(this.loginedFacebookUser != null);
    assert(_setting.facebookAccessToken != null);

    if (this._loginedFacebookUser == null) {
      return;
    }
    onStateAdd(true, message: "Đang lưu...");

    try {
      //Check condition
      var checkResult = await _tposApi.checkSaleOnlineFacebookAccount(
        facebookId: _loginedFacebookUser.id,
        facebookName: _loginedFacebookUser.name,
        facebookAvatar: _loginedFacebookUser.pictureLink,
        token: _setting.facebookAccessToken,
      );

      if (checkResult) {
        var result = await _tposApi.insertCRMTeam(
          new CRMTeam(
            id: null,
            name: _loginedFacebookUser.name,
            active: true,
            type: "Facebook",
            // facebookUserId: _loginedFacebookUser.id,
            facebookTypeId: "User",
            facebookUserAvatar: _loginedFacebookUser.pictureLink,
            facebookUserToken: _setting.facebookAccessToken,
            facebookASUserId: _loginedFacebookUser.id,
          ),
        );

        if (result != null) {
          await _refreshFacebookChannel();
          onDialogMessageAdd(
            OldDialogMessage.flashMessage("Kênh facebook ${result.name}"),
          );
        }
      } else {
        onDialogMessageAdd(
          OldDialogMessage.info(
              "Kênh ${_loginedFacebookUser.name} đã tồn tại trong hệ thống."),
        );
      }
    } catch (e, s) {
      _log.severe("insert facebook channel", e, s);
      _dialog.showError(error: e);
    }
    onStateAdd(false);
    notifyListeners();
  }

  Future<void> _insertFacebookPageChannel(
      FacebookAccount page, String name, CRMTeam crmTeam) async {
    onStateAdd(true);
    try {
      var checkResult = await _tposApi.checkSaleOnlineFacebookAccount(
        facebookId: page.id,
        facebookName: page.name,
        facebookAvatar: page.pictureString,
        token: page.accessToken,
      );

      if (checkResult) {
        var result = await _tposApi.insertCRMTeam(
          new CRMTeam(
            id: null,
            name: name ?? page.name,
            active: true,
            type: "Facebook",
            // facebookUserId: _loginedFacebookUser.id,
            facebookASUserId: crmTeam.facebookASUserId,
            parentId: crmTeam.id,
            facebookTypeId: "Page",
            facebookPageId: page.id,
            facebookPageLogo: page.pictureString,
            facebookPageName: page.name,
            facebookPageToken: page.accessToken,
            facebookPageCover: page.pictureString,
          ),
        );

        if (result != null) {
          await _refreshFacebookChannel();
          onDialogMessageAdd(
            OldDialogMessage.flashMessage("Kênh facebook ${result.name}"),
          );
        }
      } else {
        onDialogMessageAdd(
          OldDialogMessage.info(
              "Kênh ${_loginedFacebookUser.name} đã tồn tại trong hệ thống."),
        );
      }
    } catch (e, s) {
      _log.severe("insert facebook page channle", e, s);
      _dialog.showError(error: e);
    }

    onStateAdd(false);
    notifyListeners();
  }

  Future<void> _deleteFacebookChannel(CRMTeam crmTeam) async {
    assert(crmTeam != null);
    onStateAdd(true, message: "Đang xóa...");
    try {
      await _tposApi.deleteCRMTeam(crmTeam.id);
      onDialogMessageAdd(
          OldDialogMessage.flashMessage("Đã xóa kênh ${crmTeam.name}"));
      _refresh();

      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
      onDialogMessageAdd(
        OldDialogMessage.error(
          "",
          e.toString(),
          error: e,
        ),
      );
    }
    onStateAdd(false);
  }

  Future<void> _refreshFacebookTokenCommandAction(CRMTeam crmTeam) async {
    assert(this.isFacebookLoggined);
    assert(this._loginedFacebookUser != null);

    onStateAdd(true, message: "Đang cập nhật...");
    try {
      if (crmTeam.facebookTypeId == "User") {
        await _tposApi.checkSaleOnlineFacebookAccount(
            token: _setting.facebookAccessToken,
            facebookId: _loginedFacebookUser.id,
            facebookName: _loginedFacebookUser.name,
            facebookAvatar: _loginedFacebookUser.pictureLink);
        onDialogMessageAdd(OldDialogMessage.flashMessage(
            "Đã làm mới đăng nhập cho ${crmTeam.name}"));
      } else if (crmTeam.facebookTypeId == "Page") {
        //Get page info
        var pages = await _fbApi.getFacebookAccount(
            accessToken: _setting.facebookAccessToken);
        if (pages != null) {
          var page = pages.firstWhere((f) => f.id == crmTeam.facebookPageId,
              orElse: () => null);
          if (page != null) {
            // update
            await _tposApi.editSaleChannelById(
              crmTeam: new CRMTeam(
                facebookPageLogo: page.pictureString,
                id: crmTeam.id,
                facebookPageToken: page.accessToken,
              ),
            );
            onDialogMessageAdd(OldDialogMessage.flashMessage(
                "Đã làm mới đăng nhập cho ${crmTeam.name}"));
          } else {
            throw new Exception(
                "Không tìm thấy Page này trong tài khoản người dùng");
          }
        }
      }

      // Tải lại
      initCommand.execute(null);
    } catch (e, s) {
      _log.severe("refresh facebook token", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
    }
    onStateAdd(false);
  }

  Future<void> _logoutFacebook() async {
    _setting.facebookAccessToken = null;
    _loginedFacebookUser = null;
    await _facebookLogin.logOut();
    notifyListeners();
  }
}
