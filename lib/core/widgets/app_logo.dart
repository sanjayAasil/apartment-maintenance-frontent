import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.apartment_rounded, size: 32),
      if (!compact) ...[
        const SizedBox(width: 10),
        Text('Apartment Care', style: Theme.of(context).textTheme.titleLarge),
      ],
    ],
  );
}
