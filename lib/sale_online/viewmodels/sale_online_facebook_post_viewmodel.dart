/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:53 AM
 *
 */

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/facebook_apis/facebook_api.dart';
import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_facebook_comment.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_facebook_from.dart';
import 'package:tpos_mobile/src/tpos_apis/models/tpos_facebook_post.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

class SaleOnlineFacebookPostViewModel extends ViewModel
    implements ViewModelBase {
  //log
  final log = new Logger("SaleOnlineFacebookPostViewModel");
  IFacebookApiService _fbApi;
  ITposApiService _tposApi;
  CRMTeam _crmTeam;
  SaleOnlineFacebookPostViewModel(
      {IFacebookApiService fbApi, ITposApiService tposApi}) {
    _fbApi = fbApi ?? locator<IFacebookApiService>();
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  //Facebook Post Type
  FacebookPostType _postType = FacebookPostType.all;
  FacebookPostType get postType => _postType;

  CRMTeam get crmTeam => _crmTeam;
  String get _accessToken => _crmTeam.facebookTypeId == "User"
      ? _crmTeam.facebookUserToken
      : _crmTeam.facebookTypeId == "Page"
          ? _crmTeam.facebookPageToken
          : _crmTeam.facebookPageToken;
  String get accessToken => _accessToken;

  String get _userOrPageId => _crmTeam.facebookTypeId == "User"
      ? _crmTeam.facebookASUserId
      : _crmTeam.facebookTypeId == "Page"
          ? _crmTeam.facebookPageId
          : _crmTeam.facebookPageId;

  BehaviorSubject<FacebookPostType> _postTypeController = new BehaviorSubject();
  Stream<FacebookPostType> get postTypeStream => _postTypeController.stream;

  set postType(FacebookPostType value) {
    _postType = value;
    if (!_postTypeController.isClosed) _postTypeController.add(value);
  }

  List<FacebookAccount> _facebookAccounts = new List<FacebookAccount>();
  FacebookListPaging get facebookPostPaging => _facebookPostPaging;
  FacebookListPaging _facebookPostPaging;
  //FacebookPosts
  List<FacebookPost> _facebookPosts = new List<FacebookPost>();
  List<FacebookPost> get facebookPosts => _facebookPosts;

  BehaviorSubject<List<FacebookPost>> _facebookPostsController =
      new BehaviorSubject();
  Stream<List<FacebookPost>> get facebookPostsStream =>
      _facebookPostsController.stream;

  // isLoadingMoreFacebookPost
  bool _isLoadingMoreFacebookPost = false;

  bool get isLoadingMoreFacebookPost => _isLoadingMoreFacebookPost;
  set isLoadingMoreFacebookPost(bool value) {
    _isLoadingMoreFacebookPost = value;
    if (!_isLoadingMoreFacebookPostController.isClosed)
      _isLoadingMoreFacebookPostController.add(value);
  }

  BehaviorSubject<bool> _isLoadingMoreFacebookPostController =
      new BehaviorSubject();
  Stream<bool> get isLoadingMoreFacebookPostStream =>
      _isLoadingMoreFacebookPostController.stream;

  // isLoadingFacebookPost
  bool _isLoadingFacebookPost = false;
  bool get isLoadingFacebookPost => _isLoadingFacebookPost;

  set isLoadingFacebookPost(bool value) {
    _isLoadingFacebookPost = value;
    if (!_isLoadingFacebookPostController.isClosed)
      _isLoadingFacebookPostController.sink.add(_isLoadingFacebookPost);
  }

  BehaviorSubject<bool> _isLoadingFacebookPostController =
      new BehaviorSubject();
  Stream<bool> get isLoadingFacebookPostStream =>
      _isLoadingFacebookPostController.stream;
  //
  bool get isFacebookLogined => _isFacebookLogined;
  bool _isFacebookLogined;

  bool isBusy = false;

  bool isOnlyShowPostHasComment = false;
  List<FacebookAccount> get facebookAccounts => _facebookAccounts;

  Future<void> init({
    @required CRMTeam crmTeam,
  }) async {
    this._crmTeam = crmTeam;
    initCommand();
  }

  /// Gọi sau khi khởi tạo
  Future initCommand() async {
    try {
      await refreshFacebookPost();
      onPropertyChanged("");
    } catch (e, s) {
      log.severe("initCommand", e, s);
      onDialogMessageAdd(OldDialogMessage.error(
          "Tải danh sách bài đăng thất bại", e.toString()));
    }
    onStateAdd(false);
  }

  /// Gọi để tải thêm danh sách
  Future loadMoreFacebookPostCommand() async {
    await loadFacebookPost();
  }

  /// Lây danh sách bài đăng/ video
  Future refreshFacebookPost() async {
    isBusy = true;
    isLoadingFacebookPost = true;
    facebookPosts.clear();
    _facebookPostPaging = null;
    try {
      var facebookPostWithPaging = await _fbApi.getFacebookPostWithPaging(
        pageId: _userOrPageId,
        accessToken: _accessToken,
      );

      if (facebookPostWithPaging.error == null) {
        var itemsWillAdd = facebookPostWithPaging.data.where(
          (FacebookPost post) {
            return (isOnlyShowPostHasComment && post.totalComment >= 10 ||
                    isOnlyShowPostHasComment == false) &&
                (postType != FacebookPostType.all &&
                        post.type == postType.toString().split(".")[1] ||
                    postType == FacebookPostType.all);
          },
        ).toList();

        mapLiveStatus(itemsWillAdd);

        _facebookPosts.addAll(itemsWillAdd);
        if (!_facebookPostsController.isClosed)
          _facebookPostsController.sink.add(_facebookPosts);

        mapLiveCampaignWithFacebookPost(itemsWillAdd);
        this._facebookPostPaging = facebookPostWithPaging.paging;
      } else {
        String message = facebookPostWithPaging.error.message;
        if (facebookPostWithPaging.error.type == "OAuthException") {
          message = "$message \n\n Vui lòng làm mới token.";
        }

        if (_facebookPostsController.isClosed == false) {
          this._facebookPostsController.addError(message);
        }
      }
    } catch (ex, stack) {
      log.severe("refreshFacebookPost fail", ex, stack);
      if (_facebookPostsController.isClosed == false)
        this._facebookPostsController.addError("Lỗi facebook", stack);
    }
    isLoadingFacebookPost = false;
    isBusy = false;
  }

  Future mapLiveStatus(List<FacebookPost> posts) async {
    try {
      if (posts != null) {
        var ids = posts.where((s) => s.type == "video").map((f) {
          return f.id.split("_")[1];
        }).toList();
        var batch =
            await _fbApi.getLiveVideoBatch(ids, _crmTeam.userOrPageToken);

        for (int i = 0; i < ids.length; i++) {
          var rs = batch[i];
          if (rs.code == 200) {
            var live = LiveVideo.fromJson(jsonDecode(rs.body));
            var post = posts.firstWhere((f) => f.id.contains(ids[i]),
                orElse: () => null);
            post?.isLive = live.liveStatus == "LIVE";
            post?.isVideo = live.liveStatus == "VOD";
          }
        }
      }
    } catch (e, s) {
      log.severe("batch", e, s);
    }

    onPropertyChanged("");
  }

  /// Lấy thêm danh sách bài đăng video
  Future loadFacebookPost() async {
    isBusy = true;
    if (_facebookPostPaging == null) return;
    if (_facebookPostPaging.next == null) return;
    if (_isLoadingMoreFacebookPost == true) return;
    try {
      isLoadingMoreFacebookPost = true;
      var facebookPostWithPaging = await _fbApi.getFacebookPostWithPaging(
        pageId: this._userOrPageId,
        accessToken: _accessToken,
        paging: this._facebookPostPaging,
      );

      if (facebookPostWithPaging != null &&
          facebookPostWithPaging.data != null) {
        var itemsWillAdd = facebookPostWithPaging.data.where(
          (FacebookPost post) {
            return isOnlyShowPostHasComment && (post.totalComment ?? 0) >= 10 ||
                isOnlyShowPostHasComment == false;
          },
        ).toList();

        mapLiveStatus(itemsWillAdd);
        _facebookPosts.addAll(itemsWillAdd);
        mapLiveCampaignWithFacebookPost(itemsWillAdd);
        if (_facebookPostsController.isClosed == false)
          _facebookPostsController.add(_facebookPosts);
        this._facebookPostPaging = facebookPostWithPaging.paging;
      } else {
        if (facebookPostWithPaging.error != null) {
          String message = facebookPostWithPaging.error.message;
          if (facebookPostWithPaging.error.type == "OAuthException") {
            String errorMessage =
                "$message \n\n Vui lòng kiểm tra đăng nhập facebook?";
          }

          onDialogMessageAdd(new OldDialogMessage.error("", message));
        }
      }
    } catch (ex, stackTrade) {
      log.severe("loadFacebookPost fail", ex, stackTrade);
    }

    isLoadingMoreFacebookPost = false;
    isBusy = false;
  }

  Future<void> mapLiveCampaignWithFacebookPost(
      List<FacebookPost> facebookPosts) async {
    var savedPosts = await _tposApi.getSavedFacebookPost(
        this._userOrPageId, facebookPosts.map((f) => f.id).toList().toList());

    if (savedPosts != null && savedPosts.length >= 0) {
      savedPosts.forEach((savedPost) {
        var facebookPost = facebookPosts.firstWhere((f) => f.id == savedPost.id,
            orElse: () => null);

        if (facebookPost != null) {
          facebookPost.liveCampaignId = savedPost.liveCampaignId;
          facebookPost.liveCampaignName = savedPost.liveCampaignName;
          facebookPost.isSave = true;
        }
      });
    }

    onPropertyChanged("");
  }

  // Lưu bình luận

  Future<bool> saveComment(FacebookPost post) async {
    onStateAdd(true, message: "Đang lưu...");
    TposFacebookPost fbPost =
        new TposFacebookPost(comment: new List<TposFacebookComment>());
    // Get all comment
    FacebookListPaging paging;
    List<FacebookComment> lastFetchResults;

    var result = await _fbApi.fetchCommentWithPaging(
        postId: post.id, accessToken: _accessToken);
    paging = result.paging;
    lastFetchResults = result.data;

    result.data.forEach(
      (f) {
        fbPost.comment.add(
          new TposFacebookComment(
              id: f.id,
              message: f.message,
              from: new TposFacebookFrom(
                  id: f.from.id,
                  picture: f.from.pictureLink,
                  name: f.from.name),
              createdTime: f.createdTime,
              createdTimeConverted: f.createdTimeConverted),
        );
      },
    );

    while (paging != null &&
        paging.next != null &&
        lastFetchResults != null &&
        lastFetchResults.length > 0) {
      try {
        var result =
            await _fbApi.fetchMoreCommentWithPaging(paging, accessToken);
        paging = result.paging;
        lastFetchResults = result.data;
        result.data.forEach(
          (f) {
            fbPost.comment.add(
              new TposFacebookComment(
                  id: f.id,
                  message: f.message,
                  from: new TposFacebookFrom(
                      id: f.from.id,
                      picture: f.from.pictureLink,
                      name: f.from.name),
                  createdTime: f.createdTime,
                  createdTimeConverted: f.createdTimeConverted),
            );
          },
        );
      } catch (e, s) {
        log.severe("", e, s);
      }
    }

    // save comment
    fbPost.createdTime = post.createdTime;
    fbPost.from = TposFacebookFrom(
        id: post.from.id, name: post.from.name, picture: post.from.pictureLink);
    fbPost.id = post.id;
    fbPost.message = post.message;
    fbPost.story = post.story;
    fbPost.picture = post.picture;

    try {
      await _tposApi.insertFacebookPostComment([fbPost], _crmTeam.id);
      onStateAdd(false);
      return true;
    } catch (e, s) {
      log.severe("save comment", e, s);
      onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
    }
    onStateAdd(false);
    return false;
  }

  @override
  void dispose() {
    super.dispose();
    _postTypeController.close();
    _facebookPostsController.close();
    _isLoadingFacebookPostController.close();
    _isLoadingMoreFacebookPostController.close();
  }
}
