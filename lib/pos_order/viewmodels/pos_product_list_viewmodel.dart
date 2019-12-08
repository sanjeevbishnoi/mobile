import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_helper.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosProductListViewmodel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  IDatabaseFunction _dbFuction;
  PosProductListViewmodel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();

    _keywordController
        .debounceTime(Duration(milliseconds: 500))
        .listen((keyword) {
      searchProduct();
    });
  }

  String filterStack = "1";
  int countProduct = 0;
  final dbHelper = DatabaseHelper.instance;

  PriceList _priceList = PriceList();
  List<Lines> _productCarts = [];
  List<dynamic> _filerPrices = [];

  List<CartProduct> _searchProducts = [];
  List<CartProduct> _products = [];
  List<CartProduct> get products => _products;
  set products(List<CartProduct> value) {
    _products = value;
    notifyListeners();
  }

  List<dynamic> get filerPrices => _filerPrices;
  set filerPrices(List<dynamic> value) {
    _filerPrices = value;
    notifyListeners();
  }

  PriceList get priceList => _priceList;
  set priceList(PriceList value) {
    _priceList = value;
    notifyListeners();
  }

  BehaviorSubject<String> _keywordController = new BehaviorSubject();
  String _keyword = "";
  String get keyword => _keyword;

  Future<void> setKeyword(String value) async {
    _keyword = value;
    _keywordController.add(value);
    //notifyListeners();
  }

  Future<void> getProducts() async {
    setState(true);
    try {
      products = await _dbFuction.queryProductAllRows();
      _searchProducts = products;
    } catch (e) {}
    setState(false);
  }

  void searchProduct() {
    List<CartProduct> findProduct = [];
    setState(true);
    if (_keyword == "") {
      products = _searchProducts;
    } else {
      for (var i = 0; i < _searchProducts.length; i++) {
        if (_searchProducts[i]
            .name
            .toLowerCase()
            .contains(_keyword.toLowerCase())) {
          findProduct.add(_searchProducts[i]);
        }
      }
      products = findProduct;
    }
    setState(false);
  }

  Future<void> insertProductForCart(String position) async {
    for (var i = 0; i < _productCarts.length; i++) {
      List<Lines> lstProduct = await _dbFuction.queryGetProductWithID(
          position, _productCarts[i].productId);
      if (lstProduct.length == 0) {
        await _dbFuction.insertProductCart(_productCarts[i]);
      } else {
        _productCarts[i].id = lstProduct[0].id;
        _productCarts[i].qty = _productCarts[i].qty + lstProduct[0].qty;
        await _dbFuction.updateProductCart(_productCarts[i]);
      }
    }
  }

  Future<void> filterListPrice(int id) async {
    setState(true, message: "Đang tải..");
    try {
      var result = await _tposApi.exeListPrice("$id");
      if (result != null) {
        filerPrices = result;
      }
      setState(false);
    } catch (e, s) {
      logger.error("handlePaymentFail", e, s);
      _dialog.showError(error: e);
    }
  }

  void incrementQtyProduct(
      CartProduct cartProduct, int index, String position) {
    products[index].qty++;

    Lines line = Lines();
    line.discount = 0;
    line.discountType = "percent";
    line.note = "";
    line.priceUnit = cartProduct.price;
    line.productId = cartProduct.id;
    line.qty = cartProduct.qty;
    line.uomId = 1;
    line.productName = cartProduct.nameGet;
    line.tb_cart_position = position;

    if (_productCarts.length > 0) {
      for (var i = 0; i < _productCarts.length; i++) {
        if (_productCarts[i].productId == line.productId) {
          _productCarts.removeAt(i);
        }
      }
      _productCarts.add(line);
    } else {
      _productCarts.add(line);
    }

    notifyListeners();
  }

  void filterBanChay() {
    List<CartProduct> _stackProducts = [];
    _stackProducts = products;

    for (var i = 0; i < _stackProducts.length - 1; i++) {
      for (var j = i + 1; j < _stackProducts.length; j++) {
        if (_stackProducts[i].posSalesCount < _stackProducts[j].posSalesCount) {
          CartProduct product = CartProduct();
          product = _stackProducts[j];
          _stackProducts[j] = _stackProducts[i];
          _stackProducts[i] = product;
        }
      }
    }
    products = _stackProducts;
  }

  void filterName() {
    List<CartProduct> _stackProducts = [];
    _stackProducts = products;
    _stackProducts
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    products = _stackProducts;
  }

  void filterPrice() {
    print("${filerPrices.length} - ${_products.length}");
    for (var i = 0; i < filerPrices.length; i++) {
      for (var j = 0; j < _products.length; j++) {
        if (filerPrices[i].key ==
            (_products[j].id.toString() +
                "_" +
                products[j].factor.floor().toString())) {
          products[j].price = filerPrices[i].value;
          break;
        }
      }
    }
    notifyListeners();
  }

  void changePositionStack(String value) {
    filterStack = value;
    notifyListeners();
  }

  void handleFilter() async {
    if (filterStack == "2") {
      filterBanChay();
    } else if (filterStack == "3") {
      filterName();
    } else {
      getProducts();
    }
    if (priceList.id != null) {
      await filterListPrice(priceList.id);
      filterPrice();
    }
  }

  void updatePriceList(PriceList value) {
    priceList = value;
  }

  int countFilter() {
    int count = 0;
    if (filterStack != "1") {
      count++;
    }
    if (priceList.name != null && priceList.id != 1) {
      count++;
    }
    return count;
  }

  void resetFilter() {
    filterStack = "1";
    priceList = PriceList();
    notifyListeners();
  }
}
