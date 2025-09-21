import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  static AppLocalizations load(Locale locale) {
    final String name = locale.countryCode?.isEmpty == true ? locale.languageCode : locale.toString();
    final String localeName = intl.Intl.canonicalizedLocale(name);
    return lookupAppLocalizations(localeName);
  }

  static AppLocalizations lookupAppLocalizations(String localeName) {
    switch (localeName) {
      case 'en':
        return AppLocalizationsEn();
      case 'hi':
        return AppLocalizationsHi();
      default:
        throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$localeName". This is likely an issue with the localizations generation tool. Please file an issue on GitHub with a reproducible sample app and the gen-l10n configuration that was used.');
    }
  }

  String get appTitle => 'UserFlow';

  String get homeTitle => 'Users';

  String get profileTitle => 'Profile';

  String get createUserTitle => 'Create User';

  String get editUserTitle => 'Edit User';

  String get userDetailTitle => 'User Details';

  String get firstNameLabel => 'First Name';

  String get lastNameLabel => 'Last Name';

  String get emailLabel => 'Email';

  String get createButton => 'Create';

  String get saveButton => 'Save';

  String get cancelButton => 'Cancel';

  String get deleteButton => 'Delete';

  String get retryButton => 'Retry';

  String get signOutButton => 'Sign Out';

  String get notLoggedInLabel => 'Not logged in';

  String get noUsersAvailable => 'No users available';

  String get errorLoadingUsers => 'Error loading users';

  String get errorLoadingUser => 'Error loading user';

  String get errorCreatingUser => 'Error creating user';

  String get errorDeletingUser => 'Error deleting user';

  String get userCreatedSuccess => 'User created successfully';

  String get userDeletedSuccess => 'User deleted successfully';

  String get deleteUserDialogTitle => 'Delete User';

  String get deleteUserDialogContent => 'Are you sure you want to delete this user? This action cannot be undone.';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations.load(locale));
  }

  @override
  bool isSupported(Locale locale) {
    for (var supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}