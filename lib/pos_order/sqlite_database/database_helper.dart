import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/state_cart.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final tbCart = 'tb_Cart';
  static final tbProduct = 'tb_Product';
  static final tbPaymentLines = 'tb_PaymentLines';
  static final tbPartner = 'tb_Partner';
  static final tbPriceList = 'tb_PriceList';
  static final tbAccountJournal = 'tb_AccountJournal';
  static final tbSession = 'tb_Session';
  static final tbCompany = 'tb_Company';
  static final tbPayment = 'tb_Payment';
  static final tbStatementIds = 'tb_StatementIds';

  // cart
  static final columnId = 'tb_cart_id';
  static final columnPosition = 'tb_cart_position';
  static final columnCheck = 'tb_cart_check';
  static final columnTime = 'Time';
  static final columnLoginNumber = 'LoginNumber';

  // product
  static final tbId = "tbProductId";
  static final tbProductId = "Id";
  static final tbProductAvailableInPos = "AvailableInPOS";
  static final tbProductBarcode = "Barcode";
  static final tbProductDefaultCode = "DefaultCode";
  static final tbProductDiscountPurchase = "DiscountPurchase";
  static final tbProductDiscountSale = "DiscountSale";
  static final tbProductImageUrl = "ImageUrl";
  static final tbProductName = "Name";
  static final tbProductNameGet = "NameGet";
  static final tbProductNameNosign = "NameNosign";
  static final tbProductOldPrice = "OldPrice";
