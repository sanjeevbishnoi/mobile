import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/printer_helper/my_canvas_printer.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/sale_online/models/tpos_desktop/print_fast_sale_order_data.dart';
import 'package:tpos_mobile/sale_online/models/tpos_desktop/print_ship_data.dart';

class OrderTemplatePrinter {
  void templateShip(CanvasPrinter printer, PrintShipData data) {
    if (data.companyName != null) {
      printer.printTextLn("${data.companyName}",
          style: CanvasStyles(bold: true, fontSize: 50));
    }

    if (data.companyAddress != null) {
      printer.emptyLines(10);
      printer.printTextLn("Địa chỉ: ${data.companyAddress}",
          style: CanvasStyles(bold: true));
    }

    if (data.companyPhone != null) {
      printer.emptyLines(10);
      printer.printTextLn("SĐT: ${data.companyPhone}");
    }

    if (data.staff != null) {
      printer.emptyLines(10);
      printer.printTextLn("Nhân viên: ${data.staff}");
    }

    if (data.carrierName != null) {
      printer.emptyLines(1);
      printer.printTextLn(
        "${data.carrierName}",
        style: CanvasStyles(
          align: TextAlign.center,
          bold: false,
        ),
      );
    }
    if (data.trackingRefSort != null) {
      printer.emptyLines(1);
      printer.printTextLn(
        "${data.trackingRefSort}",
        style: CanvasStyles(
          align: TextAlign.center,
          bold: true,
        ),
      );
    }
    if (data.shipCode != null) {
      printer.printBarCode(
        "${data.shipCode}",
        height: 100,
        hasText: false,
      );
      printer.printTextLn(
        "${data.trackingRefToShow}",
        style: CanvasStyles(
          bold: true,
          align: TextAlign.center,
        ),
      );
    }

    if (data.cashOnDeliveryPrice != null) {
      printer.emptyLines(25);
      printer.printTextLn(
        "Thu hộ ${vietnameseCurrencyFormat(data.cashOnDeliveryPrice)} VND",
        style: CanvasStyles(
          align: TextAlign.center,
          bold: true,
          fontSize: 50,
        ),
      );
    }

    if (data.invoiceAmount != null || data.deliveryPrice != null) {
      printer.emptyLines(5);
      print(data.deliveryPrice);
      printer.printTextLn(
        "${data.invoiceAmount == null || data.deliveryPrice == null ? "" : "("}"
        "${data.invoiceAmount != null ? "Tiền hàng: ${vietnameseCurrencyFormat(data.invoiceAmount)}" : ""}"
        "${data.invoiceAmount == null || data.deliveryPrice == null ? "" : " + "}"
        "${data.deliveryPrice != null ? "Tiền ship: ${vietnameseCurrencyFormat(data.deliveryPrice)}" : ""}"
        "${data.invoiceAmount == null || data.deliveryPrice == null ? "" : ")"}",
        style: CanvasStyles(
          bold: true,
          align: TextAlign.center,
        ),
      );
    }

    if (data.invoiceNumber != null) {
      printer.emptyLines(5);
      printer.printTextLn("${data.invoiceNumber}",
          style: CanvasStyles(bold: true, align: TextAlign.center));
    }

    if (data.invoiceDate != null) {
      printer.emptyLines(5);
      printer.printTextLn(
          "Ngày: ${DateFormat("dd/MM/yyyy").format(data.invoiceDate)}",
          style: CanvasStyles(bold: true, align: TextAlign.center));
    }

    if (data.receiverName != null) {
      printer.emptyLines(25);
      printer.printTextSpans(textSpans: [
        CanvasTextSpan(
          "Người nhận: ",
          style: CanvasStyles(bold: true),
        ),
        CanvasTextSpan(
          "${data.receiverName}",
          style: CanvasStyles(),
        ),
      ]);
    }

    if (data.receiverAddress != null) {
      printer.emptyLines(25);
      printer.printTextSpans(textSpans: [
        CanvasTextSpan(
          "Địa chỉ: ",
          style: CanvasStyles(bold: true),
        ),
        CanvasTextSpan(
          "${data.receiverAddress}",
          style: CanvasStyles(),
        ),
      ]);
    }

    if (data.receiverPhone != null) {
      printer.emptyLines(25);
      printer.printTextSpans(textSpans: [
        CanvasTextSpan(
          "SĐT: ",
          style: CanvasStyles(bold: true),
        ),
        CanvasTextSpan(
          "${data.receiverPhone}",
          style: CanvasStyles(),
        ),
      ]);
    }

    if (data.shipNote != null) {
      printer.emptyLines(10);
      printer.printTextLn(
        "Ghi chú giao hàng: ${data.shipNote}",
        style: CanvasStyles(
          align: TextAlign.left,
        ),
      );
    }

    if (data.note != null) {
      printer.emptyLines(10);
      printer.printTextLn("Ghi chú: ${data.note}");
    }
  }

