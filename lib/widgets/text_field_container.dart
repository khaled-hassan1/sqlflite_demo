import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import './app_settings.dart';

class TextFieldContainer extends StatelessWidget {
  final FocusNode myFocusNode;
  final S local;
  final Function(BuildContext) onTapOutside;
  final TextEditingController controllerTitle;
  final TextEditingController controllerDescription;
  final bool isEditing;
  final Function() onPressedEdit;
  final Function() onPressedAdd;

  const TextFieldContainer({
    super.key,
    required this.onTapOutside,
    required this.controllerTitle,
    required this.controllerDescription,
    required this.isEditing,
    required this.onPressedEdit,
    required this.onPressedAdd,
    required this.local,
    required this.myFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSettings.all,
      child: Column(
        children: [
          AppSettings.sizedBox(10),
          TextField(
            maxLines: null,
            focusNode: myFocusNode,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => onTapOutside(context),
            controller: controllerTitle,
            decoration: InputDecoration(
              hintText: local.hintTitle,
              labelText: local.labelTitle,
            ),
          ),
          AppSettings.sizedBox(20),
          TextField(
              maxLines: null,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => onTapOutside(context),
              controller: controllerDescription,
              decoration: InputDecoration(
                hintText: local.hintDec,
                labelText: local.labelDec,
              )),
          AppSettings.sizedBox(20),
          ElevatedButton(
            onPressed: isEditing ? onPressedEdit : onPressedAdd,
            child: Text(
              isEditing ? local.edit : local.save,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: AppSettings.deepOrange),
            ),
          ),
          AppSettings.sizedBox(20),
        ],
      ),
    );
  }
}
