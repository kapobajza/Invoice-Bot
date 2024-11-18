import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_bot/navigation/root_router.dart';
import 'package:invoice_bot/services/storage_service.dart';
import 'package:invoice_bot/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const InvoiceBotApp());
}

final _router = GoRouter(
  routes: [
    $emptyTemplateRoute,
  ],
  redirect: (context, state) async {
    final storageService = StorageProvider.of(context);
    final invoiceTemplates =
        await storageService.getGeneratedInvoiceTemplates();

    return invoiceTemplates == null ? EmptyTemplateRoute().location : null;
  },
);

class InvoiceBotApp extends StatelessWidget {
  const InvoiceBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StorageProvider(
      storage: StorageService(),
      child: MaterialApp.router(
        theme: invoiceBotTheme,
        routerConfig: _router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale.fromSubtags(languageCode: 'en'),
        ],
      ),
    );
  }
}