  void templateShipGhtk(CanvasPrinter printer, PrintShipData data) {
    //printer.kCanvasSizeWidth = (printer.paperWidth * 50 / 80);
    //printer.kCanvasSizeHeight = (printer.paperWidth * 50 / 80);
    //printer.hasBorder = true;
    printer.setUp(
      isHasBorder: true,
      width: (printer.paperWidth * 50 / 80),
      height: (printer.paperWidth * 50 / 80),
    );
    printer.setUpCanvasHeader(
      canvasHeader: CanvasHeader(
          headerImage: CanvasImage(
            url: "giaohangtietkiem.vn/wp-content/uploads/2015/10/logo.png",
          ),
          title: HeaderTitle(title: "Giaohangtietkiem.vn")),
    );
    if (data.shipCode != null) {
      printer.emptyLines(10);
      printer.printBarCode("${data.shipCode}", lineWidth: 2, height: 60);
    }
    if (data.trackingRefToShow != null) {
      printer.emptyLines(5);
      printer.printTextLn(
        "${data.trackingRefToShow}",
        style: CanvasStyles(
          bold: true,
          align: TextAlign.center,
        ),
      );
    }
    if (data.trackingRefGHTK != null) {
      printer.emptyLines(10);
      printer.printTextLn(
        "${data.trackingRefGHTK}",
        hasBorder: true,
        style: CanvasStyles(
          bold: true,
          align: TextAlign.center,
        ),
      );
    }
    printer.emptyLines(6);
    printer.printTextLn(
      "${data.receiverName != null ? "${data.receiverName}" : ""}"
      "${data.receiverPhone != null ? ", ${data.receiverPhone}" : ""}"
      "${data.receiverAddress != null ? ", ${data.receiverAddress}" : ""}"
      "${data.receiverWardName != null ? ", ${data.receiverWardName}" : ""}"
      "${data.receiverDictrictName != null ? ", ${data.receiverDictrictName}" : ""}"
      "${data.receiverCityName != null ? ", ${data.receiverCityName}" : ""}"
      "${data.invoiceNumber != null ? ", ${data.invoiceNumber}" : ""}",
      style: CanvasStyles(fontSize: 18),
    );
  }

