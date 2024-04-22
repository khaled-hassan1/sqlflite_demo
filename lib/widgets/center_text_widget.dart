import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class CenterTextWidget extends StatelessWidget {
  const CenterTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).textEmptyList,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Colors.white, fontSize: 30),
      ),
    );
  }
}
