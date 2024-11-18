import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invoice_bot/modules/invoice_template/invoice_template.dart';

enum StorageKey {
  generatedInvoiceTemplates,
}

class StorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<T?> _read<T>(StorageKey key) async {
    final value = await _storage.read(key: key.toString());

    if (value == null) {
      return null;
    }

    if (T is String) {
      return value as T;
    }

    return json.decode(value).cast<T>();
  }

  Future<void> _write<T>(StorageKey key, T value) async {
    if (value is String) {
      return _storage.write(key: key.toString(), value: value);
    }

    return _storage.write(key: key.toString(), value: json.encode(value));
  }

  Future<void> _delete(StorageKey key) async {
    await _storage.delete(key: key.toString());
  }

  Future<List<InvoiceTemplate>?> getGeneratedInvoiceTemplates() async {
    final value = await _read<List<InvoiceTemplate>>(
      StorageKey.generatedInvoiceTemplates,
    );

    return value;
  }

  Future<void> setGeneratedInvoiceTemplates(
    List<InvoiceTemplate> templates,
  ) async {
    await _write(
      StorageKey.generatedInvoiceTemplates,
      templates,
    );
  }

  Future<void> deleteGeneratedInvoiceTemplates() async {
    _delete(StorageKey.generatedInvoiceTemplates);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}

class StorageProvider extends InheritedWidget {
  final StorageService _storage;

  const StorageProvider({
    super.key,
    required StorageService storage,
    required super.child,
  }) : _storage = storage;

  static StorageService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StorageProvider>()!
        ._storage;
  }

  @override
  bool updateShouldNotify(StorageProvider oldWidget) => false;
}
