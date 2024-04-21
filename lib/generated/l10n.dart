// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `My Notes`
  String get appName {
    return Intl.message(
      'My Notes',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `My Notes`
  String get title {
    return Intl.message(
      'My Notes',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Title...`
  String get hintTitle {
    return Intl.message(
      'Title...',
      name: 'hintTitle',
      desc: '',
      args: [],
    );
  }

  /// `Description...`
  String get hintDec {
    return Intl.message(
      'Description...',
      name: 'hintDec',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get labelTitle {
    return Intl.message(
      'Title',
      name: 'labelTitle',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get labelDec {
    return Intl.message(
      'Description',
      name: 'labelDec',
      desc: '',
      args: [],
    );
  }

  /// `Notes: `
  String get countNotes {
    return Intl.message(
      'Notes: ',
      name: 'countNotes',
      desc: '',
      args: [],
    );
  }

  /// `Add Some Notes!`
  String get emptyList {
    return Intl.message(
      'Add Some Notes!',
      name: 'emptyList',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
