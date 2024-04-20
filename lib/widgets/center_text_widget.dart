import 'package:flutter/material.dart';

class CenterTextWidget extends StatelessWidget {
  const CenterTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Add Some Notes!',
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Colors.white, fontSize: 30),
      ),
    );
  }
}
