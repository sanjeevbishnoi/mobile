import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final Widget title;
  final Widget content;
  final String titleString;
  final String contentString;
  final EdgeInsetsGeometry padding;
  final Color titleColor;
  final Color contentColor;
  final TextStyle contentTextStyle;
  InfoRow({
    this.title,
    this.content,
    this.padding =
        const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
    this.contentString,
    this.titleString,
    this.titleColor = Colors.black,
    this.contentColor = Colors.green,
    this.contentTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            title ??
                (new Text(
                  titleString ?? "",
                  style: TextStyle(color: titleColor),
                )),
            Expanded(
              child: content ??
                  (new Text(
                    contentString ?? "",
                    style:
                        contentTextStyle ?? new TextStyle(color: contentColor),
                    textAlign: TextAlign.right,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
