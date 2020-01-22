import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoquizadmin/res/values.dart';

class SubTitle extends StatelessWidget {
  final Widget action;
  final String text;

  SubTitle(this.text, {this.action});
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Values.blockSpacing, bottom: Values.normalSpacing),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Values.blockSpacing,
        runAlignment: WrapAlignment.start,
        children: <Widget>[
          Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: Values.pageSubtitle, fontWeight: Values.weightBold),
          ),
          if (action != null)
            action,
        ],
      ),
    );
  }
}