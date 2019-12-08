import 'package:sqflite/sqlite_api.dart';
import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/company.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/models/state_cart.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';

import 'database_helper.dart';

abstract class IDatabaseFunction {
  // insert
  Future<int> insertCart(StateCart stateCart);
  Future<int> insertProduct(CartProduct product);
  Future<int> insertProductCart(Lines line);
  Future<int> insertPartner(Partners partner);
  Future<int> insertPriceList(PriceList priceList);
  Future<int> insertAccountJournals(AccountJournal accountJournal);
  Future<int> insertSession(Session session);
  Future<int> insertCompany(Companies company);
  Future<int> insertPayment(Payment payment);
  Future<int> insertStatementIds(StatementIds statementIds);

  // query get rows
  Future<List<StateCart>> queryAllRowsCart();
  Future<List<StateCart>> queryCartByPosition(String position);
  Future<List<CartProduct>> queryProductAllRows();
  Future<List<Lines>> queryGetProductsForCart(String positionCart);
  Future<List<Lines>> queryGetProductWithID(String positionCart, int productId);
  Future<List<Partners>> queryGetPartners();
  Future<List<PriceList>> queryGetPriceLists();
  Future<List<AccountJournal>> queryGetAccountJournals();
  Future<List<Session>> querySessions();
  Future<List<Companies>> queryCompanys();
  Future<List<Payment>> queryPayments();
  Future<List<StatementIds>> queryStatementIds(String position);

  // delete
  Future<int> deleteCart(String position);
  Future<int> deleteProductCart(Lines line);
  Future<int> deletePayments();

  // update
  Future<int> updateCart(StateCart cart);
  Future<int> updateProductCart(Lines line);
  Future<int> updatePartner(Partners partner);
  Future<int> updateSession(Session session);
}

