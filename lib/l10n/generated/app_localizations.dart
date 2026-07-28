import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Drala'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @setDefaultWallet.
  ///
  /// In en, this message translates to:
  /// **'Set default wallet'**
  String get setDefaultWallet;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @scannedReceipts.
  ///
  /// In en, this message translates to:
  /// **'Scanned receipts'**
  String get scannedReceipts;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @legalConsentPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get legalConsentPrefix;

  /// No description provided for @legalConsentConnector.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get legalConsentConnector;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @collapseMenu.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get collapseMenu;

  /// No description provided for @expandMenu.
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get expandMenu;

  /// No description provided for @envelope.
  ///
  /// In en, this message translates to:
  /// **'Envelope'**
  String get envelope;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @resumeFromDate.
  ///
  /// In en, this message translates to:
  /// **'Resume from a specific date'**
  String get resumeFromDate;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWallet;

  /// No description provided for @walletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletNameLabel;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Savings'**
  String get walletNameHint;

  /// No description provided for @currentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalanceLabel;

  /// No description provided for @editWallet.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get editWallet;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWalletQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this wallet?'**
  String get deleteWalletQuestion;

  /// No description provided for @deleteWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'This wallet will be removed permanently. Its transaction history will remain intact.'**
  String get deleteWalletDescription;

  /// No description provided for @walletUpdated.
  ///
  /// In en, this message translates to:
  /// **'Wallet updated.'**
  String get walletUpdated;

  /// No description provided for @walletDeleted.
  ///
  /// In en, this message translates to:
  /// **'Wallet deleted.'**
  String get walletDeleted;

  /// No description provided for @walletInUseCannotBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'This wallet has transaction history and cannot be deleted.'**
  String get walletInUseCannotBeDeleted;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @showBalance.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get showBalance;

  /// No description provided for @hideBalance.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get hideBalance;

  /// No description provided for @overallBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance left'**
  String get overallBalance;

  /// No description provided for @takenFromEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Taken from envelope {name}'**
  String takenFromEnvelope(String name);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @noNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Budget warnings and important finance updates will appear here.'**
  String get noNotificationsDescription;

  /// No description provided for @envelopeBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'You went over your budget for the {name} envelope.'**
  String envelopeBudgetExceeded(String name);

  /// No description provided for @todayWithDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayWithDate(Object date);

  /// No description provided for @noEntriesForDate.
  ///
  /// In en, this message translates to:
  /// **'No entries for this date'**
  String get noEntriesForDate;

  /// No description provided for @emptyStateWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get emptyStateWelcomeBack;

  /// No description provided for @emptyStateWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get emptyStateWelcomeTo;

  /// No description provided for @emptyStateIncomePrompt.
  ///
  /// In en, this message translates to:
  /// **'Money just landed? Tell me about it so we can celebrate… and log it.'**
  String get emptyStateIncomePrompt;

  /// No description provided for @emptyStateExpensePrompt.
  ///
  /// In en, this message translates to:
  /// **'Spent something fun (or necessary)? Spill how much and on what… I’m keeping the books.'**
  String get emptyStateExpensePrompt;

  /// No description provided for @emptyStateTransferPrompt.
  ///
  /// In en, this message translates to:
  /// **'Moving money around? Tell me the from → to and I’ll make it happen.'**
  String get emptyStateTransferPrompt;

  /// No description provided for @firstEntryIncomePrompt.
  ///
  /// In en, this message translates to:
  /// **'Start by telling me any income you have! Just type something like “I got paid xxx” or “Salary xxx” and I’ll take care of the rest.'**
  String get firstEntryIncomePrompt;

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entryCount(num count);

  /// No description provided for @expenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String expenseCount(num count);

  /// No description provided for @incomeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 income} other{{count} incomes}}'**
  String incomeCount(num count);

  /// No description provided for @transferCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transfer} other{{count} transfers}}'**
  String transferCount(num count);

  /// No description provided for @unlimitedAiRequests.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI requests with Drala Plus'**
  String get unlimitedAiRequests;

  /// No description provided for @aiRequestsRemaining.
  ///
  /// In en, this message translates to:
  /// **'You have {count} AI requests remaining today'**
  String aiRequestsRemaining(Object count);

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Expense, income, or transfer'**
  String get chatHint;

  /// No description provided for @expenseSuggestion.
  ///
  /// In en, this message translates to:
  /// **'I spent X on Y today'**
  String get expenseSuggestion;

  /// No description provided for @incomeSuggestion.
  ///
  /// In en, this message translates to:
  /// **'I received a payment of X'**
  String get incomeSuggestion;

  /// No description provided for @transferSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Transfer X from wallet A to wallet B'**
  String get transferSuggestion;

  /// No description provided for @addReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add receipt'**
  String get addReceipt;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get importFile;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @receiptGalleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your scanned and imported receipts will appear here.'**
  String get receiptGalleryEmpty;

  /// No description provided for @deleteReceiptQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete receipt?'**
  String get deleteReceiptQuestion;

  /// No description provided for @deleteReceiptDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes every page of this receipt.'**
  String get deleteReceiptDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @receiptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted.'**
  String get receiptDeleted;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @receiptPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 receipt page} other{{count} receipt pages}}'**
  String receiptPages(num count);

  /// No description provided for @pageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(num count);

  /// No description provided for @deleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete receipt'**
  String get deleteReceipt;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The new passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from the current one.'**
  String get passwordMustDiffer;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search a currency'**
  String get searchCurrency;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @defaultWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'Expenses and new envelopes use this wallet by default.'**
  String get defaultWalletDescription;

  /// No description provided for @defaultWalletUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default wallet updated.'**
  String get defaultWalletUpdated;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'These terms explain the rules for using Drala.'**
  String get termsIntro;

  /// No description provided for @termsDetails.
  ///
  /// In en, this message translates to:
  /// **'Use Drala only for lawful personal finance management. You remain responsible for checking AI-created entries before relying on them. Service availability may change as the app evolves.'**
  String get termsDetails;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Your financial information belongs to you.'**
  String get privacyIntro;

  /// No description provided for @privacyDetails.
  ///
  /// In en, this message translates to:
  /// **'Drala stores account and transaction data to provide the app. Scanned receipts are kept in private per-user storage and are sent to the configured AI provider through the backend for extraction. You can delete individual receipts from Scanned receipts, or delete all stored data or your complete account from Edit profile.'**
  String get privacyDetails;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: July 21, 2026'**
  String get legalLastUpdated;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminders;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// No description provided for @selectReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Select reminder time'**
  String get selectReminderTime;

  /// No description provided for @preferredReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred reminder time'**
  String get preferredReminderTime;

  /// No description provided for @reminderDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder delivery time'**
  String get reminderDeliveryTime;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to receive daily reminders and budget alerts.'**
  String get notificationPermissionMessage;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications blocked'**
  String get notificationsBlocked;

  /// No description provided for @notificationsBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in your device settings to receive reminders and alerts.'**
  String get notificationsBlockedMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all my data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataSummary.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all app content.'**
  String get deleteAllDataSummary;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSummary.
  ///
  /// In en, this message translates to:
  /// **'Deletes your data and disables your sign-in.'**
  String get deleteAccountSummary;

  /// No description provided for @deleteAllDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get deleteAllDataQuestion;

  /// No description provided for @deleteAllDataDetails.
  ///
  /// In en, this message translates to:
  /// **'Transactions, wallets, envelopes, budgets, goals, AI history, preferences, and files will be deleted. Your account and plan will be retained.'**
  String get deleteAllDataDetails;

  /// No description provided for @deleteKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteKeyword;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm.'**
  String get typeDeleteToConfirm;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All your data has been deleted.'**
  String get allDataDeleted;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'This deletes your account, plan, files, and all your data. It cannot be undone.'**
  String get deleteAccountDetails;

  /// No description provided for @typeValueToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type {value} to confirm.'**
  String typeValueToConfirm(Object value);

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose a source'**
  String get chooseSource;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @mediaPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'We need camera and file access to continue.'**
  String get mediaPermissionMessage;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied.'**
  String get cameraDenied;

  /// No description provided for @mediaDenied.
  ///
  /// In en, this message translates to:
  /// **'Media access denied.'**
  String get mediaDenied;

  /// No description provided for @imageSelectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not select the image.'**
  String get imageSelectionFailed;

  /// No description provided for @usernameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the username.'**
  String get usernameUpdateFailed;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the profile photo.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 8 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least one uppercase letter.'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsLowercase.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least one lowercase letter.'**
  String get passwordNeedsLowercase;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least one number.'**
  String get passwordNeedsNumber;

  /// No description provided for @passwordNeedsSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least one special character.'**
  String get passwordNeedsSpecialCharacter;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In en, this message translates to:
  /// **'8+ characters'**
  String get passwordRuleMinLength;

  /// No description provided for @passwordRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get passwordRuleUppercase;

  /// No description provided for @passwordRuleLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter'**
  String get passwordRuleLowercase;

  /// No description provided for @passwordRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordRuleNumber;

  /// No description provided for @passwordRuleSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get passwordRuleSpecialCharacter;

  /// No description provided for @netThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Net this month'**
  String get netThisMonth;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average / day'**
  String get averagePerDay;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @largestExpense.
  ///
  /// In en, this message translates to:
  /// **'Largest expense'**
  String get largestExpense;

  /// No description provided for @dailySpending.
  ///
  /// In en, this message translates to:
  /// **'Daily spending'**
  String get dailySpending;

  /// No description provided for @topSpending.
  ///
  /// In en, this message translates to:
  /// **'Top spending'**
  String get topSpending;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpensesThisMonth;

  /// No description provided for @moreThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% more than last month'**
  String moreThanLastMonth(String percentage);

  /// No description provided for @lessThanLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% less than last month'**
  String lessThanLastMonth(String percentage);

  /// No description provided for @addEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Add envelope'**
  String get addEnvelope;

  /// No description provided for @createExpenseCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Create an expense category before adding another envelope.'**
  String get createExpenseCategoryFirst;

  /// No description provided for @monthlyEnvelopes.
  ///
  /// In en, this message translates to:
  /// **'Monthly envelopes'**
  String get monthlyEnvelopes;

  /// No description provided for @availableAcrossEnvelopes.
  ///
  /// In en, this message translates to:
  /// **'Available across envelopes'**
  String get availableAcrossEnvelopes;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @newEnvelope.
  ///
  /// In en, this message translates to:
  /// **'New envelope'**
  String get newEnvelope;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @envelopeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries'**
  String get envelopeNameHint;

  /// No description provided for @monthlyAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly amount'**
  String get monthlyAmount;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get expenseCategory;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noEnvelopesYet.
  ///
  /// In en, this message translates to:
  /// **'No envelopes yet'**
  String get noEnvelopesYet;

  /// No description provided for @envelopeEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly amount for an expense category. Chat expenses will update it automatically.'**
  String get envelopeEmptyDescription;

  /// No description provided for @deleteEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Delete envelope'**
  String get deleteEnvelope;

  /// No description provided for @overBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String overBudgetBy(String amount);

  /// No description provided for @amountSpent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String amountSpent(String amount);

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofAmount(String amount);

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think'**
  String get feedbackPrompt;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe an issue or share an idea'**
  String get feedbackHint;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback'**
  String get feedbackRequired;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent. Thank you!'**
  String get feedbackSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
