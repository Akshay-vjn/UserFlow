// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UserFlow';

  @override
  String get loginButton => 'Sign In with Google';

  @override
  String get homeTitle => 'Users';

  @override
  String get profileTitle => 'Profile';

  @override
  String get noNetworkTitle => 'No Internet Connection';

  @override
  String get createUserTitle => 'Create User';

  @override
  String get editUserTitle => 'Edit User';

  @override
  String get userDetailTitle => 'User Detail';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get saveButton => 'Save';

  @override
  String get createButton => 'Create';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteUserDialogTitle => 'Delete User';

  @override
  String get deleteUserDialogContent => 'Are you sure you want to delete this user?';

  @override
  String get noNetworkDescription => 'Please check your internet connection and try again.';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get notLoggedInLabel => 'Not logged in';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get noUsersAvailable => 'No users available';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get retryButton => 'Retry';

  @override
  String get userCreatedSuccess => 'User created successfully';

  @override
  String get errorCreatingUser => 'Error creating user';

  @override
  String get userDeletedSuccess => 'User deleted successfully';

  @override
  String get errorDeletingUser => 'Error deleting user';

  @override
  String get errorLoadingUser => 'Error loading user';
}