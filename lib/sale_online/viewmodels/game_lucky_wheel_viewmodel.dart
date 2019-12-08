import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/models/FacebookWinner.dart';
import 'package:tpos_mobile/sale_online/services/print_service.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_post_summary_user.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class LuckyWheelViewModel extends ViewModel {
  //log
  final log = new Logger("LuckyWheelViewModel");
  ISettingService _setting;
  ITposApiService _tposApi;
  DialogService _dialog;
  PrintService _print;

  LuckyWheelViewModel(
      {ISettingService settingService,
      ITposApiService tposApi,
      PrintService printService,
      DialogService dialog}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _setting = settingService ?? locator<ISettingService>();
    _dialog = dialog ?? locator<DialogService>();
    _print = printService ?? locator<PrintService>();
  }

  String _postId;

  CRMTeam _crmTeam;

  /// Đang chơi
  bool isPlaying = false;

  /// Đang chuẩn bị
  bool isPrepaing = false;

  int get playerShareCount {
    if (_players == null || _players.length == 0) return 0;
    return _players.map((f) => f.countShare).reduce((p1, p2) => p1 + p2);
  }

  int get playerCommentCount {
    if (_players == null || _players.length == 0) return 0;
    return _players.map((f) => f.countComment).reduce((p1, p2) => p1 + p2);
  }

  static const String REFRESH_PLAYER_EVENT = "REFRESH_PLAYER_EVENT";

  /// Khởi tạo dữ liệu ban đầu và nhận tham số
  void init({
    @required String postId,
    @required String facebookUid,
    @required CRMTeam crmTeam,
  }) {
    assert(postId != null);
    assert(facebookUid != null);
    this._postId = postId;
  }

  SaleOnlineFacebookPostSummaryUser postSummary =
      new SaleOnlineFacebookPostSummaryUser();

  /// Danh sách người chơi được phép tham dự
  List<Users> _players;
  List<Users> get players => _players;
  Users _winPlayer;
  int get winPlayerIndex {
    if (_winPlayer != null) {
      return _players.indexOf(_winPlayer);
    } else
      return 0;
  }

  Users get winPlayer => _winPlayer;
  List<FacebookWinner> _facebookWinners = new List<FacebookWinner>();
  FacebookWinner facebookWinner = new FacebookWinner();
  List<FacebookWinner> get facebookWinners => _facebookWinners;
  BehaviorSubject<List<FacebookWinner>> _facebookWinnersController =
      new BehaviorSubject();

  Stream<List<FacebookWinner>> get facebookWinnersStream =>
      _facebookWinnersController.stream;

  BehaviorSubject<List<Users>> _playersController = new BehaviorSubject();

  Stream<List<Users>> get playersStream => _playersController.stream;

  List<int> allNumbers = [];
  List<Users> tempUsers;
  List<AvailableInsertPartners> _partner;

  /// Lấy danh sách toàn bộ người chơi
  Future<void> _fetchPlayers() async {
    postSummary = await _tposApi.getSaleOnlineFacebookPostSummaryUser(_postId);
    tempUsers = postSummary.users;
    _partner = postSummary.availableInsertPartners;
  }

  /// Lấy danh sách những người đã trúng thưởng trong quá khứ
  Future<void> _fetchFacebookWinners() async {
    _facebookWinners?.clear();
    var facebookWinners = await _tposApi.getFacebookWinner();
    if (facebookWinners != null) _facebookWinners.addAll(facebookWinners);
  }

  Future<void> printWin(String name, String uid,
      {String phone, String partnerCode}) async {
    try {
      await _print.printGame(
          name: name, uid: uid, phone: phone, partnerCode: partnerCode);
    } catch (e, s) {
      _dialog.showNotify(message: "In lỗi: ${e.toString()}");
      log.severe("", e, s);
    }
  }

  /// Lưu người thắng cuộc
  Future<void> updateFacebookWinner() async {
    try {
      if (_winPlayer != null) {
        facebookWinner.facebookName = _winPlayer.name;
//        facebookWinner.facebookUId = playerWin.uId;
        facebookWinner.facebookPostId = _postId;
        facebookWinner.facebookASUId = _winPlayer.id;
        //facebookWinner.dateCreated = DateTime.now();

        await _tposApi.updateFacebookWinner(facebookWinner);

        var partnerWin = await _tposApi.checkPartner(
            asuid: _winPlayer.id, crmTeamId: _crmTeam?.id);

        var customer;
        if (partnerWin != null && partnerWin.length > 0)
          customer = partnerWin?.first;

        _dialog.showNotify(message: "Đã lưu người trúng");
        await printWin(
          _winPlayer.name,
          _winPlayer.uId,
          phone: customer?.phone,
          partnerCode: customer?.ref,
        );
        await _fetchFacebookWinners();
        _dialog.showNotify(message: "Đã cập nhật lại danh sách người trúng");
      }
    } catch (ex, stack) {
      log.severe("loadPlayers fail", ex, stack);
      var dialogResult = await _dialog.showError(
          title: "Đã có lỗi xảy ra", error: ex, isRetry: true);

      if (dialogResult != null && dialogResult.type == DialogResultType.RETRY) {
        updateFacebookWinner();
      }
    }
  }

  /// Cập nhật lại danh sách người chơi phù hợp với cấu hình
  Future<void> _refreshPlayer() async {
    if (tempUsers == null) return;
    _players = tempUsers.where((f) {
      return (_setting.isShareGame && f.countShare > 0 ||
              !_setting.isShareGame) &&
          (_setting.isOrderGame && f.hasOrder || !_setting.isOrderGame) &&
          (_setting.isWinGame == false &&
                  !_facebookWinners.any((s) => s.facebookASUId == f.uId) ||
              _setting.isWinGame);
    }).toList();
  }

  void startGame() {
    // Tất cả vé tham dự
    // Lọc người thawgns gần đây
    var recentsWinners = _facebookWinners
        .where((f) => f.dateCreated
            .isAfter(DateTime.now().add(Duration(days: -_setting.days))))
        .toList();
    allNumbers = <int>[];
    int index = 0;
    for (int i = 0; i < _players.length; i++) {
      index = allNumbers.length;
      _players[i].numbers = <int>[index];
      if (_setting.settingGameIsIgroneRecentWinner) {
        // Đã thắng gần đây
        if (recentsWinners.any((f) => f.facebookUId == _players[i].uId)) {
          _players[i].numbers.add(index + 1);
          allNumbers.addAll(_players[i].numbers);
          // print("Nguoi choi: $i: ${_players[i].numbers}");
          continue;
        }
      }
      switch (_setting.isPriorGame) {
        case "comment":
          if (_players[i].countComment > 0) {
            _players[i].numbers.addAll(List.generate(
                _players[i].countComment, (genIndex) => genIndex + 1 + index));
            allNumbers.addAll(_players[i].numbers);
          }
          break;
        case "share":
          if (_players[i].countShare > 0) {
            _players[i].numbers.addAll(List.generate(
                _players[i].countShare, (genIndex) => genIndex + 1 + index));
            allNumbers.addAll(_players[i].numbers);
          }
          break;
        case "share_comment":
          _players[i].numbers.addAll(List.generate(
              _players[i].countComment + _players[i].countShare,
              (genIndex) => genIndex + 1 + index));
          allNumbers.addAll(_players[i].numbers);
          break;
        default:
          _players[i].numbers.add(index + 1);
          allNumbers.addAll(_players[i].numbers);
          break;
      }

      // print("Nguoi choi: $i: ${_players[i].numbers}");
    }

    if (allNumbers.length > 0) {
      var randomNumber = Random().nextInt(allNumbers.length);
      _winPlayer = players.firstWhere((f) => f.numbers.contains(randomNumber),
          orElse: () => null);
      //print(randomNumber);
    }
  }

  Future<void> initCommand() async {
    onStateAdd(true, message: "Đang tải dữ liệu...");
    try {
      // Tải dữ liệu
      await Future.wait([
        _fetchFacebookWinners(),
        _fetchPlayers(),
      ]);

      // Lọc người chơi theo cấu hình
      await _refreshPlayer();
      notifyListeners();
    } catch (e, s) {
      log.severe("initCommand", e, s);
      var dialogResult = await _dialog.showError(
        title: "Đã có lỗi xảy ra!",
        error: e,
        isRetry: true,
      );
      onStateAdd(false, message: "Đang tải dữ liệu...");
      if (dialogResult != null && dialogResult.type == DialogResultType.RETRY) {
        this.initCommand();
      }
    }
    onStateAdd(false, message: "Đang tải dữ liệu...");
    notifyListeners();
  }

  Future<void> refreshPlayer() async {
    print("refrsh palyers");
    try {
      await _refreshPlayer();
      onEventAdd(REFRESH_PLAYER_EVENT, null);
    } catch (e, s) {
      log.severe("refresh player", e, s);
      _dialog.showError(title: "Đã xảy ra lỗi!", error: e);
    }
  }

  @override
  void dispose() {
    _playersController?.close();
    _facebookWinnersController?.close();
    super.dispose();
  }
}
