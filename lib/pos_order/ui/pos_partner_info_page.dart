import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/ui/pos_partner_add_edit_page.dart';
import 'package:tpos_mobile/widgets/info_row.dart';

class PosPartnerInfoPage extends StatefulWidget {
  PosPartnerInfoPage(this.partner);
  final Partners partner;

  @override
  _PosPartnerInfoPageState createState() => _PosPartnerInfoPageState();
}

class _PosPartnerInfoPageState extends State<PosPartnerInfoPage> {
  TextStyle detailFontStyle;
  TextStyle titleFontStyle;

  @override
  Widget build(BuildContext context) {
    titleFontStyle = TextStyle(color: Colors.green);
    detailFontStyle = TextStyle(color: Colors.green);
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin khách hàng"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) =>
                        new PosPartnerAddEditPage(widget.partner)),
              );
            },
          )
        ],
      ),
      body: _buildPartnerInfo(),
    );
  }

  Widget _buildPartnerInfo() {
    var dividerMin = new Divider(
      height: 2,
    );
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 6,
          ),
          Text(
            "${widget.partner.name}",
            style: detailFontStyle.copyWith(
                fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 15.0,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[400],
                        offset: Offset(0, 3),
                        blurRadius: 3)
                  ]),
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: <Widget>[
                  InfoRow(
                    contentTextStyle: titleFontStyle,
                    titleString: "Mã vạch: ",
                    content: Text("${widget.partner.barcode ?? "N/A"}",
                        textAlign: TextAlign.right, style: detailFontStyle),
                  ),
                  dividerMin,
                  InfoRow(
                    contentTextStyle: titleFontStyle,
                    titleString: "Mã số thuế:",
                    content: Text("${widget.partner.taxCode ?? ""}",
                        textAlign: TextAlign.right, style: detailFontStyle),
                  ),
                  dividerMin,
                  InfoRow(
                    contentTextStyle: titleFontStyle,
                    titleString: "Số điện thoại:",
                    content: Text("${widget.partner.phone ?? ""}",
                        textAlign: TextAlign.right, style: detailFontStyle),
                  ),
                  dividerMin,
                  InfoRow(
                    contentTextStyle: titleFontStyle,
                    titleString: "Email:",
                    content: Text("${widget.partner.email ?? ""}",
                        textAlign: TextAlign.right, style: detailFontStyle),
                  ),
                  dividerMin,
                  InfoRow(
                    contentTextStyle: titleFontStyle,
                    titleString: "Địa chỉ:",
                    content: Text("${widget.partner.street ?? ""}",
                        textAlign: TextAlign.right, style: detailFontStyle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