  void templateFastSaleOrder(
      CanvasPrinter printer, PrintFastSaleOrderData data) {
    printer.fontFamily = "";

    // Tên công ty
    if (data.companyName != null) {
      printer.printTextLn(
        "${data.companyName}",
        style: CanvasStyles(align: TextAlign.center, bold: true, fontSize: 40),
      );
    }
    if (data.companyMoreInfo != null) {
      printer.printTextLn(
        "${data.companyMoreInfo}",
        style: CanvasStyles(
          align: TextAlign.center,
        ),
      );
    }
    if (data.compnayAddress != null) {
      printer.printTextLn(
        "${data.compnayAddress}",
        style: CanvasStyles(
          align: TextAlign.center,
        ),
      );
    }
    if (data.companyPhone != null) {
      printer.printTextLn(
        "${data.companyPhone}",
        style: CanvasStyles(
          align: TextAlign.center,
        ),
      );
    }

    if (data.carrierName != null) {
      printer.printTextLn(
        "${data.carrierName}",
        style: CanvasStyles(
          align: TextAlign.center,
        ),
      );
    }

    if (data.shipCode != null) {
      printer.printBarCode("${data.shipCode}", height: 60, lineWidth: 2.8);
    }

    if (data.trackingRefToShow != null) {
      printer.printTextLn(
        "${data.trackingRefToShow}",
        style: CanvasStyles(
          align: TextAlign.center,
          bold: true,
        ),
      );
    }

    if (data.shipWeight != null) {
      printer.printTextSpans(center: true, textSpans: [
        CanvasTextSpan(
          "KL ship (g): ",
          style: CanvasStyles(bold: true),
        ),
        CanvasTextSpan(
          "${data.shipWeight.toInt()}",
          style: CanvasStyles(),
        ),
      ]);
    }

    if (data.cashOnDeliveryAmount != null) {
      printer.printTextSpans(
        center: true,
        textSpans: [
          CanvasTextSpan(
            "Thu hộ: ",
            style: CanvasStyles(),
          ),
          CanvasTextSpan(
            "${vietnameseCurrencyFormat(data.cashOnDeliveryAmount)}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    printer.emptyLines(18);

    printer.printDividerDash();

    printer.emptyLines(25);
    printer.printTextLn(
      "PHIẾU BÁN HÀNG",
      style: CanvasStyles(align: TextAlign.center, fontSize: 50),
    );
    printer.emptyLines(25);
    if (data.invoiceNumber != null) {
      printer.printTextSpans(
        center: true,
        textSpans: [
          CanvasTextSpan(
            "Số phiếu: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.invoiceNumber}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.invoiceDate != null) {
      printer.printTextSpans(
        center: true,
        textSpans: [
          CanvasTextSpan(
            "Ngày: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${getDate(data.invoiceDate)} ${getTime(data.invoiceDate)}",
            style: CanvasStyles(),
          ),
        ],
      );
    }
    printer.emptyLines(18);
    if (data.invoiceNumber != null || data.invoiceDate != null) {
      printer.printDividerDash();
    }
    printer.emptyLines(10);
    if (data.customerName != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Khách hàng: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.customerName}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.customerAddress != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Địa chỉ: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.customerAddress}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.customerPhone != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Điện thoại: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.customerPhone}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.user != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Người bán: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.user}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.userDelivery != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "NV giao hàng: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.userDelivery}",
            style: CanvasStyles(),
          ),
        ],
      );
    }
    printer.emptyLines(10);
    printer.printDividerDash(lineDash: LineDash(dashSpace: 0));
    printer.printRow(
      [
        CanvasColumn(
          text: "Sản phẩm",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
        CanvasColumn(
          text: "Giá bán",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
        CanvasColumn(
          text: "CK",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
        CanvasColumn(
          text: "Thành tiền",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
      ],
    );
    printer.printDividerDash(lineDash: LineDash(dashSpace: 0));

    var qty = 0.0;
    if (data.orderLines != null) {
      data.orderLines.forEach((item) {
        qty = qty + item.productUOMQty;
        printer.printTextLn(
          "${item.nameTemplate ?? " "}",
          style: CanvasStyles(bold: true),
        );
        printer.emptyLines(10);
        printer.printRow(
          [
            CanvasColumn(
              text:
                  "${item.productUOMQty?.toInt() ?? " "} ${item.productUomName ?? " "}",
              width: 3,
              styles: CanvasStyles(
                bold: false,
                align: TextAlign.start,
              ),
            ),
            CanvasColumn(
              text: "${vietnameseCurrencyFormat(item.priceUnit ?? 0)}",
              width: 3,
              styles: CanvasStyles(
                bold: false,
                align: TextAlign.center,
              ),
            ),
            CanvasColumn(
              text: item.discount != null && item.discount > 0
                  ? "${item.discount?.toInt() ?? 0}%"
                  : item.discountFixed != null && item.discountFixed > 0
                      ? "${vietnameseCurrencyFormat(item.discountFixed)} đ  "
                      : "0%",
              width: 3,
              styles: CanvasStyles(
                bold: false,
                align: TextAlign.center,
              ),
            ),
            CanvasColumn(
              text: "${vietnameseCurrencyFormat(item.priceTotal ?? 0)}",
              width: 3,
              styles: CanvasStyles(
                bold: false,
                align: TextAlign.end,
              ),
            ),
          ],
        );
        printer.printDividerDash(lineDash: LineDash(dashSpace: 0));
      });
    }

    printer.emptyLines(5);
    printer.printRow(
      [
        CanvasColumn(
          text: "Tổng:",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
        CanvasColumn(
          text: "SL: ${qty.toInt()}",
          width: 3,
          styles: CanvasStyles(bold: true),
        ),
        CanvasColumn(
          text: "${vietnameseCurrencyFormat(data.subTotal ?? 0)}",
          width: 6,
          styles: CanvasStyles(
            bold: true,
            align: TextAlign.end,
          ),
        ),
      ],
    );
    //Chiết khấu %
    if (data.discount != null && data.discount != 0) {
      printer.emptyLines(10);
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "CK (${data.discount} %):",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.discountAmount ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    }
    //Giảm tiền
    if (data.decreaseAmount != null && data.decreaseAmount != 0) {
      printer.emptyLines(10);
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "Giảm tiền:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.decreaseAmount ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    }
    //Tiền ship
    if (data.shipAmount != null) {
      printer.emptyLines(10);
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "Tiền ship:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.shipAmount ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    }

    printer.emptyLines(10);
    if (data.totalAmount != null)
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "Tổng tiền:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.totalAmount ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    printer.emptyLines(10);

    if (data.totalInWords != null)
      printer.printTextLn(
        "Bằng chữ:",
        style: CanvasStyles(
          bold: true,
        ),
      );
    if (data.totalInWords != null)
      printer.printTextLn(
        data.totalInWords,
        style: CanvasStyles(
          bold: true,
        ),
      );
    printer.emptyLines(10);
    if (data.previousBalance != null)
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "Nợ cũ:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.previousBalance ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    printer.emptyLines(10);
    if (data.payment != null)
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "Thanh toán:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.payment)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );

    printer.emptyLines(10);
    if (data.totalDeb != null)
      printer.printRow(
        [
          CanvasColumn(
            text: " ",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "TỔNG NỢ:",
            width: 6,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
          CanvasColumn(
            text: "${vietnameseCurrencyFormat(data.totalDeb ?? 0)}",
            width: 3,
            styles: CanvasStyles(
              bold: true,
              align: TextAlign.end,
            ),
          ),
        ],
      );
    if (data.shipNote != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Ghi chú GH: ",
            style: CanvasStyles(bold: true, fontSize: 25),
          ),
          CanvasTextSpan(
            "${data.shipNote}",
            style: CanvasStyles(fontSize: 25),
          ),
        ],
      );
    }

    printer.emptyLines(10);
    if (data.invoiceNote != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Ghi chú: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.invoiceNote}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    if (data.revenue != null) {
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Doanh số: ",
            style: CanvasStyles(bold: true, fontSize: 40),
          ),
          CanvasTextSpan(
            "${vietnameseCurrencyFormat(data.revenue ?? 0)}",
            style: CanvasStyles(fontSize: 40),
          ),
        ],
      );
    }

    if (!data.hideDelivery) {
      printer.printTextLn(
        "YÊU CẦU",
        style: CanvasStyles(
          fontSize: 50,
          bold: true,
          align: TextAlign.center,
        ),
      );
      printer.emptyLines(20);
      printer.printDividerDash();
      printer.emptyLines(10);
      printer.printTextLn(
        "GIAO HÀNG",
        style: CanvasStyles(
          fontSize: 50,
          bold: true,
          align: TextAlign.center,
        ),
      );
      printer.emptyLines(20);
      if (data.receiverName != null) {
        printer.printTextSpans(
          textSpans: [
            CanvasTextSpan(
              "Người nhận: ",
              style: CanvasStyles(bold: true, fontSize: 40),
            ),
            CanvasTextSpan(
              "${data.receiverName}",
              style: CanvasStyles(fontSize: 40),
            ),
          ],
        );
      }
      if (data.receiverPhone != null) {
        printer.printTextSpans(
          textSpans: [
            CanvasTextSpan(
              "Điện thoại: ",
              style: CanvasStyles(bold: true, fontSize: 40),
            ),
            CanvasTextSpan(
              "${data.receiverPhone}",
              style: CanvasStyles(fontSize: 40),
            ),
          ],
        );
      }
      if (data.receiverAddress != null) {
        printer.printTextSpans(
          textSpans: [
            CanvasTextSpan(
              "Địa chỉ GH: ",
              style: CanvasStyles(bold: true, fontSize: 40),
            ),
            CanvasTextSpan(
              "${data.receiverAddress}",
              style: CanvasStyles(fontSize: 40),
            ),
          ],
        );
      }
    }

    if (data.defaultNote != null) {
      printer.emptyLines(10);
      printer.printTextSpans(
        textSpans: [
          CanvasTextSpan(
            "Lưu ý: ",
            style: CanvasStyles(bold: true),
          ),
          CanvasTextSpan(
            "${data.defaultNote}",
            style: CanvasStyles(),
          ),
        ],
      );
    }

    printer.printDividerDash();
    printer.emptyLines(60);
  }
}
