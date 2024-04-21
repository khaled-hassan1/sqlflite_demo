import 'package:flutter/material.dart';

import '../generated/l10n.dart';

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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            focusNode: myFocusNode,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => onTapOutside(context),
            controller: controllerTitle,
            decoration: InputDecoration(
              hintText: local.hintTitle,
              labelText: local.labelTitle,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => onTapOutside(context),
              controller: controllerDescription,
              decoration: InputDecoration(
                hintText: local.hintDec,
                labelText: local.labelDec,
              )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEditing ? onPressedEdit : onPressedAdd,
            child: Text(
              isEditing ? local.edit : local.save,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.deepOrange),
            ),
          )
        ],
      ),
    );
  }
}
