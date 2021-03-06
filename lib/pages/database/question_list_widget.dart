import 'package:admin/components/app_button.dart';
import 'package:admin/components/app_integer_selector.dart';
import 'package:admin/components/app_intl_column_view.dart';
import 'package:admin/components/app_intl_resource_form_field.dart';
import 'package:admin/components/app_model_actions.dart';
import 'package:admin/components/app_model_edition_dialog.dart';
import 'package:admin/components/app_model_listview.dart';
import 'package:admin/components/app_subtitle.dart';
import 'package:admin/components/app_type_picker.dart';
import 'package:admin/components/app_window.dart';
import 'package:admin/models/language_model.dart';
import 'package:admin/models/question_model.dart';
import 'package:admin/models/theme_model.dart';
import 'package:admin/pages/database/database_provider.dart';
import 'package:admin/pages/database/database_tools_widget.dart';
import 'package:admin/utils/resource_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class QuestionListWidget extends StatelessWidget {
  final Iterable<LanguageModel> supportedLanguages;
  final List<QuestionModel> questions;
  final ThemeModel selectedTheme;

  QuestionListWidget({
    Key key,
    @required this.selectedTheme,
    @required this.supportedLanguages,
    @required this.questions,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    return Column(
      children: [
        AppSubtitle(
          child: Text("Questions"),
          trailing: [
            AppButton(
              style: AppButtonStyle.ligth,
              onPressed: databaseProvider.selectedTheme == null ? null : () {
                QuestionEditionDialog(
                  databaseProvider: databaseProvider,
                )..show(context);
              },
              child: Text("Add"),
            )
          ],
        ),
        AppModelListView<QuestionModel>(
          weights: [1,1,2,1,8,1,1],
          labels: [Container(), Text("Type"), Text("Entitled"), Text("Type"), Text("Answers (first is correct)"), Text("Difficulty"), Container()],
          models: questions,
          cellsBuilders: <Widget Function(QuestionModel)>[
            (q) =>  AppIntlLanguagesColumn(languages: supportedLanguages),
            (q) =>  Text(q.entitledType.label),
            (q) =>  AppIntlColumnView(
                      languages: supportedLanguages,
                      intlRes: q.entitled
                    ),
            (q) =>  Text(q.answersType.label),
            (q) =>  Row(
                      children: q?.answers?.map((a) => Expanded(
                        flex: 1,
                        child: AppIntlColumnView(
                          languages: supportedLanguages,
                          intlRes: a,
                        ),
                      ))?.toList()??[],
                    ), 
            (q) =>  Text(q.difficulty?.toString()??""),
            (q) =>  ModelActionsWidget(
                      dialog: QuestionEditionDialog(
                        databaseProvider: databaseProvider,
                        inititalQuestion: q,
                      ),
                      onDelete: () => databaseProvider.deleteQuestion(q),
                    )
          ],
        )
      ],
    );
  }
}


class QuestionEditionDialog extends AppModelEditionDialog {
  QuestionEditionDialog({
    Key key,
    QuestionModel inititalQuestion,
    @required DatabaseProvider databaseProvider,
  }) : super(
    key: key,
    initialModel: inititalQuestion,
    databaseProvider: databaseProvider,
  );

  @override
  AppModelEditionDialogState createState() => _QuestionEditionDialogState();
}

class _QuestionEditionDialogState extends AppModelEditionDialogState {
  final minimumNumberOfAnswers = 4;
  final _formKey = GlobalKey<FormState>();
  TypePickerController entitledTypeController;
  IntlResourceEditingController entitledController;
  TypePickerController answersTypeController;
  IntegerSelectorController difficultyController;
  List<IntlResourceEditingController> answerControllers;

  @override
  QuestionEditionDialog get widget => super.widget as QuestionEditionDialog;

  @override
  void initState() {
    super.initState();
    var question = widget.initialModel as QuestionModel;
    entitledTypeController = TypePickerController(initialType: question?.entitledType);
    entitledController = IntlResourceEditingController(resource: question?.entitled);
    answersTypeController = TypePickerController(initialType: question?.answersType);
    difficultyController = IntegerSelectorController(selectedValue: question?.difficulty);
    answerControllers = [];
    question?.answers?.forEach((a) => answerControllers.add(IntlResourceEditingController(resource: a)));
    while (answerControllers.length < minimumNumberOfAnswers) {
      answerControllers.add(IntlResourceEditingController());
    }
  }

  save() {
    if (_formKey.currentState.validate()) {
      var theme = (widget.initialModel as QuestionModel)?.theme??widget.databaseProvider.selectedTheme.id;
      var updatedQuestion = QuestionModel(
        id: widget.initialModel?.id,
        theme: theme,
        entitledType: entitledTypeController.value,
        entitled: entitledController.resource,
        answersType: answersTypeController.value,
        answers: answerControllers.map((c) => c.resource).toList(),
        difficulty: difficultyController.value,
      );
      widget.databaseProvider.saveQuestion(updatedQuestion).then((_) {
        dismiss();
      }).catchError((e) {
        print(e);
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString()),));
      });
    }
  }

  onAddAnswerField() {
    setState(() {
      answerControllers.add(IntlResourceEditingController());
    });
  }

  onRemoveAnswerField() {
    setState(() {
      answerControllers.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppWindow(
      title: Text("Question Edition"),
      bottom: AppButton(
        onPressed: save,
        child: Text("Save"),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTypePicker(
              types: [ResourceType.text, ResourceType.image],
              controller: entitledTypeController,
            ),
            IntlResourceFormField(
              controller: entitledController,
              languages: widget.languages,
              validator: basicIntlValidator,
            ),
            DatabaseToolsWidget(),
            AppTypePicker(
              types: ResourceType.values,
              controller: answersTypeController,
            ),
            ...List.generate(answerControllers.length, (i) => i).map((i) => 
              IntlResourceFormField(
                languages: widget.languages,
                controller: answerControllers.elementAt(i),
                validator: basicIntlValidator,
              ),
            ).toList(),
            Row(
              children: [
                AppButton(
                  style: AppButtonStyle.normal,
                  onPressed: onAddAnswerField,
                  child: Text("Add answer"),
                ),
                AppButton(
                  style: AppButtonStyle.normal,
                  onPressed: answerControllers.length <= minimumNumberOfAnswers ? null : onRemoveAnswerField,
                  child: Text("Remove last answer"),
                ),
              ],
            ),
            IntegerSelector(
              controller: difficultyController,
            )
          ],
        ),
      ),
    );
  }
}