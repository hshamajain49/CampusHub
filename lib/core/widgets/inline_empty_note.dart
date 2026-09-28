import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class InlineEmptyNote extends StatelessWidget {
  final String message;
  const InlineEmptyNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(child: Text(message, style: AppTextStyles.bodySecondary)),
    );
  }
}
