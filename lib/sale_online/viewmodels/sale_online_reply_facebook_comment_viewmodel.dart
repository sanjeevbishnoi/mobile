import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';

import 'new_facebook_post_comment_viewmodel.dart';

class SaleOnlineReplyFacebookCommentViewModel extends ViewModel {
  ITposApiService _tposApi;
  IFacebookApiService _fbApi;
  String _accessToken;
  CommentItemModel _comment;
  String _pageId;
  CRMTeam _crmTeam;
  String _postId;
  bool _isSendMessage;
  Function onSendCompleted;
  Logger _log = new Logger("SaleOnlineReplyFacebookCommentViewModel");
  DialogService _dialog;

  SaleOnlineReplyFacebookCommentViewModel(
      {ITposApiService tposApi, IFacebookApiService fbApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    _fbApi = fbApi ?? locator<IFacebookApiService>();
    _dialog = locator<DialogService>();
    _initCommand = new ViewModelCommand(
      name: "init command",
      executeFunction: (param) => _init(),
      canExecute: (param) => isBusy == false,
    );

    _replyCommand = new ViewModelCommand(
      name: "reply command",
      executeFunction: (param) => _actionSend(param),
      canExecute: (param) => isBusy == false,
    );
    _addNewCommand = new ViewModelCommand(
      name: "add command",
      executeFunction: (param) => _add(param),
      canExecute: (param) => isBusy == false,
    );
  }

  List<MailTemplate> _mailTemplates;
  ViewModelCommand _replyCommand;
  ViewModelCommand _addNewCommand;

  var _mailTemplatesSubject = new BehaviorSubject<List<MailTemplate>>();

  ViewModelCommand get initCommand => _initCommand;
  ViewModelCommand get replyCommand => _replyCommand;
  ViewModelCommand get addNewCommand => _addNewCommand;

  List<MailTemplate> get mailTemplates => _mailTemplates;
  Stream<List<MailTemplate>> get mailTemplateStream =>
      _mailTemplatesSubject.stream;
  ViewModelCommand _initCommand;
  CommentItemModel get comment => _comment;

  void init(
      {@required String accessToken,
      @required CommentItemModel comment,
      @required String pageId,
      @required bool isSendMessage,
      @required CRMTeam crmTeam,
      @required postId}) {
    assert(accessToken != null);
    assert(comment != null);
    assert(pageId != null && pageId != "");
    assert(crmTeam != null);
    assert(postId != null);

    this._accessToken = accessToken;
    this._comment = comment;
    this._pageId = pageId;
    this._isSendMessage = isSendMessage;
    this._crmTeam = crmTeam;
    this._postId = postId;
  }

  Future<void> _init() async {
    try {
      onStateAdd(true);
      _mailTemplates = await _tposApi.getMailTemplates();
      if (!_mailTemplatesSubject.isClosed)
        _mailTemplatesSubject.add(_mailTemplates);
      notifyListeners();
    } catch (e, s) {
      _log.severe("init mail template", e, s);
    }
    onStateAdd(false);
  }

  Future<void> _actionSend(String message) async {
    if (_isSendMessage) {
      return await _sendMessage(message);
    } else {
      return await _reply(message);
    }
  }

  Future<bool> _reply(String mesasge) async {
    try {
      String id = await _fbApi.replyPageComment(
          message: mesasge,
          accessToken: this._accessToken,
          commentId: this._comment.facebookComment.id);
      return (id != null);
    } catch (e, s) {
      _log.severe("reply comment", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", e.toString()));
      return false;
    }
  }

  Future<void> _sendMessage(String message) async {
    try {
      if (_crmTeam.facebookTypeId == "User") {
//        String uid = await _tposApi.getFacebookPSUID(
//            asuid: comment.facebookComment.from.id, pageId: this._pageId);
//        urlLauch("fb://messaging/$uid");
        _dialog.showNotify(message: "Gửi inbox chỉ hỗ trợ trên PAGE");
        return;
      }

      await _tposApi.sendFacebookPageInbox(
          message: message,
          comment: _comment.facebookComment,
          cmrTeamid: _crmTeam.id,
          facebookPostId: _postId);

      onDialogMessageAdd(OldDialogMessage.flashMessage(
          "Đã gửi tin nhắn tới ${comment.facebookComment.from.name}"));
    } catch (e, s) {
      _log.severe("sendMessage", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "",
          error: e, stackTrade: s, title: "Không gửi được!"));
    }
  }

  Future<void> _add(String message) async {
    try {
      await _tposApi.addMailTemplate(
        new MailTemplate(name: message, bodyPlain: message, typeId: "General"),
      );

      onDialogMessageAdd(OldDialogMessage.flashMessage(
          "Đã thêm mẫu '$message' vào mẫu tin nhắn"));
    } catch (e, s) {
      _log.severe("add new message", e, s);
      onDialogMessageAdd(
        OldDialogMessage.error(
          "",
          e.toString(),
        ),
      );
    }
  }

  void search(String keyword) {
    if (!_mailTemplatesSubject.isClosed) {
      if (keyword == null || keyword == "") {
        _mailTemplatesSubject.add(_mailTemplates);
        return;
      }

      _mailTemplatesSubject.add(
        _mailTemplates
            ?.where(
              (f) => (removeVietnameseMark(f.bodyPlain.toLowerCase()).contains(
                removeVietnameseMark(
                  keyword.toLowerCase(),
                ),
              )),
            )
            ?.toList(),
      );
    }
  }

  @override
  void dispose() {
    this._mailTemplatesSubject.close();
    super.dispose();
  }
}
