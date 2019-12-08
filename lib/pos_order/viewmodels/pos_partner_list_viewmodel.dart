import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_helper.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosPartnerListViewModel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  IDatabaseFunction _dbFuction;
  PosPartnerListViewModel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();

    _keywordController
        .debounceTime(Duration(milliseconds: 500))
        .listen((keyword) {
      searchPartner();
    });
  }

  final dbHelper = DatabaseHelper.instance;

  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  String _keyword = "";
  String get keyword => _keyword;

  Future<void> setKeyword(String value) async {
    _keyword = value;
    _keywordController.add(value);
    //notifyListeners();
  }

  List<Partners> _searchPartners = [];
  List<Partners> _partners = [];
  List<Partners> get partners => _partners;
  set partners(List<Partners> value) {
    _partners = value;
    notifyListeners();
  }

  Future<void> getPartners() async {
    setState(true);
    partners = await _dbFuction.queryGetPartners();
    _searchPartners = partners;
    setState(false);
  }

  void searchPartner() {
    List<Partners> findPartner = [];
    if (_keyword == "") {
      partners = _searchPartners;
    } else {
      for (var i = 0; i < _searchPartners.length; i++) {
        if (_searchPartners[i]
            .name
            .toLowerCase()
            .contains(_keyword.toLowerCase())) {
          findPartner.add(_searchPartners[i]);
        }
      }
      partners = findPartner;
    }
  }
}
