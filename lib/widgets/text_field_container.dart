import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextFieldContainer extends StatelessWidget {
  final Function(BuildContext) onTapOutside;
  final TextEditingController controllerTitle;
  final TextEditingController controllerDescription;
  final bool isEditing;
  final Function() onPressedEdit;
  final Function() onPressedAdd;

  const TextFieldContainer(
      {super.key,
      required this.onTapOutside,
      required this.controllerTitle,
      required this.controllerDescription,
      required this.isEditing,
      required this.onPressedEdit,
      required this.onPressedAdd});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => onTapOutside(context),
            controller: controllerTitle,
            decoration: const InputDecoration(
              hintText: "Title...",
              labelText: 'Title',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => onTapOutside(context),
              controller: controllerDescription,
              decoration: const InputDecoration(
                hintText: 'Description...',
                labelText: 'Description',
              )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEditing ? onPressedEdit : onPressedAdd,
            child: Text(
              isEditing ? 'Update' : 'Save',
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
