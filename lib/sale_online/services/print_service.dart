/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 4:12 PM
 *
 */

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:nam_esc_pos_printer/nam_esc_pos_printer.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart' show Printing;
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/fast_purchase_order/printer_helper/my_canvas_printer.dart';
import 'package:tpos_mobile/fast_purchase_order/printer_helper/order_template_printer.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/sale_online/models/tpos_desktop.dart';
import 'package:tpos_mobile/sale_online/models/tpos_desktop/print_fast_sale_order_data.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/src/number_to_text/number_to_text.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/printer_configs.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_order.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/fast_sale_order_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_all.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'dart:ui' as ui;

abstract class PrintService {
  Future<void> printSaleOnlineTag(
      {@required SaleOnlineOrder order,
      String comment,
      String partnerNote,
      String productName,
      String partnerStatus,
      String note});
  Future<void> printFastSaleOrderShip({int fastSaleOrderId, int carrierId});
  Future<void> printFastSaleOrderInvoice(int invoiceId);
  Future<ByteData> printShipImage80mm(PrintShipData data);
  Future<ByteData> printShipGhtkImage80mm(PrintShipData data);
  Future<ByteData> printFastSaleOrderImage80mm(PrintFastSaleOrderData data);
  void printFastSaleOrderDeliveryInvoice();

  ///In sale online test qua Lan
  Future<void> printSaleOnlineLanTest();

  ///In sale online test qua TPOS PRINTER
  Future printSaleOnlineViaComputerTest();
  Future<void> printGame(
      {String name, String uid, String phone, String partnerCode});
}

class PosPrintService implements PrintService {
  ITposApiService _tposApiService;
  TposApi _tposApi;
  ITPosDesktopService _tposDesktop;
  IFastSaleOrderApi _fastSaleOrderApi;

  ISettingService _setting;
  Logger _log = new Logger("PosPrintService");
  PosPrintService(
      {ITposApiService tposApiService,
      ITPosDesktopService tposDesktop,
      ISettingService setting,
      IFastSaleOrderApi fastSaleOrderApi,
      IAppService appService,
      TposApi tposApi}) {
    _setting = setting ?? locator<ISettingService>();
    _tposApiService = tposApiService ?? locator<ITposApiService>();
    _tposDesktop = tposDesktop ?? locator<ITPosDesktopService>();
    _tposApi = tposApi ?? locator<TposApi>();
    _fastSaleOrderApi = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
  }

  @override
  void printFastSaleOrderDeliveryInvoice() {
    // TODO: implement printFastSaleOrderDeliveryInvoice
  }

  String _getDeliverCarrierBarcode(String carrierType, String trackingRef) {
    if (trackingRef == null || trackingRef == "") return "";
    var type = carrierType.toLowerCase();
    switch (type) {
      case "ghtk":
        return trackingRef.split(".").last;
        break;
      case "ghn":
        return trackingRef;
        break;
      default:
        return trackingRef;
    }
  }

  String _getDeliveryCarrierCodeToShow(String carrierType, String trackingRef) {
    if (trackingRef == null || trackingRef == "") return "";
    switch (carrierType.toLowerCase()) {
      case "ghtk":
        return trackingRef.replaceAll("${trackingRef.split(".")[0]}.", "");

        break;
      case "ghn":
        return trackingRef;
        break;
      default:
        return trackingRef;
    }
  }

