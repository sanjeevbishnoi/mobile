import 'package:flutter/foundation.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/services/log_services/log_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/facebook_share_info.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class FacebookPostShareListViewModel extends ViewModel {
  ITposApiService _tposApi;
  String _facebookPostId;
  String _facebookUserOrPageId;
  FacebookPostShareListViewModel(
      {ITposApiService tposApi, LogService logService})
      : super(logService: logService) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  bool isAutoClose = false;

  void init(
      {@required String postId, @required String pageId, bool isAutoClose}) {
    assert(postId != null);
    assert(pageId != null);
    this._facebookPostId = postId;
    this._facebookUserOrPageId = pageId;
    this.isAutoClose = isAutoClose;

    _initCommand = new ViewModelCommand(
        name: "Init", executeFunction: (param) => _initCommandAction());

    _refreshCommand = new ViewModelCommand(
        name: "Refresh", executeFunction: (param) => _initCommandAction());
  }

  ViewModelCommand _initCommand;
  ViewModelCommand _refreshCommand;
  List<FacebookShareInfo> _facebookShares;
  List<FacebookShareCount> _facebookShareCounts;

  ViewModelCommand get initCommand => _initCommand;
  ViewModelCommand get refreshCommand => _refreshCommand;

  List<FacebookShareCount> get facebookShareCounts => _facebookShareCounts;
  int get shareCount => _facebookShares?.length ?? 0;
  int get userCount => _facebookShareCounts?.length ?? 0;
  Future<void> _initCommandAction() async {
    onStateAdd(true, message: "Đang tải dữ liệu...");
    try {
      await _loadShares();
    } catch (e, s) {
      logger.error("", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
    }
    notifyListeners();
    onStateAdd(false);
  }

  Future<void> _loadShares() async {
    _facebookShares = await _tposApi.getSharedFacebook(
        _facebookPostId, _facebookUserOrPageId,
        mapUid: isAutoClose);

    _facebookShareCounts = new List<FacebookShareCount>();
    _facebookShares.forEach(
      (value) {
        var exists = _facebookShareCounts.firstWhere(
            (f) => f.facebookUid == value.from.id,
            orElse: () => null);
        if (exists != null) {
          exists.count += 1;
          exists.details.add(value);
        } else {
          _facebookShareCounts.add(
            new FacebookShareCount(
              count: 1,
              avatarLink: value.from.pictureLink,
              name: value.from.name,
              facebookUid: value.from.id,
              details: <FacebookShareInfo>[value],
            ),
          );
        }
      },
    );

    _facebookShareCounts.sort((a, b) => a.count.compareTo(b.count));
    _facebookShareCounts = _facebookShareCounts.reversed.toList();
  }
}

class FacebookShareCount {
  String avatarLink;
  String name;
  String facebookUid;
  int count;
  List<FacebookShareInfo> details;

  FacebookShareCount(
      {this.avatarLink, this.name, this.facebookUid, this.count, this.details});
}
