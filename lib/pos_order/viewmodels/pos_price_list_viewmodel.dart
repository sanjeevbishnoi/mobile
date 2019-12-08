import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosPriceListViewModel extends ViewModelBase {
  DialogService _dialog;
  IDatabaseFunction _dbFuction;
  PosPriceListViewModel({DialogService dialogService}) {
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();
  }

  List<PriceList> _priceLists = [];
  List<PriceList> get priceLists => _priceLists;
  set priceLists(List<PriceList> value) {
    _priceLists = value;
    notifyListeners();
  }

  Future<void> getPriceLists() async {
    priceLists = await _dbFuction.queryGetPriceLists();
  }
}