  /// In hóa đơn bán hàng nhanh
  @override
  Future<void> printFastSaleOrderInvoice(int invoiceId) async {
    /// Cấu hình in
    PrinterConfig printConfig;

    /// Cấu hình bán hàng
    SaleSetting saleSetting;
    // Lấy máy in
    var shipPrinter = _setting.printers.firstWhere(
        (f) => f.name == _setting.fastSaleOrderInvoicePrinterName,
        orElse: () => null);

    if (shipPrinter == null) {
      throw new Exception(
          "Không tìm thấy máy in được cấu hình: ${_setting.fastSaleOrderInvoicePrinterName}. Vui lòng chọn lại trong Cài đặt-> Máy in -> Hóa đơn");
    }
    try {
      // ship setting
      Future getPrintConfig() async {
        // ship setting
        var conffig = await _tposApiService.getCompanyConfig();
        printConfig = conffig.printerConfigs
            ?.firstWhere((f) => f.code == "01", orElse: () => null);
      }

      // sale setting
      Future getSaleSetting() async {
        saleSetting = await _tposApi.saleSetting.getDefault();
      }

//      Future getCompany() async {
//        company = await _tposApi.getCompanyById(order.companyId);
//      }

      await Future.wait([
        getPrintConfig(),
        getSaleSetting(),
      ]);
    } catch (e, s) {
      _log.severe("get print config", e, s);
    }

    if (shipPrinter.type == "preview") {
      PdfPageFormat pdfFormat = PdfPageFormat.a4;
      if (printConfig != null) {
        switch (printConfig.template) {
          case "BILL80":
            pdfFormat = PdfPageFormat(7.6, 20);
            break;
          case "A5":
            pdfFormat = PdfPageFormat.a5;
            break;
          case "A4":
            pdfFormat = PdfPageFormat.a4;
            break;
        }
      }

      var invoice = await _tposApiService.getFastSaleOrderPrintDataAsHtml(
          fastSaleOrderId: invoiceId, type: "invoice");

      if (invoice != null) {
        invoice = invoice
            .replaceAll('href="/Content', 'href="${_setting.shopUrl}/Content')
            .replaceAll('/Web', '${_setting.shopUrl}/Web');
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            return await Printing.convertHtml(format: pdfFormat, html: invoice);
          },
        );
      }
    } else if (shipPrinter.type == "tpos_printer") {
      await _printOrderTPosPrinter(shipPrinter,
          printerConfig: printConfig,
          orderId: invoiceId,
          saleSetting: saleSetting);
    } else if (shipPrinter.type == "esc_pos") {
      await _printOrderLan(shipPrinter,
          orderId: invoiceId,
          printerConfig: printConfig,
          saleSetting: saleSetting);
    }
  }

  /// In phiếu ship
  /// Input FastSaleOrderId or order
  @override
  Future<void> printFastSaleOrderShip(
      {int fastSaleOrderId, int carrierId, FastSaleOrder order}) async {
    assert(order != null || fastSaleOrderId != null);

    // get print setting
    var shipPrinter = _setting.printers.firstWhere(
        (f) => f.name == _setting.shipPrinterName,
        orElse: () => null);

    if (shipPrinter == null) {
      throw new Exception("Không tìm thấy máy in được cấu hình");
    }

    PrinterConfigs printShipConfig;
    SaleSetting saleSetting;
    Company company;
    try {
      Future getOrder() async {
        if (order == null) {
          order = await _fastSaleOrderApi.getById(fastSaleOrderId);
        }
      }

      // ship setting
      Future getPrintConfig() async {
        var printConfigs = await _tposApiService.getPrinterConfigs();
        printShipConfig =
            printConfigs?.firstWhere((f) => f.code == "08", orElse: () => null);
      }

      // sale setting
      Future getSaleSetting() async {
        saleSetting = await _tposApi.saleSetting.getDefault();
      }

      await Future.wait([
        getOrder(),
        getPrintConfig(),
        getSaleSetting(),
      ]);

      company = await _tposApi.company.getById(order.companyId);
    } catch (e, s) {
      _log.severe("get print config", e, s);
      throw Exception("Không tải được dữ liệu, vui lòng thử lại");
    }

    if (_setting.shipPrinterName == "Xem và in") {
      this.printFastSaleOrderShipPreview(
          fastSaleOrderId, order.carrierId, printShipConfig);
      return;
    }
    // Send data to print
    var partner = order.partner;
    var dataPrint = PrintShipData(
        companyName: company.name,
        companyPhone: company.phone,
        companyAddress: company.street,
        carrierName: order.carrierName,
        carrierService: order.shipServiceId,
        shipWeight: order.shipWeight?.toInt(),
        cashOnDeliveryPrice: order.cashOnDelivery,
        invoiceAmount: order.amountTotal,
        deliveryPrice: order.deliveryPrice,
        invoiceNumber: order.number,
        invoiceDate: order.dateInvoice,
        receiverName: order.receiverName ?? partner.name,
        receiverPhone: order.receiverPhone ?? partner.phone,
        receiverAddress: order.receiverAddress ?? partner.street,
        receiverCityName: order.shipReceiver?.city?.name ?? partner.city?.name,
        receiverDictrictName:
            order.shipReceiver?.district?.name ?? partner.district?.name,
        receiverWardName: order.shipReceiver?.ward?.name ?? partner?.ward?.name,
        note: printShipConfig?.note,
        shipNote: order.deliveryNote,
        content: order.orderLines
            ?.map((f) => "${f.productUOMQty?.toInt()}  ${f.nameTemplate}")
            ?.join(", "),
        trackingRef: order.trackingRef,
        trackingRefSort: order.trackingRefSort,
        staff: order.userName,
        depositAmount: order.amountDeposit,
        productQuantity: order.productQuantity);

    // nếu cấu hinh in địa chỉ đẩy đủ
    if (saleSetting.groupFastSaleAddressFull) {
      dataPrint.receiverAddress = order.address ?? partner.addressFull;
    }

    if (order.carrierDeliveryType != null &&
        order.carrierDeliveryType.toLowerCase().contains("ghtk")) {
      if (order.trackingRef != null) {}
    }

    if (order.carrierDeliveryType != null && order.trackingRef != null) {
      String carrierType = order.carrierDeliveryType.toLowerCase();
      switch (carrierType) {
        case "ghtk":
          dataPrint.shipCode = order.trackingRef.split(".").last;
          dataPrint.trackingRefToShow = order.trackingRef
              .replaceAll("${order.trackingRef.split(".")[0]}.", "");

          if (order.trackingRef.split(".").length > 2)
            dataPrint.trackingRefGHTK =
                "${order.trackingRef.split(".")[1]}.${order.trackingRef.split(".")[2]}";
          else
            dataPrint.trackingRefGHTK = order.trackingRef;
          break;
        case "ghn":
          dataPrint.shipCode = order.trackingRef;
          dataPrint.trackingRefToShow = order.trackingRef;
          break;
        default:
          dataPrint.shipCode = order.trackingRef;
          dataPrint.trackingRefToShow = order.trackingRef;
      }
    }

    PrintShipConfig shipConfig = new PrintShipConfig();
    var others = printShipConfig?.others;
    if (others != null) {
      shipConfig.isHideShipAmount = others
              .firstWhere((f) => f.key == "config.hide_ship_amount",
                  orElse: () => null)
              ?.value ??
          false;

      shipConfig.isHideShip = others
              .firstWhere((f) => f.key == "config.hide_ship",
                  orElse: () => null)
              ?.value ??
          false;
      shipConfig.isHideNoteShip = others
              .firstWhere((f) => f.key == "config.hide_noteship",
                  orElse: () => null)
              ?.value ??
          false;
      shipConfig.isHideInfoShip = others
              .firstWhere((f) => f.key == "config.hide_infoship",
                  orElse: () => null)
              ?.value ??
          false;
      shipConfig.isHideAddress = others
              .firstWhere((f) => f.key == "config.hide_address",
                  orElse: () => null)
              ?.value ??
          false;
      shipConfig.isShowLogo = others
              .firstWhere((f) => f.key == "config.show_logo",
                  orElse: () => null)
              ?.value ??
          false;

      shipConfig.isHideCod = others
              .firstWhere((f) => f.key == "config.hide_COD", orElse: () => null)
              ?.value ??
          false;
      shipConfig.isHideInvoiceCode = others
              .firstWhere((f) => f.key == "config.hide_invoice_code",
                  orElse: () => null)
              ?.value ??
          false;
      shipConfig.isShowStaff = others
              .firstWhere((f) => f.key == "config.show_staff",
                  orElse: () => null)
              ?.value ??
          false;
    }

    if (shipPrinter.type == "tpos_printer") {
      String shipSize = _setting.shipSize;

      if (!_setting.settingPrintShipShowDepositAmount) {
        dataPrint.depositAmount = null;
      }

      if (!_setting.settingPrintShipShowProductQuantity) {
        dataPrint.productQuantity = null;
      }
      await _tposDesktop.printShip(
          hostName: shipPrinter.ip,
          port: shipPrinter.port,
          data: dataPrint,
          size: shipSize,
          config: shipConfig);
    } else if (shipPrinter.type == "esc_pos") {
      await printFastSaleOrderShipLan(
          data: dataPrint, settingPrinter: shipPrinter, config: shipConfig);
    } else {
      // preview
    }
  }

  /// In phiếu ship qua lan
  Future<void> printFastSaleOrderShipLan(
      {PrintShipData data,
      PrinterDevice settingPrinter,
      PrintShipConfig config}) async {
    //Check printer

    Printer printer =
        new Printer(printerProfileName: settingPrinter.profileName);
    await printer.connect(
        host: settingPrinter.ip,
        port: settingPrinter.port,
        timeout: Duration(seconds: 10));

    if (_setting.shipSize == "BILL80-IMAGE") {
      // In qua hình
      try {
        if (config.isHideAddress) data.companyAddress = null;
        if (config.isHideCod) data.cashOnDeliveryPrice = null;
        if (config.isHideShipAmount) data.deliveryPrice = null;
        if (config.isHideInvoiceCode) data.invoiceNumber = null;
        if (config.isHideNoteShip) data.shipNote = null;
        if (!config.isShowStaff) data.staff = null;
        var image = await printShipImage80mm(data);
        settingPrinter.isImageRasterPrint
            ? printer.printImageRasterFromByteData(image)
            : printer.printImage(data: image);
        printer.feed(1);
        printer.cut(mode: PosCutMode.full);
        printer.disconnect();
      } catch (e) {
        printer.disconnect();
        throw new Exception(e);
      }

      return;
    }

    try {
      PosStyles normalStyle = PosStyles(codeTable: PosCodeTable.wpc1258);
      printer.printTextLn(
        "${data.companyName}",
        style: normalStyle.copyWith(
            bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      );
      printer.printTextLn("SĐT: ${data.companyPhone}",
          style: normalStyle.copyWith(bold: true));
      // Địa chỉ công ty
      if (!config.isHideAddress) {
        printer.printTextLn(
          "Địa chỉ: ${data.companyAddress}",
          style: normalStyle.copyWith(bold: true),
        );
      }

      if (!config.isShowStaff) {
        printer.printTextLn(
          "Nhân viên: ${data.staff ?? ""}",
          style: normalStyle.copyWith(bold: false),
        );
      }

      if (data.carrierName != null) {
        printer.printTextLn("${data.carrierName}",
            style:
                normalStyle.copyWith(bold: false, align: PosTextAlign.center));
      }

      if (data.shipCode != null) {
        printer.printBarcode("${data.shipCode}",
            textStyle: PosStyles(align: PosTextAlign.center),
            barcodeStyle: BarcodeStyle(
                width: 3,
                height: 70,
                textPosition: BarcodeTextPosition.barcode_text_position_none));
      }
      if (data.trackingRefToShow != null) {
        printer.printTextLn("${data.trackingRefToShow}",
            style:
                normalStyle.copyWith(bold: false, align: PosTextAlign.center));
      }

      // Barcode
      printer.feed(1);
      if (!config.isHideCod) {
        printer.printTextLn(
          "Thu hộ: ${vietnameseCurrencyFormat(data.cashOnDeliveryPrice ?? 0)} VNĐ",
          style: normalStyle.copyWith(
              align: PosTextAlign.center,
              width: PosTextSize.size2,
              height: PosTextSize.size2,
              bold: true),
        );
      }

      // Tiền hàng +  tiền ship
      if (!config.isHideShipAmount) {
        String shipAmountString =
            " + Ship: ${vietnameseCurrencyFormat(data.deliveryPrice ?? 0)})";
        printer.printTextLn(
          "(Tiền hàng : ${vietnameseCurrencyFormat(data.invoiceAmount ?? 0)}${config.isHideShip ? "" : shipAmountString}",
          style: normalStyle.copyWith(
            align: PosTextAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
          ),
        );
      }

      // Mã hóa đơn
      if (!config.isHideInvoiceCode) {
        printer.printTextLn(
          "${data.invoiceNumber}",
          style: normalStyle.copyWith(
            align: PosTextAlign.center,
            width: PosTextSize.size1,
            height: PosTextSize.size1,
            bold: true,
          ),
        );
      }

      printer.printTextLn(
        "Ngày: ${DateFormat("dd/MM/yyyy").format(data.invoiceDate)}",
        style: normalStyle.copyWith(
          align: PosTextAlign.center,
          width: PosTextSize.size1,
          height: PosTextSize.size1,
          bold: true,
        ),
        lineAfter: 1,
      );

      printer.printTextLn("Người nhận: ${data.receiverName}",
          style: normalStyle.copyWith(bold: true));
      printer.printTextLn("Điện thoại: ${data.receiverPhone}",
          style: normalStyle.copyWith(bold: true));
      printer.printTextLn("Địa chỉ: ${data.receiverAddress}",
          style: normalStyle.copyWith(bold: false));

      // Ghi chú giao hàng
      if (!config.isHideNoteShip && data.shipNote != null) {
        printer.feed(1);
        printer.printTextLn(
          "Ghi chú GH: ${data.shipNote ?? ""}",
          style: normalStyle.copyWith(
              bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
        );
      }

      printer.printTextLn("Ghi chú khác: ${data.note ?? ""}",
          style: normalStyle.copyWith(bold: false));

      if (data.trackingRefSort != null) {}
      printer.feed(1);
      printer.cut();
      printer.disconnect();
    } catch (e, s) {
      _log.severe("print", e, s);
      printer.disconnect();
      throw new Exception(e.toString());
    }
  }

  /// In phiếu ship qua máy
  Future<void> printFastSaleOrderShipPreview(
    int fastSaleOrderId,
    int carrierId,
    PrinterConfigs printConfig,
  ) async {
    var html = await _tposApiService.getFastSaleOrderPrintDataAsHtml(
        fastSaleOrderId: fastSaleOrderId, carrierId: carrierId, type: "ship");

    if (html != null) {
      html = html
          .replaceAll('href="/Content', 'href="${_setting.shopUrl}/Content')
          .replaceAll('/Web', '${_setting.shopUrl}/Web');

      PdfPageFormat pdfFormat = PdfPageFormat.a4;
      if (printConfig != null) {
        switch (printConfig.template) {
          case "BILL80":
            pdfFormat =
                PdfPageFormat(7.6 * PdfPageFormat.cm, 20 * PdfPageFormat.cm);
            break;
          case "A5":
            pdfFormat = PdfPageFormat.a5;
            break;
          case "A4":
            pdfFormat = PdfPageFormat.a4;
            break;
        }
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return await Printing.convertHtml(format: pdfFormat, html: html);
        },
      );
    }
  }

  /// In sale online
  @override
  Future<void> printSaleOnlineTag(
      {@required SaleOnlineOrder order,
      String comment,
      String partnerNote,
      String productName,
      String partnerStatus,
      String note}) async {
    String product = productName ??
        (order.details != null
            ? order.details.map((f) => f.productName).join(", ")
            : "");

    Future<String> _tryGetPartnerCode(int partnerId) async {
      try {
        var parnter = await _tposApiService.getPartnerById(partnerId);
        return parnter?.ref;
      } catch (e, s) {
        return null;
      }
    }

    // Get setting
    PrintSaleOnlineData printData = new PrintSaleOnlineData(
        index: order.sessionIndex != null && order.sessionIndex != 0
            ? order.sessionIndex
            : null,
        code: order.code,
        uid: order.facebookUserId,
        partnerCode:
            order.partnerCode ?? await _tryGetPartnerCode(order.partnerId),
        partnerStatus: partnerStatus,
        name: order.facebookUserName,
        product: product,
        phone: order.telephone,
        header: _setting.isSaleOnlinePrintCustomHeader
            ? _setting.saleOnlinePrintCustomHeaderContent
            : null);

    if (note == null || note == "") {
      note = "";

      if (_setting.isSaleOnlinePrintAllOrderNote) {
        note = order.note;
      }
// In địa chỉ
      if (_setting.isSaleOnlinePrintAddress == true) {
        if (note != null && note.isNotEmpty) {
          if (order.address != null && order.address != "") {
            note += "\nDc: ${order.address}";
          }
        } else {
          note = order.address ?? "";
        }
      }
// In Comment
      if (_setting.isSaleOnlinePrintComment == true &&
          _setting.isSaleOnlinePrintAllOrderNote == false) {
        if (note.isNotEmpty) {
          if (comment != null && comment != "") {
            note += "\n------------\n$comment";
          }
        } else {
          note = comment ?? "";
        }
      }

      if (_setting.isSaleOnlinePrintPartnerNote) {
        if (note.isNotEmpty) {
          if (partnerNote != null && partnerNote != "") {
            note += "\n-----------\n" + (partnerNote ?? "");
          }
        } else {
          note = partnerNote ?? "";
        }
      }
    }

    if (_setting.printMethod == PrintSaleOnlineMethod.ComputerPrinter) {
      await _tposDesktop.printSaleOnline(null, null, note, printData);
    } else if (_setting.printMethod == PrintSaleOnlineMethod.LanPrinter) {
      // print by ESC POS DEVICE
      var shipPrinter = _setting.printers
          .firstWhere((f) => f.type == "esc_pos", orElse: () => null);

      if (_setting.saleOnlineSize == "BILL80-IMAGE") {
        await printSaleOnlineTagImage80mm(
            printData: printData,
            note: order.note,
            comment: comment,
            dateCreated: order.dateCreated,
            address: order.address);
        return;
      }

      var printer = Printer(printerProfileName: shipPrinter.profileName);
      await printer.connect(
          host: _setting.lanPrinterIp,
          port: int.parse(_setting.lanPrinterPort),
          timeout: Duration(seconds: 20));
      printer.reset();

      //Content here
      var style = PosStyles(
          codeTable: PosCodeTable.wpc1258,
          bold: true,
          fontType: PosFontType.fontA,
          width: PosTextSize.size2,
          height: PosTextSize.size2,
          align: PosTextAlign.center,
          isRemoveMark: _setting.settingPrintSaleOnlineNoSign);

      try {
        // IN nội dung theo cài đặt
        var settingContents = _setting.settingSaleOnlinePrintContents;
        settingContents.forEach((content) {
          // Chuyển int sang PosFontSize
          PosTextSize getPosSize(int value) {
            switch (value) {
              case 1:
                return PosTextSize.size1;
                break;
              case 2:
                return PosTextSize.size2;
                break;
              case 3:
                return PosTextSize.size3;
              default:
                return PosTextSize.size1;
            }
          }

          // Tạo style cho chữ
          var textStyle = style.copyWith(
            bold: content.bold,
            width: getPosSize(
              content.fontSize,
            ),
            height: getPosSize(content.fontSize),
          );
          switch (content.name) {
            case "header":
              if (_setting.saleOnlinePrintCustomHeaderContent != null &&
                  _setting.saleOnlinePrintCustomHeaderContent != "") {
                printer.printTextLn(
                  _setting.saleOnlinePrintCustomHeaderContent,
                  style: textStyle,
                );
              }
              break;
            case "uid":
              if (printData.uid != null && printData.uid != "")
                printer.printTextLn(
                  printData.uid,
                  style: textStyle,
                );
              break;
            case "name":
              if (printData.name != null && printData.name != "") {
                printer.printTextLn(printData.name, style: textStyle);
              }

              break;
            case "phone":
              if (printData.phone != null && printData.phone != "")
                printer.printTextLn("SĐT: ${printData.phone}",
                    style: textStyle);
              break;
            case "address":
              if (order.address != null && order.address != "") {
                printer.printTextLn(
                  "ĐC: ${order.address}",
                  style: textStyle,
                );
              }
              break;
            case "partnerCode":
              if (printData.partnerCode != null &&
                  printData.partnerCode != "") {
                printer.printTextLn(
                  printData.partnerCode,
                  style: textStyle,
                );
              }

              break;
//            case "parterCode":
//              if (printData.partnerCode != null &&
//                  printData.partnerCode != "") {
//                printer.printTextLn(
//                  printData.partnerCode,
//                  style: textStyle,
//                );
//              }
//
//              break;
            case "productName":
              if (printData.product != null && printData.product != "") {
                printer.printTextLn(
                  printData.product,
                  style: textStyle,
                );
              }
              break;
            case "orderIndex":
              if (order.sessionIndex != null && order.sessionIndex != 0) {
                printer.printTextLn(
                  "STT đơn: ${order.sessionIndex}",
                  style: textStyle,
                );
              }
              break;
            case "orderCode":
              if (order.code != null && order.code != "") {
                printer.printTextLn(
                  "Mã đơn: ${order.code}",
                  style: textStyle,
                );
              }
              break;
            case "orderIndexAndCode":
              String indexCodeBuilder = "";
              if (printData.index != null && printData.index != 0) {
                indexCodeBuilder = "#${printData.index.toString()}. ";
              }
              // Code
              printer.printTextLn("$indexCodeBuilder${printData.code}",
                  style: textStyle, lineAfter: 1);
              break;
            case "orderTime":
              if (order.dateCreated != null) {
                printer.printTextLn(
                  "Ngày ĐH: ${DateFormat("dd/MM/yyyy HH:mm").format(order.dateCreated)}",
                  style: textStyle,
                );
              }
              break;
            case "comment":
              if (comment != null && comment != "") {
                printer.printTextLn(
                  "$comment",
                  style: textStyle,
                );
              }
              break;
            case "note":
              if (order.note != null &&
                  order.note != "" &&
                  _setting.isSaleOnlinePrintAllOrderNote) {
                printer.printTextLn(
                  "${order.note}",
                  style: textStyle,
                );
              }
              break;
            case "printTime":
              // time// Time
              printer.printTextLn(
                DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
                style: textStyle,
              );
              break;
            case "partnerStatus":
              // time// Time
              printer.printTextLn(
                "${printData.partnerCode}",
                style: textStyle,
              );
              break;
            case "partnerCodeAndStatus":
              // time// Time
              printer.printTextLn(
                "${printData.partnerCode} (${printData.partnerStatus})",
                style: textStyle,
              );
              break;
          }
        });
        printer.feed(1);
        printer.printTextLn(
          "TPOS.VN",
          style: PosStyles(
            align: PosTextAlign.center,
          ),
        );

        //Content here
        printer.cut();
        printer.reset();
        printer.disconnect();
      } catch (e, s) {
        printer.disconnect();
        _log.severe("", e, s);
        throw new Exception(e.toString());
      }
    }
  }

  Future<void> printSaleOnlineTagImage80mm({
    @required PrintSaleOnlineData printData,
    String comment,
    String note,
    DateTime dateCreated,
    String address,
  }) async {
    // print by ESC POS DEVICE
    var shipPrinter = _setting.printers
        .firstWhere((f) => f.type == "esc_pos", orElse: () => null);

    var printer = Printer(printerProfileName: shipPrinter.profileName);
    try {
      await printer.connect(
          host: _setting.lanPrinterIp,
          port: int.parse(_setting.lanPrinterPort),
          timeout: Duration(seconds: 20));
      printer.reset();

      CanvasPrinter canvasPrinter = new CanvasPrinter();
      CanvasStyles canvasStyles = new CanvasStyles();
      // IN nội dung theo cài đặt
      var settingContents = _setting.settingSaleOnlinePrintContents;
      settingContents.forEach((content) {
        // Chuyển int sang PosFontSize
        double getPosSize(int value) {
          switch (value) {
            case 1:
              return 30;
              break;
            case 2:
              return 50;
              break;
            case 3:
              return 70;
            default:
              return 30;
          }
        }

        // Tạo style cho chữ
        var textStyle = canvasStyles.copyWith(
          bold: content.bold,
          fontSize: getPosSize(
            content.fontSize,
          ),
          align: TextAlign.center,
        );
        switch (content.name) {
          case "header":
            if (_setting.saleOnlinePrintCustomHeaderContent != null &&
                _setting.saleOnlinePrintCustomHeaderContent != "") {
              canvasPrinter.printTextLn(
                _setting.saleOnlinePrintCustomHeaderContent,
                style: textStyle,
              );
            }
            break;
          case "uid":
            if (printData.uid != null && printData.uid != "")
              canvasPrinter.printTextLn(
                printData.uid,
                style: textStyle,
              );
            break;
          case "name":
            if (printData.name != null && printData.name != "") {
              canvasPrinter.printTextLn(printData.name, style: textStyle);
            }

            break;
          case "phone":
            if (printData.phone != null && printData.phone != "")
              canvasPrinter.printTextLn("SĐT: ${printData.phone}",
                  style: textStyle);
            break;
          case "address":
            if (address != null && address != "") {
              canvasPrinter.printTextLn(
                "ĐC: $address",
                style: textStyle,
              );
            }
            break;
          case "partnerCode":
            if (printData.partnerCode != null && printData.partnerCode != "") {
              canvasPrinter.printTextLn(
                printData.partnerCode,
                style: textStyle,
              );
            }

            break;

          case "productName":
            if (printData.product != null && printData.product != "") {
              canvasPrinter.printTextLn(
                printData.product,
                style: textStyle,
              );
            }
            break;
          case "orderIndex":
            if (printData.index != null && printData.index != 0) {
              canvasPrinter.printTextLn(
                "STT đơn: ${printData.index}",
                style: textStyle,
              );
            }
            break;
          case "orderCode":
            if (printData.code != null && printData.code != "") {
              canvasPrinter.printTextLn(
                "Mã đơn: ${printData.code}",
                style: textStyle,
              );
            }
            break;
          case "orderIndexAndCode":
            String indexCodeBuilder = "";
            if (printData.index != null && printData.index != 0) {
              indexCodeBuilder = "#${printData.index.toString()}. ";
            }
            // Code
            canvasPrinter.printTextLn(
              "$indexCodeBuilder${printData.code}",
              style: textStyle,
            );
            break;
          case "orderTime":
            if (dateCreated != null) {
              canvasPrinter.printTextLn(
                "Ngày ĐH: ${DateFormat("dd/MM/yyyy HH:mm").format(dateCreated)}",
                style: textStyle,
              );
            }
            break;
          case "comment":
            if (comment != null && comment != "") {
              canvasPrinter.printTextLn(
                "$comment",
                style: textStyle,
              );
            }
            break;
          case "note":
            if (note != null &&
                note != "" &&
                _setting.isSaleOnlinePrintAllOrderNote) {
              canvasPrinter.printTextLn(
                "$note",
                style: textStyle,
              );
            }
            break;
          case "printTime":
            // time// Time
            canvasPrinter.printTextLn(
              DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
              style: textStyle,
            );
            break;
          case "partnerStatus":
            // time// Time
            canvasPrinter.printTextLn(
              "${printData.partnerCode}",
              style: textStyle,
            );
            break;
          case "partnerCodeAndStatus":
            // time// Time
            canvasPrinter.printTextLn(
              "${printData.partnerCode} (${printData.partnerStatus})",
              style: textStyle,
            );
            break;
        }
      });
      canvasPrinter.emptyLines(1);
      canvasPrinter.printTextLn(
        "TPOS.VN",
        style: CanvasStyles(
          align: TextAlign.center,
        ),
      );

      var image = await canvasPrinter.generateImage();
      shipPrinter.isImageRasterPrint
          ? printer.printImageRasterFromByteData(image)
          : printer.printImage(data: image);

      //Content here
      printer.cut();
      printer.reset();
      printer?.disconnect();
    } catch (e, s) {
      _log.severe("", e, s);
      throw new Exception(e.toString());
    }
  }

  Future<void> _printOrderLan(PrinterDevice printerDevice,
      {FastSaleOrder order,
      int orderId,
      PrinterConfig printerConfig,
      SaleSetting saleSetting}) async {
    assert(order != null || orderId != null);
    assert(printerConfig != null);

    if (order == null) {
      order = await _fastSaleOrderApi.getById(orderId);
    }

    if (order == null) {
      throw new Exception("Không tải được dữ liệu");
    }

    // Print setting

    var company = await _tposApi.company.getById(order.companyId);
    var partner = await _tposApiService.getPartnerById(order.partnerId);

    PrintFastSaleOrderConfig webPrintConfig = new PrintFastSaleOrderConfig();
    printerConfig.others.forEach((f) {
      switch (f.keyConfig) {
        case Config.hide_address:
          webPrintConfig.hideAddress = f.value;
          break;
        case Config.hide_product_code:
          webPrintConfig.hideProductCode = f.value;
          break;
        case Config.hide_delivery:
          webPrintConfig.hideDelivery = f.value;
          break;
        case Config.hide_debt:
          webPrintConfig.hideDebt = f.value;
          break;
        case Config.hide_logo:
          webPrintConfig.hideLogo = f.value;
          break;
        case Config.hide_receiver:
          webPrintConfig.hideReceiver = f.value;
          break;
        case Config.hide_address:
          webPrintConfig.hideAddress = f.value;
          break;
        case Config.hide_phone:
          webPrintConfig.hidePhone = f.value;
          break;
        case Config.hide_staff:
          webPrintConfig.hideStaff = f.value;
          break;
        case Config.hide_amount_text:
          webPrintConfig.hideAmountText = f.value;
          break;
        case Config.hide_sign:
          webPrintConfig.hideSign = f.value;
          break;
        case Config.hide_TrackingRef:
          webPrintConfig.hideTrackingRef = f.value;
          break;
        case Config.hide_CustomerName:
          webPrintConfig.hideCustomerName = f.value;
          break;
        case Config.showbarcode:
          webPrintConfig.showBarcode = f.value;
          break;
        case Config.showweightship:
          webPrintConfig.showWeightShip = f.value;
          break;
        case Config.hide_product_note:
          webPrintConfig.hideProductNote = f.value;
          break;
        case Config.show_COD:
          webPrintConfig.showCod = f.value;
          break;
        case Config.show_revenue:
          webPrintConfig.showRevenue = f.value;
          break;
        case Config.show_combo:
          webPrintConfig.showCombo = f.value;
          break;
        case Config.show_tracking_ref_sort:
          webPrintConfig.showTrackingRefSoft = f.value;
          break;
      }
    });

    double productCount =
        order.orderLines?.map((f) => f.productUOMQty)?.reduce((a, b) => a + b);

    Printer printer =
        new Printer(printerProfileName: printerDevice.profileName);
    await printer.connect(
        port: printerDevice.port,
        host: printerDevice.ip,
        timeout: Duration(seconds: 10));

    if (_setting.fastSaleOrderInvoicePrintSize == "BILL80-IMAGE") {
      try {
        var printData = PrintFastSaleOrderData();

        printData.companyName = company.name;
        printData.companyMoreInfo = company.moreInfo;
        printData.companyPhone = company.phone;
        printData.compnayAddress = company.street;

        printData.carrierName = order.carrierName;
        if (order.trackingRef != null && order.trackingRef != "") {
          printData.shipCode = _getDeliverCarrierBarcode(
              order.carrierDeliveryType, order.trackingRef);
          printData.trackingRef = order.trackingRef;
          printData.trackingRefSort = order.trackingRefSort;
        }

        printData.shipNote = order.deliveryNote;

        printData.cashOnDeliveryAmount = order.cashOnDelivery;
        printData.invoiceNumber = order.number;
        printData.invoiceDate = order.dateInvoice;
        printData.customerName = partner.name;
        printData.customerPhone = partner.phone;
        printData.customerAddress = saleSetting.groupFastSaleAddressFull
            ? partner.addressFull
            : partner.street;

        printData.subTotal = order.subTotal;
        printData.shipAmount = order.carrierId != null && order.carrierId != 0
            ? order.deliveryPrice
            : null;
        printData.discount = order.discount;
        printData.discountAmount = order.discountAmount;
        printData.decreaseAmount = order.decreaseAmount;
        printData.totalAmount = order.amountTotal + order.deliveryPrice;
        printData.oldCredit = order.oldCredit;
        printData.payment = order.paymentAmount;
        printData.totalDeb = partner.credit;
        printData.previousBalance = order.previousBalance;
        printData.invoiceNote = order.comment;
        printData.defaultNote = printerConfig?.note;
        printData.receiverPhone = order.receiverPhone ?? order.partner?.phone;
        printData.receiverAddress =
            order.receiverAddress ?? order.partner?.addressFull;
        printData.receiverName = order.receiverName ?? order.partner?.name;

        printData.hideProductCode = webPrintConfig.hideProductCode;
        printData.hideDelivery = webPrintConfig.hideDelivery;
        printData.hideDebt = webPrintConfig.hideDebt;
        printData.hideLogo = webPrintConfig.hideLogo;
        printData.hideReceiver = webPrintConfig.hideReceiver;
        printData.hideAddress = webPrintConfig.hideAddress;
        printData.hidePhone = webPrintConfig.hidePhone;
        printData.hideStaff = webPrintConfig.hideStaff;

        printData.hideAmountText = webPrintConfig.hideAmountText;
        printData.hideSign = webPrintConfig.hideSign;
        printData.hideTrackingRef = webPrintConfig.hideTrackingRef;
        printData.hideCustomerNam = webPrintConfig.hideCustomerName;
        printData.hideProductNote = webPrintConfig.hideProductNote;
        printData.showBarcode = webPrintConfig.showBarcode;

        printData.showWeightShip = webPrintConfig.showWeightShip;
        printData.showCod = webPrintConfig.showCod;
        printData.showRevenue = webPrintConfig.showRevenue;
        printData.showCombo = webPrintConfig.showCombo;
        printData.showTrackingRefSort = webPrintConfig.showTrackingRefSoft;
        printData.trackingRefToShow = _getDeliveryCarrierCodeToShow(
            order.carrierDeliveryType, order.trackingRef);

        printData.revenue = order.revenue;
        printData.user = order.userName;
        printData.orderLines = order.orderLines;
        printData.totalInWords =
            "${convertNumberToWord(((order.amountTotal ?? 0) + (order.deliveryPrice ?? 0)).toInt().toString())} ./.";

        // Hide
        if (webPrintConfig.hideAddress) printData.customerAddress = null;
        if (webPrintConfig.hidePhone) printData.customerPhone = null;
        if (webPrintConfig.hideAmountText) printData.totalInWords = null;
        if (webPrintConfig.hideCustomerName) printData.customerName = null;
        if (webPrintConfig.hideDebt) printData.previousBalance = null;
        if (webPrintConfig.hideDebt) printData.totalDeb = null;
        if (webPrintConfig.hideDebt) printData.payment = null;
        if (webPrintConfig.hideTrackingRef) printData.trackingRef = null;
        if (webPrintConfig.hideTrackingRef) printData.trackingRefToShow = null;
        if (webPrintConfig.hideTrackingRef) printData.trackingRefSort = null;
        if (webPrintConfig.hideTrackingRef) printData.shipCode = null;
        if (webPrintConfig.hideTrackingRef) printData.carrierName = null;
        if (webPrintConfig.hideStaff) printData.userDelivery = null;
        if (webPrintConfig.hideStaff) printData.user = null;
        if (webPrintConfig.hidePhone) if (webPrintConfig.hideReceiver) {
          printData.receiverAddress = null;
          printData.receiverName = null;
          printData.receiverPhone = null;
        }

        // show
        if (!webPrintConfig.showWeightShip) printData.shipWeight = null;
        if (!webPrintConfig.showTrackingRefSoft)
          printData.trackingRefSort = null;
        if (!webPrintConfig.showCod) printData.cashOnDeliveryAmount = null;
        if (!webPrintConfig.showRevenue) printData.revenue = null;

        printData.deliveryDate = order.deliveryDate;
        var orderImage = await printFastSaleOrderImage80mm(printData);

        printerDevice.isImageRasterPrint
            ? printer.printImageRasterFromByteData(orderImage)
            : printer.printImage(data: orderImage);

        printer.cut();
        printer.disconnect();
      } catch (e, s) {
        _log.severe("", e, s);
        printer.disconnect();
      }

      return;
    }

    try {
      // Tên công ty
      var style = PosStyles(align: PosTextAlign.center);
      printer.printTextLn(order.company?.name,
          style: style.copyWith(width: PosTextSize.size2));
      printer.printTextLn(company?.moreInfo,
          style: style.copyWith(width: PosTextSize.size2));
      printer.printTextLn(company?.street, style: style);
      printer.printTextLn(company?.phone, style: style);

      //Tên đối tác giao hàng
      printer.printTextLn(order.carrierName, style: style);

      if (!webPrintConfig.hideTrackingRef) {
        if (order.trackingRefSort != null)
          printer.printTextLn(order.trackingRefSort, style: style);
        // bar code
        if (order.trackingRef != null && order.trackingRef != "") {
          printer.printBarcode(
              _getDeliverCarrierBarcode(
                  order.carrierDeliveryType, order.trackingRef),
              textStyle: PosStyles(align: PosTextAlign.center),
              barcodeStyle: BarcodeStyle(
                  width: 3,
                  height: 70,
                  textPosition:
                      BarcodeTextPosition.barcode_text_position_none));

          printer.printTextLn(
              _getDeliveryCarrierCodeToShow(
                  order.carrierDeliveryType, order.trackingRef),
              style: style);
          if (webPrintConfig.showWeightShip) {
            printer.printTextLn("KL ship (g) ${order.shipWeight}",
                style: style);
          }
        }
      }

      // Thu hộ
      if (webPrintConfig.showCod)
        printer.printTextLn(
            "Thu hộ ${vietnameseCurrencyFormat(order.cashOnDelivery ?? 0)}",
            style: style);
      // Gạch
      printer.printTextLn("------------------------------------------------",
          style: style);
      printer.printTextLn("Phiếu Bán Hàng",
          lineAfter: 1,
          style: style.copyWith(
              width: PosTextSize.size3, height: PosTextSize.size2));
      printer.printTextLn("Số phiếu: ${order.number}", style: style);
      printer.printTextLn(
          "Ngày: ${DateFormat("dd/MM/yyyy HH:mm").format(order.dateInvoice)}",
          style: style);
      // gạch
      printer.printTextLn("------------------------------------------------",
          style: style);

      style = style.copyWith(align: PosTextAlign.left);
      //  Tên khách hàng
      if (!webPrintConfig.hideCustomerName)
        printer.printTextLn("Khách hàng: ${order.partner?.name}", style: style);
      // Địa chỉ khách hàng
      if (!webPrintConfig.hideAddress)
        printer.printTextLn("Địa chỉ: ${order.partner?.addressFull ?? ""}",
            style: style);

      // Phone khách hàng
      if (!webPrintConfig.hidePhone)
        printer.printTextLn("Điện thoại: ${order.partner?.phone ?? ""}",
            style: style);

      // Tên nhân viên bán
      if (!webPrintConfig.hideStaff)
        printer.printTextLn("Người bán: ${order.userName ?? ""}", style: style);
      // Tên người giao hàng
//      if (!webPrintConfig.hideDelivery)
//        printer.printTextLn("NV giao hàng: ${order.userName}", style: style);

      // Tiêu đề bảng
      printer.printTextLn("------------------------------------------------",
          style: style);
      var columnStyle = PosStyles(align: PosTextAlign.left, bold: true);
      printer.printRow([
        PosColumn(text: "Sản phẩm", width: 4, styles: columnStyle),
        PosColumn(text: "Giá bán", width: 3, styles: columnStyle),
        PosColumn(text: "CK", width: 2, styles: columnStyle),
        PosColumn(text: "Thành tiền", width: 3, styles: columnStyle),
      ]);
      printer.printTextLn("------------------------------------------------",
          style: style);

      if (order.orderLines != null && order.orderLines.length > 0) {
        for (var product in order.orderLines) {
          //Tên sản phẩm
          printer.printTextLn("${product.productNameGet}",
              style: style.copyWith(bold: true));
          // SL, đơn vị, đơn giá, chiết khấu, thành tiền

          printer.printRow([
            PosColumn(
                width: 4,
                text: "${product.productUOMQty} ${product.productUomName}",
                styles: columnStyle.copyWith(
                    bold: false, align: PosTextAlign.left)),
            PosColumn(
                width: 3,
                text: "${vietnameseCurrencyFormat(product.priceUnit ?? 0)}",
                styles: columnStyle.copyWith(
                    bold: false, align: PosTextAlign.left)),
            PosColumn(
                width: 2,
                text: product.discount != null && product.discount > 0
                    ? "${product.discount?.toInt() ?? 0}%"
                    : product.discountFixed != null && product.discountFixed > 0
                        ? "${vietnameseCurrencyFormat(product.discountFixed)} đ  "
                        : "0%",
                styles: columnStyle.copyWith(
                    bold: false, align: PosTextAlign.left)),
            PosColumn(
                width: 3,
                text: "${vietnameseCurrencyFormat(product.priceTotal ?? 0)}",
                styles: columnStyle.copyWith(
                    bold: false, align: PosTextAlign.right)),
          ]);

          printer.printTextLn(
            "------------------------------------------------",
          );
        }
      }

      // Tổng cộng
      printer.printRow([
        PosColumn(
            width: 3,
            text: "Tổng:",
            styles: style.copyWith(bold: true, align: PosTextAlign.left)),
        PosColumn(
            width: 6,
            text: "$productCount",
            styles: style.copyWith(bold: true)),
        PosColumn(
            width: 3,
            text: "${vietnameseCurrencyFormat(order.amountTotal)}",
            styles: style.copyWith(align: PosTextAlign.right, bold: true)),
      ]);

      //  Chiết khấu %
      if (order.discount != null && order.discount > 0) {
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "CK (${order.discount} %):",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(order.discountAmount ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: false)),
        ]);
      }
      //  Chiết khấu tiền
      if (order.decreaseAmount != null && order.decreaseAmount > 0) {
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "Giảm tiền:",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(order.decreaseAmount ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: false)),
        ]);
      }

      // Tiền ship
      if (order.carrierId != null && order.deliveryPrice != null)
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "Tiền ship:",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(order.deliveryPrice ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        ]);

      // Tổng tiền

      printer.printRow([
        PosColumn(
            text: "",
            width: 6,
            styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        PosColumn(
            text: "Tổng  tiền:",
            width: 3,
            styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        PosColumn(
            text:
                "${vietnameseCurrencyFormat((order.amountTotal ?? 0) + (order.deliveryPrice ?? 0))}",
            width: 3,
            styles: style.copyWith(align: PosTextAlign.right, bold: true)),
      ]);

      // Bằng chữ

      if (!webPrintConfig.hideAmountText) {
        var words = convertNumberToWord(
            ((order.amountTotal ?? 0) + (order.deliveryPrice ?? 0))
                .toInt()
                .toString());
        printer.printTextLn("Bằng chữ: $words ./.", style: style);
      }

      // Nợ cũ
      if (!webPrintConfig.hideDebt) {
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "Nợ cũ:",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(order.previousBalance ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        ]);

        // thanh toán
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "Thanh toán:",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(order.paymentAmount ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        ]);
        // thanh toán
        printer.printRow([
          PosColumn(
              text: "",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "TỔNG NỢ:",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
          PosColumn(
              text: "${vietnameseCurrencyFormat(partner.credit ?? 0)}",
              width: 3,
              styles: style.copyWith(align: PosTextAlign.right, bold: true)),
        ]);
      }

      //Ghi chú giao hàng
      if (order.deliveryNote != null)
        printer.printTextLn("Ghi chú GH: ${order.deliveryNote}", style: style);

      //Ghi chú hóa đơn
      if (order.comment != null)
        printer.printTextLn("Ghi chú: ${order.comment ?? ""}", style: style);
      // Ghi chú khác
      if (printerConfig?.note != null)
        printer.printTextLn("Lưu ý: ${printerConfig?.note ?? ""}",
            style: style);
      // Người nhận

      if (!webPrintConfig.hideReceiver) {
        printer.printTextLn(
          "Yêu Cầu",
          style: style.copyWith(
              bold: true,
              align: PosTextAlign.center,
              height: PosTextSize.size2,
              width: PosTextSize.size3),
        );

        printer.printTextLn("------------------------------------------------",
            style: style);
        printer.printTextLn(
          "Giao Hàng",
          style: style.copyWith(
              align: PosTextAlign.center,
              bold: true,
              height: PosTextSize.size2,
              width: PosTextSize.size3),
        );

        if (order.deliveryDate != null) {
          printer.printTextLn(
            "Ngày giao: ${DateFormat("dd/MM/yyyy HH:mm").format(order.deliveryDate)}",
            style: style.copyWith(
                bold: false,
                height: PosTextSize.size1,
                width: PosTextSize.size1),
          );
        }

        printer.printTextLn(
          "Người nhận: ${order.shipReceiver?.name ?? order.partner?.name}",
          style: style.copyWith(
              bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
        );
        printer.printTextLn(
          "Điện thoại: ${order.shipReceiver?.phone ?? order.partner?.phone}",
          style: style.copyWith(
              bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
        );
        printer.printTextLn(
          "Địa chỉ GH: ${order.shipReceiver?.street ?? order.partner?.street} ",
          style: style.copyWith(
              bold: false, height: PosTextSize.size1, width: PosTextSize.size1),
        );
      }

      printer.printTextLn("------------------------------------------------",
          style: style);
      //Kí tên
      if (!webPrintConfig.hideSign) {
        printer.printRow([
          PosColumn(
              text: "Người giao",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.center, bold: true)),
          PosColumn(
              text: "Người nhận:",
              width: 6,
              styles: style.copyWith(align: PosTextAlign.center, bold: true)),
        ]);

        printer.feed(1);
      }

      printer.cut();
    } catch (e, s) {
      _log.severe("print", e, s);
    }

    printer.disconnect();
  }

  Future<void> _printOrderTPosPrinter(PrinterDevice printerDevice,
      {FastSaleOrder order,
      int orderId,
      PrinterConfig printerConfig,
      SaleSetting saleSetting}) async {
    assert(order != null || orderId != null);
    assert(printerConfig != null);

    if (order == null) {
      order = await _fastSaleOrderApi.getById(orderId);
    }

    if (order == null) {
      throw new Exception("Không tải được dữ liệu");
    }

    // Print setting

    var company = await _tposApi.company.getById(order.companyId);
    var partner = await _tposApiService.getPartnerById(order.partnerId);

    PrintFastSaleOrderConfig webPrintConfig = new PrintFastSaleOrderConfig();
    printerConfig.others.forEach((f) {
      switch (f.keyConfig) {
        case Config.hide_address:
          webPrintConfig.hideAddress = f.value;
          break;
        case Config.hide_product_code:
          webPrintConfig.hideProductCode = f.value;
          break;
        case Config.hide_delivery:
          webPrintConfig.hideDelivery = f.value;
          break;
        case Config.hide_debt:
          webPrintConfig.hideDebt = f.value;
          break;
        case Config.hide_logo:
          webPrintConfig.hideLogo = f.value;
          break;
        case Config.hide_receiver:
          webPrintConfig.hideReceiver = f.value;
          break;
        case Config.hide_address:
          webPrintConfig.hideAddress = f.value;
          break;
        case Config.hide_phone:
          webPrintConfig.hidePhone = f.value;
          break;
        case Config.hide_staff:
          webPrintConfig.hideStaff = f.value;
          break;
        case Config.hide_amount_text:
          webPrintConfig.hideAmountText = f.value;
          break;
        case Config.hide_sign:
          webPrintConfig.hideSign = f.value;
          break;
        case Config.hide_TrackingRef:
          webPrintConfig.hideTrackingRef = f.value;
          break;
        case Config.hide_CustomerName:
          webPrintConfig.hideCustomerName = f.value;
          break;
        case Config.showbarcode:
          webPrintConfig.showBarcode = f.value;
          break;
        case Config.showweightship:
          webPrintConfig.showWeightShip = f.value;
          break;
        case Config.hide_product_note:
          webPrintConfig.hideProductNote = f.value;
          break;
        case Config.show_COD:
          webPrintConfig.showCod = f.value;
          break;
        case Config.show_revenue:
          webPrintConfig.showRevenue = f.value;
          break;
        case Config.show_combo:
          webPrintConfig.showCombo = f.value;
          break;
        case Config.show_tracking_ref_sort:
          webPrintConfig.showTrackingRefSoft = f.value;
          break;
      }
    });

    double productCount =
        order.orderLines?.map((f) => f.productUOMQty)?.reduce((a, b) => a + b);

    Printer printer =
        new Printer(printerProfileName: printerDevice.profileName);
    await printer.connect(
        port: printerDevice.port,
        host: printerDevice.ip,
        timeout: Duration(seconds: 5));

    var printData = PrintFastSaleOrderData();
    printData.companyName = company.name;
    printData.companyMoreInfo = company.moreInfo;
    printData.companyPhone = company.phone;
    printData.compnayAddress = company.street;

    printData.carrierName = order.carrierName;
    if (order.trackingRef != null && order.trackingRef != "") {
      printData.shipCode = _getDeliverCarrierBarcode(
          order.carrierDeliveryType, order.trackingRef);
      printData.trackingRef = order.trackingRef;
      printData.trackingRefSort = order.trackingRefSort;
    }

    printData.shipNote = order.deliveryNote;

    printData.cashOnDeliveryAmount = order.cashOnDelivery;
    printData.invoiceNumber = order.number;
    printData.invoiceDate = order.dateInvoice;
    printData.customerName = partner.name;
    printData.customerPhone = partner.phone;
    printData.customerAddress = saleSetting.groupFastSaleAddressFull
        ? partner.addressFull
        : partner.street;

    printData.subTotal = order.subTotal;
    printData.shipAmount = order.deliveryPrice;
    printData.totalAmount = order.amountTotal;
    printData.discount = order.discount;
    printData.discountAmount = order.discountAmount;
    printData.decreaseAmount = order.decreaseAmount;
    printData.oldCredit = order.oldCredit;
    printData.payment = order.paymentAmount;
    printData.totalDeb = partner.credit;
    printData.invoiceNote = order.comment;
    printData.defaultNote = printerConfig?.note;
    printData.receiverPhone = order.receiverPhone;
    printData.receiverAddress = order.receiverAddress;
    printData.receiverName = order.receiverName;
    printData.revenue = order.revenue;
    printData.shipNote = order.deliveryNote;
    printData.hideProductCode = webPrintConfig.hideProductCode;
    printData.hideDelivery = webPrintConfig.hideDelivery;
    printData.hideDebt = webPrintConfig.hideDebt;
    printData.hideLogo = webPrintConfig.hideLogo;
    printData.hideReceiver = webPrintConfig.hideReceiver;
    printData.hideAddress = webPrintConfig.hideAddress;
    printData.hidePhone = webPrintConfig.hidePhone;
    printData.hideStaff = webPrintConfig.hideStaff;

    printData.hideAmountText = webPrintConfig.hideAmountText;
    printData.hideSign = webPrintConfig.hideSign;
    printData.hideTrackingRef = webPrintConfig.hideTrackingRef;
    printData.hideCustomerNam = webPrintConfig.hideCustomerName;
    printData.hideProductNote = webPrintConfig.hideProductNote;
    printData.showBarcode = webPrintConfig.showBarcode;

    printData.showWeightShip = webPrintConfig.showWeightShip;
    printData.showCod = webPrintConfig.showCod;
    printData.showRevenue = webPrintConfig.showRevenue;
    printData.showCombo = webPrintConfig.showCombo;
    printData.showTrackingRefSort = webPrintConfig.showTrackingRefSoft;
    printData.trackingRefToShow = _getDeliveryCarrierCodeToShow(
        order.carrierDeliveryType, order.trackingRef);

    printData.user = order.userName;
    printData.orderLines = order.orderLines;
    printData.totalInWords =
        "${convertNumberToWord((order.amountTotal ?? 0).toInt().toString())} ./.";

    printData.deliveryDate = order.deliveryDate;

    if (webPrintConfig.hideAddress) printData.customerAddress = null;
    if (webPrintConfig.hidePhone) printData.customerPhone = null;
    if (webPrintConfig.hideAmountText) printData.totalInWords = null;
    if (webPrintConfig.hideCustomerName) printData.customerName = null;
    if (webPrintConfig.hideDebt) printData.previousBalance = null;
    if (webPrintConfig.hideTrackingRef) printData.trackingRef = null;
    if (webPrintConfig.hideTrackingRef) printData.trackingRefToShow = null;
    if (webPrintConfig.hideTrackingRef) printData.trackingRefSort = null;
    if (webPrintConfig.hideTrackingRef) printData.shipCode = null;
    if (webPrintConfig.hideTrackingRef) printData.carrierName = null;
    if (webPrintConfig.hideStaff) printData.userDelivery = null;
    if (webPrintConfig.hideStaff) printData.user = null;
    if (webPrintConfig.hidePhone) if (webPrintConfig.hideReceiver) {
      printData.receiverAddress = null;
      printData.receiverName = null;
      printData.receiverPhone = null;
    }

    // show
    if (!webPrintConfig.showWeightShip) printData.shipWeight = null;
    if (!webPrintConfig.showTrackingRefSoft) printData.trackingRefSort = null;
    if (!webPrintConfig.showCod) printData.cashOnDeliveryAmount = null;
    if (!webPrintConfig.showRevenue) printData.revenue = null;
    await _tposDesktop.printFastSaleOrder(
      ip: printerDevice.ip,
      port: printerDevice.port,
      size: "BILL80",
      data: printData,
    );
  }

  @override
  Future<ByteData> printShipImage80mm(PrintShipData data) async {
    CanvasPrinter printer = new CanvasPrinter();
    OrderTemplatePrinter().templateShip(printer, data);
    var result = await printer.generateImage();
    return result;
  }

  @override
  Future<ByteData> printShipGhtkImage80mm(PrintShipData data) async {
    CanvasPrinter printer = new CanvasPrinter();
    OrderTemplatePrinter().templateShipGhtk(printer, data);
    var result = await printer.generateImage();
    return result;
  }

  @override
  Future<ByteData> printFastSaleOrderImage80mm(
      PrintFastSaleOrderData data) async {
    CanvasPrinter printer = new CanvasPrinter();
    OrderTemplatePrinter().templateFastSaleOrder(printer, data);
    var result = await printer.generateImage();
    return result;
  }

  Future<ui.Image> printFastSaleOrderImage80mm2(
      PrintFastSaleOrderData data) async {
    CanvasPrinter printer = new CanvasPrinter();
    OrderTemplatePrinter().templateFastSaleOrder(printer, data);
    var result = await printer.generateImageImg();
    return result;
  }

  /// In sale online lan test
  @override
  Future<void> printSaleOnlineLanTest() async {
    var testOrder = new SaleOnlineOrder();
    testOrder.index = 111;
    testOrder.code = "10000023";
    testOrder.facebookUserId = "1000028347384";
    testOrder.partnerCode = "KH00023";
    testOrder.facebookUserName = "Tên Facebook";
    testOrder.telephone = "0908080808";

    await printSaleOnlineTag(order: testOrder);
  }

  /// In sale online Tpos printer test
  Future printSaleOnlineViaComputerTest() async {
    var data = new PrintSaleOnlineData(
        uid: "10000023049934",
        name: "Nguyễn văn nam",
        code: "KH000001",
        header: "Công ty Trường Minh Thịnh",
        index: 100001,
        time: DateTime.now().toString(),
        partnerCode: "KH000001",
        note: "",
        phone: "0908075555",
        product: "Keo dán ABC");

    await _tposDesktop.printSaleOnline(
        "BILL80", "", "Ghi chú [Comment, địa chỉ....]", data);
  }

  @override
  Future<void> printGame(
      {String name, String uid, String phone, String partnerCode}) async {
    var printData = PrintSaleOnlineData(
        name: "$name (Trúng thưởng game)",
        uid: uid,
        phone: phone,
        partnerCode: partnerCode,
        note: "Đã trúng thưởng");

    if (_setting.printMethod == PrintSaleOnlineMethod.LanPrinter) {
      Printer printer = new Printer();
      try {
        await printer.connect(
            host: _setting.lanPrinterIp,
            port: int.parse(_setting.lanPrinterPort),
            timeout: Duration(seconds: 5));

        var textStyle = PosStyles(
            align: PosTextAlign.center,
            width: PosTextSize.size2,
            height: PosTextSize.size2,
            isRemoveMark: true);
        printer.printTextLn("TRUNG THUONG GAME", style: textStyle);
        printer.printTextLn("Ten: $name", style: textStyle);
        printer.printTextLn("SDT: $phone", style: textStyle);
        printer.printTextLn("UID: $uid", style: textStyle);
        if (partnerCode != null)
          printer.printTextLn("Mã khách hàng: $partnerCode", style: textStyle);
        printer.cut();
      } catch (e, s) {
        _log.severe("", e, s);
      }

      printer?.disconnect();
    } else if (_setting.printMethod == PrintSaleOnlineMethod.ComputerPrinter) {
      await _tposDesktop.printSaleOnline("BILL80", "", "", printData);
    }
  }
}

