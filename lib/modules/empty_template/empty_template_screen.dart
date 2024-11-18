import 'package:flutter/material.dart';
import 'package:invoice_bot/theme/spacing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyTemplateScreen extends StatelessWidget {
  const EmptyTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.emptyTemplates_appBarTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(image: AssetImage('assets/images/logo/logo.png')),
            SizedBox(height: spacing.x10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.x4),
              child: Text(
                t.emptyTemplates_noTemplateDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: spacing.x4),
            FilledButton(
              onPressed: () {},
              child: Text(t.emptyTemplates_newTemplate),
            ),
          ],
        ),
      ),
    );
  }
}
