import 'package:admin/models/model.dart';
import 'package:admin/pages/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class AppModelEditionDialog<T extends Model> extends StatefulWidget {
  final T initialModel;
  final DatabaseProvider databaseProvider;
  List<String> get languages => databaseProvider.languages.map((l) => l.isoCode2).toList();

  show(context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: this
      ),
    );
  }

  AppModelEditionDialog({
    Key key,
    @required this.initialModel,
    @required this.databaseProvider
  }) : super(key: key);

  @override
  AppModelEditionDialogState createState();
}

abstract class AppModelEditionDialogState<T> extends State<AppModelEditionDialog> {

  dismiss() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}