class PrinterDevice {
  String name;
  String ip;
  int port;
  String type;
  String note;
  bool isDefault = false;
  String profileName = "default";
  bool _isImageRasterPrint = false;
  bool get isImageRasterPrint => _isImageRasterPrint ?? false;
  set isImageRasterPrint(bool value) {
    _isImageRasterPrint = value;
  }

  PrinterDevice(
      {this.name,
      this.ip,
      this.port,
      this.type,
      this.note,
      this.isDefault = false,
      this.profileName = "default",
      bool isImageRasterImage = false}) {
    this._isImageRasterPrint = isImageRasterImage;
  }

  PrinterDevice.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    ip = json["ip"];
    port = json["port"];
    type = json["type"];
    note = json["note"];
    isDefault = json["isDefault"];
    profileName = json["profileName"];
    isImageRasterPrint = json["isImageRasterPrint"];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["ip"] = this.ip;
    data["port"] = this.port;
    data["type"] = this.type;
    data["note"] = this.note;
    data["isDefault"] = this.isDefault;
    data["profileName"] = this.profileName;
    data["isImageRasterPrint"] = this.isImageRasterPrint;
    return data;
  }
}

class NetworkAddress {
  NetworkAddress(this.ip, this.exists);
  bool exists;
  String ip;
}