class DatabaseFunction implements IDatabaseFunction {
  // inserted row.
  Future<int> insertCart(StateCart stateCart) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbCart, stateCart.toJson());
  }

  // insert product
  Future<int> insertProduct(CartProduct product) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbProduct, product.toJson());
  }

  // insert product for cart
  Future<int> insertProductCart(Lines line) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbPaymentLines, line.toJson());
  }

  // insert partner
  Future<int> insertPartner(Partners partner) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbPartner, partner.toJson());
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<StateCart>> queryAllRowsCart() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbCart);

    List<StateCart> list = res.isNotEmpty
        ? res.map((val) => StateCart.fromJson(val)).toList()
        : [];
    return list;
  }

  Future<List<CartProduct>> queryProductAllRows() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbProduct);

    List<CartProduct> list = res.isNotEmpty
        ? res.map((val) => CartProduct.fromJson(val)).toList()
        : [];
    return list;
  }

  Future<List<Lines>> queryGetProductsForCart(String positionCart) async {
    Database db = await DatabaseHelper.instance.database;
    var result = await db.query(DatabaseHelper.tbPaymentLines,
        where: '${DatabaseHelper.columnPosition} = ?',
        whereArgs: [positionCart]);
    List<Lines> lines = result.isNotEmpty
        ? result.map((value) => Lines.fromJson(value)).toList()
        : [];
    return lines;
  }

  Future<List<Lines>> queryGetProductWithID(
      String positionCart, int productId) async {
    Database db = await DatabaseHelper.instance.database;
    var result = await db.query(DatabaseHelper.tbPaymentLines,
        where:
            '${DatabaseHelper.tbPaymentLinesProductId} = ? and ${DatabaseHelper.tbPaymentLinesTbCartPosition} = ?',
        whereArgs: [productId, positionCart]);
    List<Lines> lines = result.isNotEmpty
        ? result.map((value) => Lines.fromJson(value)).toList()
        : [];
    return lines;
  }

  Future<List<Partners>> queryGetPartners() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbPartner);
    List<Partners> partners = res.isNotEmpty
        ? res.map((value) => Partners.fromJson(value)).toList()
        : [];
    return partners;
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> deleteCart(String position) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tbCart,
        where: '${DatabaseHelper.columnPosition} = ?', whereArgs: [position]);
  }

  // Để xóa tất cả sản phẩm trong 1 giỏ hàng
  Future<int> deleteProductCart(Lines line) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tbPaymentLines,
        where:
            '${DatabaseHelper.tbPaymentLinesTbCartPosition} = ?  and ${DatabaseHelper.tbPaymentLinesProductId} = ? and ${DatabaseHelper.tbPaymentLinesId} = ?',
        whereArgs: [line.tb_cart_position, line.productId, line.id]);
  }

  //update
  Future<int> updateCart(StateCart cart) async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.update(DatabaseHelper.tbCart, cart.toJson(),
        where: '${DatabaseHelper.tbPaymentLinesTbCartPosition} = ?',
        whereArgs: [cart.position]);
    return res;
  }

  Future<int> updateProductCart(Lines line) async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.update(DatabaseHelper.tbPaymentLines, line.toJson(),
        where:
            '${DatabaseHelper.tbPaymentLinesTbCartPosition} = ? and ${DatabaseHelper.tbPaymentLinesProductId} = ? and ${DatabaseHelper.tbPaymentLinesId} = ?',
        whereArgs: [line.tb_cart_position, line.productId, line.id]);
    return res;
  }

  Future<int> updatePartner(Partners partner) async {
    int id;
    id = partner.id;
    partner.id = null;
    Database db = await DatabaseHelper.instance.database;
    var response = await db.update(DatabaseHelper.tbPartner, partner.toJson(),
        where: '${DatabaseHelper.tbPartnerId} = ?', whereArgs: [id]);
    return response;
  }

  @override
  Future<int> insertPriceList(PriceList priceList) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbPriceList, priceList.toJson());
  }

  @override
  Future<List<PriceList>> queryGetPriceLists() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbPriceList);

    List<PriceList> list = res.isNotEmpty
        ? res.map((val) => PriceList.fromJson(val)).toList()
        : [];
    return list;
  }

  @override
  Future<int> insertAccountJournals(AccountJournal accountJournal) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
        DatabaseHelper.tbAccountJournal, accountJournal.toJson());
  }

  @override
  Future<List<AccountJournal>> queryGetAccountJournals() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbAccountJournal);

    List<AccountJournal> list = res.isNotEmpty
        ? res.map((val) => AccountJournal.fromJson(val)).toList()
        : [];
    return list;
  }

  @override
  Future<List<Session>> querySessions() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbSession);

    List<Session> list =
        res.isNotEmpty ? res.map((val) => Session.fromJson(val)).toList() : [];
    return list;
  }

  @override
  Future<int> updateSession(Session session) async {
    int id;
    id = session.id;
    //int cashControl = session.cashControl ? 1 : 0;
    Database db = await DatabaseHelper.instance.database;
    var response = await db.update(DatabaseHelper.tbSession, session.toJson(),
        where: '${DatabaseHelper.tbSessionId} = ?', whereArgs: [id]);
    return response;
  }

  @override
  Future<int> insertCompany(Companies company) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbCompany, company.toJson());
  }

  @override
  Future<List<Companies>> queryCompanys() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbCompany);

    List<Companies> list = res.isNotEmpty
        ? res.map((val) => Companies.fromJson(val)).toList()
        : [];
    return list;
  }

  @override
  Future<List<StateCart>> queryCartByPosition(String position) async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbCart,
        where: '${DatabaseHelper.columnPosition} = ?', whereArgs: [position]);

    List<StateCart> list = res.isNotEmpty
        ? res.map((val) => StateCart.fromJson(val)).toList()
        : [];
    return list;
  }

  @override
  Future<int> insertSession(Session session) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbSession, session.toJson());
  }

  @override
  Future<int> insertPayment(Payment payment) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(DatabaseHelper.tbPayment, payment.toJson());
  }

  @override
  Future<List<Payment>> queryPayments() async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbPayment);

    List<Payment> list =
        res.isNotEmpty ? res.map((val) => Payment.fromJson(val)).toList() : [];
    return list;
  }

  @override
  Future<int> deletePayments() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(DatabaseHelper.tbPayment);
  }

  @override
  Future<int> insertStatementIds(StatementIds statementIds) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
        DatabaseHelper.tbStatementIds, statementIds.toJson());
  }

  @override
  Future<List<StatementIds>> queryStatementIds(String position) async {
    Database db = await DatabaseHelper.instance.database;
    var res = await db.query(DatabaseHelper.tbStatementIds,
        where: '${DatabaseHelper.tbStatementIdsPositIon} = ?',
        whereArgs: [position]);

    List<StatementIds> list = res.isNotEmpty
        ? res.map((val) => StatementIds.fromJson(val)).toList()
        : [];
    return list;
  }
}
