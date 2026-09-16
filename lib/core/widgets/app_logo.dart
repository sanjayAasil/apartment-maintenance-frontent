import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.apartment_rounded,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Apartment Care',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
        ),
      ],
    ],
  );
}
