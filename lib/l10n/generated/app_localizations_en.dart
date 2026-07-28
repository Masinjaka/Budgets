// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Drala';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePassword => 'Change password';

  @override
  String get preferences => 'Preferences';

  @override
  String get notification => 'Notification';

  @override
  String get currency => 'Currency';

  @override
  String get setDefaultWallet => 'Set default wallet';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get scannedReceipts => 'Scanned receipts';

  @override
  String get legal => 'Legal';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get legalConsentPrefix => 'I agree to the ';

  @override
  String get legalConsentConnector => ' and the ';

  @override
  String get logOut => 'Log out';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get menu => 'Menu';

  @override
  String get collapseMenu => 'Collapse menu';

  @override
  String get expandMenu => 'Expand menu';

  @override
  String get envelope => 'Envelope';

  @override
  String get stats => 'Stats';

  @override
  String get feedback => 'Feedback';

  @override
  String get resumeFromDate => 'Resume from a specific date';

  @override
  String get wallets => 'Wallets';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get walletNameLabel => 'Wallet name';

  @override
  String get walletNameHint => 'e.g. Savings';

  @override
  String get currentBalanceLabel => 'Current balance';

  @override
  String get editWallet => 'Edit wallet';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String get deleteWalletQuestion => 'Delete this wallet?';

  @override
  String get deleteWalletDescription =>
      'This wallet will be removed permanently. Its transaction history will remain intact.';

  @override
  String get walletUpdated => 'Wallet updated.';

  @override
  String get walletDeleted => 'Wallet deleted.';

  @override
  String get walletInUseCannotBeDeleted =>
      'This wallet has transaction history and cannot be deleted.';

  @override
  String get allTime => 'All time';

  @override
  String get showBalance => 'Show balance';

  @override
  String get hideBalance => 'Hide balance';

  @override
  String get overallBalance => 'Wallet balance left';

  @override
  String takenFromEnvelope(String name) {
    return 'Taken from envelope $name';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsDescription =>
      'Budget warnings and important finance updates will appear here.';

  @override
  String envelopeBudgetExceeded(String name) {
    return 'You went over your budget for the $name envelope.';
  }

  @override
  String todayWithDate(Object date) {
    return 'Today, $date';
  }

  @override
  String get noEntriesForDate => 'No entries for this date';

  @override
  String get emptyStateWelcomeBack => 'Welcome back!';

  @override
  String get emptyStateWelcomeTo => 'Welcome to';

  @override
  String get emptyStateIncomePrompt =>
      'Money just landed? Tell me about it so we can celebrate… and log it.';

  @override
  String get emptyStateExpensePrompt =>
      'Spent something fun (or necessary)? Spill how much and on what… I’m keeping the books.';

  @override
  String get emptyStateTransferPrompt =>
      'Moving money around? Tell me the from → to and I’ll make it happen.';

  @override
  String get firstEntryIncomePrompt =>
      'Start by telling me any income you have! Just type something like “I got paid xxx” or “Salary xxx” and I’ll take care of the rest.';

  @override
  String entryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String incomeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incomes',
      one: '1 income',
    );
    return '$_temp0';
  }

  @override
  String transferCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transfers',
      one: '1 transfer',
    );
    return '$_temp0';
  }

  @override
  String get unlimitedAiRequests => 'Unlimited AI requests with Drala Plus';

  @override
  String aiRequestsRemaining(Object count) {
    return 'You have $count AI requests remaining today';
  }

  @override
  String get chatHint => 'Expense, income, or transfer';

  @override
  String get expenseSuggestion => 'I spent X on Y today';

  @override
  String get incomeSuggestion => 'I received a payment of X';

  @override
  String get transferSuggestion => 'Transfer X from wallet A to wallet B';

  @override
  String get addReceipt => 'Add receipt';

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get send => 'Send';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get importFile => 'Import file';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get receiptGalleryEmpty =>
      'Your scanned and imported receipts will appear here.';

  @override
  String get deleteReceiptQuestion => 'Delete receipt?';

  @override
  String get deleteReceiptDescription =>
      'This removes every page of this receipt.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get receiptDeleted => 'Receipt deleted.';

  @override
  String get receipt => 'Receipt';

  @override
  String receiptPages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipt pages',
      one: '1 receipt page',
    );
    return '$_temp0';
  }

  @override
  String pageCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get deleteReceipt => 'Delete receipt';

  @override
  String get save => 'Save';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get user => 'User';

  @override
  String get currentPassword => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmNewPassword => 'Confirm your new password';

  @override
  String get passwordsDoNotMatch => 'The new passwords do not match.';

  @override
  String get passwordMustDiffer =>
      'Choose a password different from the current one.';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get searchCurrency => 'Search a currency';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get defaultWalletDescription =>
      'Expenses and new envelopes use this wallet by default.';

  @override
  String get defaultWalletUpdated => 'Default wallet updated.';

  @override
  String get termsIntro => 'These terms explain the rules for using Drala.';

  @override
  String get termsDetails =>
      'Use Drala only for lawful personal finance management. You remain responsible for checking AI-created entries before relying on them. Service availability may change as the app evolves.';

  @override
  String get privacyIntro => 'Your financial information belongs to you.';

  @override
  String get privacyDetails =>
      'Drala stores account and transaction data to provide the app. Scanned receipts are kept in private per-user storage and are sent to the configured AI provider through the backend for extraction. You can delete individual receipts from Scanned receipts, or delete all stored data or your complete account from Edit profile.';

  @override
  String get legalLastUpdated => 'Last updated: July 21, 2026';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get dailyReminders => 'Daily reminders';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get selectReminderTime => 'Select reminder time';

  @override
  String get preferredReminderTime => 'Preferred reminder time';

  @override
  String get reminderDeliveryTime => 'Daily reminder delivery time';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get notificationPermissionMessage =>
      'Allow notifications to receive daily reminders and budget alerts.';

  @override
  String get allow => 'Allow';

  @override
  String get deny => 'Deny';

  @override
  String get notificationsBlocked => 'Notifications blocked';

  @override
  String get notificationsBlockedMessage =>
      'Allow notifications in your device settings to receive reminders and alerts.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get deleteAllData => 'Delete all my data';

  @override
  String get deleteAllDataSummary => 'Permanently deletes all app content.';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountSummary =>
      'Deletes your data and disables your sign-in.';

  @override
  String get deleteAllDataQuestion => 'Delete all data?';

  @override
  String get deleteAllDataDetails =>
      'Transactions, wallets, envelopes, budgets, goals, AI history, preferences, and files will be deleted. Your account and plan will be retained.';

  @override
  String get deleteKeyword => 'DELETE';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm.';

  @override
  String get allDataDeleted => 'All your data has been deleted.';

  @override
  String get deleteAccountQuestion => 'Permanently delete account?';

  @override
  String get deleteAccountDetails =>
      'This deletes your account, plan, files, and all your data. It cannot be undone.';

  @override
  String typeValueToConfirm(Object value) {
    return 'Type $value to confirm.';
  }

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get chooseSource => 'Choose a source';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get mediaPermissionMessage =>
      'We need camera and file access to continue.';

  @override
  String get cameraDenied => 'Camera access denied.';

  @override
  String get mediaDenied => 'Media access denied.';

  @override
  String get imageSelectionFailed => 'Could not select the image.';

  @override
  String get usernameUpdateFailed => 'Could not update the username.';

  @override
  String get profilePhotoUploadFailed => 'Could not upload the profile photo.';

  @override
  String get back => 'Back';

  @override
  String get enterEmail => 'Enter an email address';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get enterPassword => 'Enter a password';

  @override
  String get passwordMinLength =>
      'The password must contain at least 8 characters.';

  @override
  String get passwordNeedsUppercase =>
      'The password must contain at least one uppercase letter.';

  @override
  String get passwordNeedsLowercase =>
      'The password must contain at least one lowercase letter.';

  @override
  String get passwordNeedsNumber =>
      'The password must contain at least one number.';

  @override
  String get passwordNeedsSpecialCharacter =>
      'The password must contain at least one special character.';

  @override
  String get passwordRuleMinLength => '8+ characters';

  @override
  String get passwordRuleUppercase => 'At least one uppercase letter';

  @override
  String get passwordRuleLowercase => 'At least one lowercase letter';

  @override
  String get passwordRuleNumber => 'At least one number';

  @override
  String get passwordRuleSpecialCharacter => 'At least one special character';

  @override
  String get netThisMonth => 'Net this month';

  @override
  String get transactions => 'Transactions';

  @override
  String get averagePerDay => 'Average / day';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get largestExpense => 'Largest expense';

  @override
  String get dailySpending => 'Daily spending';

  @override
  String get topSpending => 'Top spending';

  @override
  String get noExpensesThisMonth => 'No expenses this month';

  @override
  String moreThanLastMonth(String percentage) {
    return '$percentage% more than last month';
  }

  @override
  String lessThanLastMonth(String percentage) {
    return '$percentage% less than last month';
  }

  @override
  String get addEnvelope => 'Add envelope';

  @override
  String get createExpenseCategoryFirst =>
      'Create an expense category before adding another envelope.';

  @override
  String get monthlyEnvelopes => 'Monthly envelopes';

  @override
  String get availableAcrossEnvelopes => 'Available across envelopes';

  @override
  String get budget => 'Budget';

  @override
  String get spent => 'Spent';

  @override
  String get newEnvelope => 'New envelope';

  @override
  String get name => 'Name';

  @override
  String get envelopeNameHint => 'e.g. Groceries';

  @override
  String get monthlyAmount => 'Monthly amount';

  @override
  String get expenseCategory => 'Expense category';

  @override
  String get saving => 'Saving…';

  @override
  String get create => 'Create';

  @override
  String get noEnvelopesYet => 'No envelopes yet';

  @override
  String get envelopeEmptyDescription =>
      'Set a monthly amount for an expense category. Chat expenses will update it automatically.';

  @override
  String get deleteEnvelope => 'Delete envelope';

  @override
  String overBudgetBy(String amount) {
    return 'Over budget by $amount';
  }

  @override
  String amountSpent(String amount) {
    return '$amount spent';
  }

  @override
  String ofAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get feedbackPrompt => 'Tell us what you think';

  @override
  String get feedbackHint => 'Describe an issue or share an idea';

  @override
  String get feedbackRequired => 'Please enter your feedback';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get feedbackSent => 'Feedback sent. Thank you!';
}