class NetworkAnalyzer {
  static Future<Socket> _ping(String host, int port, Duration timeout) {
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return socket;
    });
  }

  static Stream<NetworkAddress> discover(
    String subnet,
    int port, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }

    final out = StreamController<NetworkAddress>();
    final futures = <Future<Socket>>[];

    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';
      final Future<Socket> f = _ping(host, port, timeout);
      futures.add(f);

      f.then((socket) {
        socket.destroy();
        socket.close();
        out.sink.add(NetworkAddress(host, true));
      }).catchError((dynamic e) {
        if (!(e is SocketException)) {
          throw e;
        }
        // 13: Connection failed (OS Error: Permission denied)
        // 49: Bind failed (OS Error: Can't assign requested address)
        // 61: OS Error: Connection refused
        // 64: Connection failed (OS Error: Host is down)
        // 65: No route to host
        // 101: Network is unreachable
        // 111: Connection refused
        // 113: No route to host
        // <empty>: SocketException: Connection timed out
        final errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];

        // Check if connection timed out or one of the predefined errors
        if (e.osError == null || errorCodes.contains(e.osError.errorCode)) {
          out.sink.add(NetworkAddress(host, false));
        } else {
          // 23,24: Too many open files in system
          throw e;
        }
      });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) => out.close())
        .catchError((dynamic e) => out.close());

    return out.stream;
  }
}