//  static final tbProductPosSalesCount = "PosSalesCount";
  static final tbProductPrice = "Price";
  static final tbProductProductTmplId = "ProductTmplId";
  static final tbProductPurchaseOK = "PurchaseOK";
  static final tbProductPurchasePrice = "PurchasePrice";
  static final tbProductSaleOK = "SaleOK";
  static final tbProductUOMId = "UOMId";
  static final tbProductUOMName = "UOMName";
  static final tbProductVersion = "Version";
  static final tbProductWeight = "Weight";
  static final tbProductPosSalesCount = "PosSalesCount";
  static final tbProductFactor = "Factor";

  // paymentLines
  static final tbPaymentLinesQty = "qty";
  static final tbPaymentLinesPriceUnit = "price_unit";
  static final tbPaymentLinesDiscount = "discount";
  static final tbPaymentLinesProductId = "product_id";
  static final tbPaymentLinesUomId = "uom_id";
  static final tbPaymentLinesDiscountType = "discount_type";
  static final tbPaymentLinesId = "id";
  static final tbPaymentLinesNote = "note";
  static final tbPaymentLinesNameCart = "name_cart";
  static final tbPaymentLinesTbCartPosition = "tb_cart_position";
  static final tbPaymentLinesProductName = "productName";
  static final tbPaymentLinesPromotionProgramId = "promotionprogram_id";
  static final tbPaymentLinesIsPromotion = "IsPromotion";

  // partner
  static final tbPartnerId = "Id";
  static final tbPartnerName = "Name";
  static final tbPartnerDisplayName = "DisplayName";
  static final tbPartnerStreet = "Street";
  static final tbPartnerPhone = "Phone";
  static final tbPartnerEmail = "Email";
  static final tbPartnerBarcode = "Barcode";
  static final tbPartnerImage = "Image";
  static final tbPartnerTaxCode = "TaxCode";

  // list price
  static final tbPriceListId = "Id";
  static final tbPriceListName = "Name";
  static final tbPriceListCurrencyId = "CurrencyId";
  static final tbPriceListCurrencyName = "CurrencyName";
  static final tbPriceListActive = "Active";
  static final tbPriceListCompanyId = "CompanyId";
  static final tbPriceListPartnerCateName = "PartnerCateName";
  static final tbPriceListSequence = "Sequence";
  static final tbPriceListDateStart = "DateStart";
  static final tbPriceListDateEnd = "DateEnd";

  // Account Journal
  static final tbAccountJournalId = "Id";
  static final tbAccountJournalCode = "Code";
  static final tbAccountJournalName = "Name";
  static final tbAccountJournalType = "Type";
  static final tbAccountJournalUpdatePosted = "UpdatePosted";
  static final tbAccountJournalCurrencyId = "CurrencyId";
  static final tbAccountJournalDefaultDebitAccountId = "DefaultDebitAccountId";
  static final tbAccountJournalDefaultCreditAccountId =
      "DefaultCreditAccountId";
  static final tbAccountJournalCompanyId = "CompanyId";
  static final tbAccountJournalCompanyName = "CompanyName";
  static final tbAccountJournalJournalUser = "JournalUser";
  static final tbAccountJournalProfitAccountId = "ProfitAccountId";
  static final tbAccountJournalLossAccountId = "LossAccountId";
  static final tbAccountJournalAmountAuthorizedDiff = "AmountAuthorizedDiff";
  static final tbAccountJournalDedicatedRefund = "DedicatedRefund";

  // session
  static final tbSessionId = "Id";
  static final tbSessionConfigId = "ConfigId";
  static final tbSessionConfigName = "ConfigName";
  static final tbSessionName = "Name";
  static final tbSessionUserId = "UserId";
  static final tbSessionUserName = "UserName";
  static final tbSessionStartAt = "StartAt";
  static final tbSessionStopAt = "StopAt";
  static final tbSessionState = "State";
  static final tbSessionShowState = "ShowState";
  static final tbSessionSequenceNumber = "SequenceNumber";
  static final tbSessionLoginNumber = "LoginNumber";
  static final tbSessionCashControl = "CashControl";
  static final tbSessionCashRegisterId = "CashRegisterId";
  static final tbSessionCashRegisterBalanceStart = "CashRegisterBalanceStart";
  static final tbSessionCashRegisterTotalEntryEncoding =
      "CashRegisterTotalEntryEncoding";
  static final tbSessionCashRegisterBalanceEnd = "CashRegisterBalanceEnd";
  static final tbSessionCashRegisterBalanceEndReal =
      "CashRegisterBalanceEndReal";
  static final tbSessionCashRegisterDifference = "CashRegisterDifference";
  static final tbSessionDateCreated = "DateCreated";

  // company tbCompany
  static final tbCompanyId = "Id";
  static final tbCompanyName = "Name";
  static final tbCompanyPartnerId = "PartnerId";
  static final tbCompanyEmail = "Email";
  static final tbCompanyPhone = "Phone";
  static final tbCompanyCurrencyId = "CurrencyId";
  static final tbCompanyStreet = "Street";
  static final tbCompanyLastUpdated = "LastUpdated";
  static final tbCompanyTransferAccountId = "TransferAccountId";
  static final tbCompanyWarehouseId = "WarehouseId";
  static final tbCompanyPeriodLockDate = "PeriodLockDate";
  static final tbCompanyCity = "City";
  static final tbCompanyDistrict = "District";
  static final tbCompanyWard = "Ward";

  // payment tbPayment
  static final tbPaymentName = "name";
  static final tbPaymentAmountPaid = "amount_paid";
  static final tbPaymentAmountTotal = "amount_total";
  static final tbPaymentAmountTax = "amount_tax";
  static final tbPaymentAmountReturn = "amount_return";
  static final tbPaymentDiscount = "discount";
  static final tbPaymentDiscountType = "discount_type";
  static final tbPaymentDiscountFixed = "discount_fixed";
  static final tbPaymentPosSessionId = "pos_session_id";
  static final tbPaymentPartnerId = "partner_id";
  static final tbPaymentTaxId = "tax_id";
  static final tbPaymentUserId = "user_id";
  static final tbPaymentUid = "uid";
  static final tbPaymentSequenceNumber = "sequence_number";
  static final tbPaymentCreationDate = "creation_date";
  static final tbPaymentTableId = "table_id";
  static final tbPaymentFloor = "floor";
  static final tbPaymentFloorId = "floor_id";
  static final tbPaymentCustomerCount = "customer_count";
  static final tbPaymentLoyaltyPoints = "loyalty_points";
  static final tbPaymentWonPoints = "won_points";
  static final tbPaymentSpentPoints = "spent_points";
  static final tbPaymentTotalPoints = "total_points";

  // StatementIds
  static final tbStatementIdsName = "name";
  static final tbStatementIdsStatementId = "statement_id";
  static final tbStatementIdsAccountId = "account_id";
  static final tbStatementIdsJournalId = "journal_id";
  static final tbStatementIdsAmount = "amount";
  static final tbStatementIdsPositIon = "positon";

  // make this a singleton class
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tbCart (
            $columnId INTEGER PRIMARY KEY,
            $columnPosition TEXT NOT NULL,
            $columnCheck BOOL NOT NULL,
            $columnTime TEXT,
            $columnLoginNumber INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE $tbProduct (
            $tbId INTEGER PRIMARY KEY,
            $tbProductId INTEGER,
            $tbProductName TEXT,
            $tbProductUOMId INTEGER,
            $tbProductUOMName TEXT,
            $tbProductNameNosign TEXT,
            $tbProductNameGet TEXT,
            $tbProductPrice DOUBLE,
            $tbProductOldPrice DOUBLE,
            $tbProductVersion INTEGER,  
            $tbProductDiscountSale DOUBLE, 
            $tbProductDiscountPurchase DOUBLE,
            $tbProductWeight DOUBLE,
            $tbProductProductTmplId INTEGER,
            $tbProductImageUrl TEXT,
            $tbProductPurchasePrice DOUBLE,
            $tbProductSaleOK BOOLEAN,
            $tbProductPurchaseOK BOOLEAN,           
            $tbProductAvailableInPos BOOLEAN,
            $tbProductDefaultCode TEXT,
            $tbProductBarcode TEXT,
            $tbProductPosSalesCount DOUBLE,  
            $tbProductFactor DOUBLE
          )
          ''');
    await db.execute('''
          CREATE TABLE $tbPaymentLines (
            $tbPaymentLinesQty INTEGER,
            $tbPaymentLinesPriceUnit DOUBLE,
            $tbPaymentLinesDiscount DOUBLE,
            $tbPaymentLinesProductId INTEGER NOT NULL,
            $tbPaymentLinesUomId INTEGER,
            $tbPaymentLinesDiscountType TEXT,
            $tbPaymentLinesId INTEGER NOT NULL PRIMARY KEY,
            $tbPaymentLinesNote TEXT,
            $tbPaymentLinesTbCartPosition TEXT NOT NULL,
            $tbPaymentLinesProductName TEXT,
            $tbPaymentLinesPromotionProgramId INTEGER,
            $tbPaymentLinesIsPromotion INTEGER
          )
          ''');
    await db.execute('''
          CREATE TABLE $tbPartner (
            $tbPartnerId INTEGER NOT NULL PRIMARY KEY,
            $tbPartnerName TEXT,
            $tbPartnerDisplayName TEXT,
            $tbPartnerStreet TEXT,
            $tbPartnerPhone TEXT,
            $tbPartnerEmail TEXT,
            $tbPartnerBarcode TEXT,
            $tbPartnerImage TEXT,
            $tbPartnerTaxCode TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $tbPriceList (
            $tbPriceListId INTEGER NOT NULL PRIMARY KEY,
            $tbPriceListName TEXT,
            $tbPriceListCurrencyId INTEGER,
            $tbPriceListCurrencyName TEXT,
            $tbPriceListActive BOOLEAN,
            $tbPriceListCompanyId INTEGER,
            $tbPriceListPartnerCateName TEXT,
            $tbPriceListSequence INTEGER,
            $tbPriceListDateStart TEXT,
            $tbPriceListDateEnd TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tbAccountJournal (
            $tbAccountJournalId INTEGER NOT NULL PRIMARY KEY,
            $tbAccountJournalCode TEXT,
            $tbAccountJournalName TEXT,
            $tbAccountJournalType TEXT,
            $tbAccountJournalUpdatePosted BOOLEAN,
            $tbAccountJournalCurrencyId INTEGER,
            $tbAccountJournalDefaultDebitAccountId INTEGER,
            $tbAccountJournalDefaultCreditAccountId INTEGER,
            $tbAccountJournalCompanyId INTEGER,
            $tbAccountJournalCompanyName TEXT,
            $tbAccountJournalJournalUser BOOLEAN,
            $tbAccountJournalProfitAccountId INTEGER,
            $tbAccountJournalLossAccountId INTEGER,
            $tbAccountJournalAmountAuthorizedDiff TEXT,
            $tbAccountJournalDedicatedRefund TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tbSession (
            $tbSessionId INTEGER NOT NULL PRIMARY KEY,
            $tbSessionConfigId INTEGER,
            $tbSessionConfigName TEXT,
            $tbSessionName TEXT,
            $tbSessionUserId TEXT,
            $tbSessionUserName TEXT,
            $tbSessionStartAt TEXT,
            $tbSessionStopAt TEXT,
            $tbSessionState TEXT,
            $tbSessionShowState TEXT,
            $tbSessionSequenceNumber INTEGER,
            $tbSessionLoginNumber INTEGER,
            $tbSessionCashRegisterId TEXT,
            $tbSessionCashRegisterBalanceStart INTEGER,
            $tbSessionCashRegisterTotalEntryEncoding INTEGER,
            $tbSessionCashRegisterBalanceEnd INTEGER,
            $tbSessionCashRegisterBalanceEndReal INTEGER,
            $tbSessionCashRegisterDifference INTEGER,
            $tbSessionDateCreated TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tbCompany (
            $tbCompanyId INTEGER NOT NULL PRIMARY KEY,
            $tbCompanyName TEXT,
            $tbCompanyPartnerId INTEGER,
            $tbCompanyEmail TEXT,
            $tbCompanyPhone TEXT,
            $tbCompanyCurrencyId INTEGER,
            $tbCompanyStreet TEXT,
            $tbCompanyLastUpdated TEXT,
            $tbCompanyTransferAccountId INTEGER,
            $tbCompanyWarehouseId INTEGER,
            $tbCompanyPeriodLockDate TEXT,
            $tbCompanyCity TEXT,
            $tbCompanyDistrict TEXT,
            $tbCompanyWard TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tbPayment (
            $tbPaymentName TEXT,
            $tbPaymentAmountPaid DOUBLE,
            $tbPaymentAmountTotal DOUBLE,
            $tbPaymentAmountTax DOUBLE,
            $tbPaymentAmountReturn DOUBLE,
            $tbPaymentDiscount DOUBLE,
            $tbPaymentDiscountType TEXT,
            $tbPaymentDiscountFixed DOUBLE,
            $tbPaymentPosSessionId INTEGER ,
            $tbPaymentPartnerId INTEGER,
            $tbPaymentTaxId TEXT,
            $tbPaymentUserId TEXT,
            $tbPaymentUid TEXT,
            $tbPaymentSequenceNumber INTEGER NOT NULL PRIMARY KEY, 
            $tbPaymentCreationDate TEXT,
            $tbPaymentTableId TEXT,
            $tbPaymentFloor TEXT,
            $tbPaymentFloorId TEXT,
            $tbPaymentCustomerCount INTEGER,
            $tbPaymentLoyaltyPoints INTEGER,
            $tbPaymentWonPoints INTEGER,
            $tbPaymentSpentPoints INTEGER,
            $tbPaymentTotalPoints INTEGER
          )
          ''');

    await db.execute('''
          CREATE TABLE $tbStatementIds (
            $tbStatementIdsName TEXT,
            $tbStatementIdsStatementId INTEGER,
            $tbStatementIdsAccountId INTEGER,
            $tbStatementIdsJournalId INTEGER,
            $tbStatementIdsAmount DOUBLE,
            $tbStatementIdsPositIon DOUBLE
          )
          ''');
  }
}
