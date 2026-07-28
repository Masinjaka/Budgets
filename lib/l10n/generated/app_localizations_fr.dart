// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Drala';

  @override
  String get settings => 'Paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get preferences => 'Préférences';

  @override
  String get notification => 'Notifications';

  @override
  String get currency => 'Devise';

  @override
  String get setDefaultWallet => 'Portefeuille par défaut';

  @override
  String get theme => 'Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get scannedReceipts => 'Reçus numérisés';

  @override
  String get legal => 'Mentions légales';

  @override
  String get termsOfService => 'Conditions d’utilisation';

  @override
  String get termsAndConditions => 'Conditions générales';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get legalConsentPrefix => 'J’accepte les ';

  @override
  String get legalConsentConnector => ' et la ';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get menu => 'Menu';

  @override
  String get collapseMenu => 'Réduire le menu';

  @override
  String get expandMenu => 'Développer le menu';

  @override
  String get envelope => 'Enveloppes';

  @override
  String get stats => 'Statistiques';

  @override
  String get feedback => 'Avis';

  @override
  String get resumeFromDate => 'Reprendre à une date précise';

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get addWallet => 'Ajouter un portefeuille';

  @override
  String get walletNameLabel => 'Nom du portefeuille';

  @override
  String get walletNameHint => 'ex. Épargne';

  @override
  String get currentBalanceLabel => 'Solde actuel';

  @override
  String get editWallet => 'Modifier le portefeuille';

  @override
  String get deleteWallet => 'Supprimer le portefeuille';

  @override
  String get deleteWalletQuestion => 'Supprimer ce portefeuille ?';

  @override
  String get deleteWalletDescription =>
      'Ce portefeuille sera supprimé définitivement. Son historique de transactions restera intact.';

  @override
  String get walletUpdated => 'Portefeuille modifié.';

  @override
  String get walletDeleted => 'Portefeuille supprimé.';

  @override
  String get walletInUseCannotBeDeleted =>
      'Ce portefeuille contient un historique de transactions et ne peut pas être supprimé.';

  @override
  String get allTime => 'Depuis toujours';

  @override
  String get showBalance => 'Afficher le solde';

  @override
  String get hideBalance => 'Masquer le solde';

  @override
  String get overallBalance => 'Solde restant des portefeuilles';

  @override
  String takenFromEnvelope(String name) {
    return 'Prélevé sur l’enveloppe $name';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get noNotificationsDescription =>
      'Les alertes de budget et les informations financières importantes apparaîtront ici.';

  @override
  String envelopeBudgetExceeded(String name) {
    return 'Vous avez dépassé le budget de l’enveloppe $name.';
  }

  @override
  String todayWithDate(Object date) {
    return 'Aujourd’hui, $date';
  }

  @override
  String get noEntriesForDate => 'Aucune entrée pour cette date';

  @override
  String get emptyStateWelcomeBack => 'Bon retour !';

  @override
  String get emptyStateWelcomeTo => 'Bienvenue sur';

  @override
  String get emptyStateIncomePrompt =>
      'Une rentrée d’argent ? Dites-m’en plus pour qu’on puisse célébrer… et l’enregistrer.';

  @override
  String get emptyStateExpensePrompt =>
      'Une dépense plaisir (ou nécessaire) ? Dites-moi combien et pour quoi… je tiens les comptes.';

  @override
  String get emptyStateTransferPrompt =>
      'Un transfert d’argent ? Indiquez-moi le compte de départ → d’arrivée et je m’en occupe.';

  @override
  String get firstEntryIncomePrompt =>
      'Commencez par m’indiquer vos revenus ! Écrivez simplement « J’ai reçu xxx » ou « Salaire xxx » et je m’occupe du reste.';

  @override
  String entryCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '1 entrée',
      zero: '0 entrée',
    );
    return '$_temp0';
  }

  @override
  String expenseCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dépenses',
      one: '1 dépense',
      zero: '0 dépense',
    );
    return '$_temp0';
  }

  @override
  String incomeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revenus',
      one: '1 revenu',
      zero: '0 revenu',
    );
    return '$_temp0';
  }

  @override
  String transferCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transferts',
      one: '1 transfert',
      zero: '0 transfert',
    );
    return '$_temp0';
  }

  @override
  String get unlimitedAiRequests => 'Requêtes IA illimitées avec Drala Plus';

  @override
  String aiRequestsRemaining(Object count) {
    return 'Il vous reste $count requêtes IA aujourd’hui';
  }

  @override
  String get chatHint => 'Dépense, revenu ou transfert';

  @override
  String get expenseSuggestion => 'J’ai dépensé X pour Y aujourd’hui';

  @override
  String get incomeSuggestion => 'J’ai reçu un paiement de X';

  @override
  String get transferSuggestion =>
      'Transférer X du portefeuille A au portefeuille B';

  @override
  String get addReceipt => 'Ajouter un reçu';

  @override
  String get manualEntry => 'Saisie manuelle';

  @override
  String get send => 'Envoyer';

  @override
  String get enterManually => 'Saisir manuellement';

  @override
  String get importFile => 'Importer un fichier';

  @override
  String get scanReceipt => 'Numériser un reçu';

  @override
  String get receiptGalleryEmpty =>
      'Vos reçus numérisés et importés apparaîtront ici.';

  @override
  String get deleteReceiptQuestion => 'Supprimer ce reçu ?';

  @override
  String get deleteReceiptDescription =>
      'Toutes les pages de ce reçu seront supprimées.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get receiptDeleted => 'Reçu supprimé.';

  @override
  String get receipt => 'Reçu';

  @override
  String receiptPages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages de reçu',
      one: '1 page de reçu',
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
  String get deleteReceipt => 'Supprimer le reçu';

  @override
  String get save => 'Enregistrer';

  @override
  String get username => 'Nom d’utilisateur';

  @override
  String get enterUsername => 'Saisissez votre nom d’utilisateur';

  @override
  String get user => 'Utilisateur';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get enterCurrentPassword => 'Saisissez votre mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get enterNewPassword => 'Saisissez votre nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmNewPassword => 'Confirmez votre nouveau mot de passe';

  @override
  String get passwordsDoNotMatch =>
      'Les nouveaux mots de passe ne correspondent pas.';

  @override
  String get passwordMustDiffer =>
      'Choisissez un mot de passe différent de l’actuel.';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour.';

  @override
  String get searchCurrency => 'Rechercher une devise';

  @override
  String errorWithMessage(Object message) {
    return 'Erreur : $message';
  }

  @override
  String get defaultWalletDescription =>
      'Les dépenses et les nouvelles enveloppes utilisent ce portefeuille par défaut.';

  @override
  String get defaultWalletUpdated => 'Portefeuille par défaut mis à jour.';

  @override
  String get termsIntro =>
      'Ces conditions expliquent les règles d’utilisation de Drala.';

  @override
  String get termsDetails =>
      'Utilisez Drala uniquement pour gérer légalement vos finances personnelles. Vous restez responsable de la vérification des entrées créées par l’IA avant de vous y fier. La disponibilité du service peut évoluer avec l’application.';

  @override
  String get privacyIntro => 'Vos informations financières vous appartiennent.';

  @override
  String get privacyDetails =>
      'Drala conserve les données de compte et de transaction nécessaires au fonctionnement de l’application. Les reçus numérisés sont stockés dans un espace privé propre à chaque utilisateur et transmis au fournisseur d’IA configuré via le backend pour extraction. Vous pouvez supprimer un reçu depuis Reçus numérisés, toutes vos données ou votre compte complet depuis Modifier le profil.';

  @override
  String get legalLastUpdated => 'Dernière mise à jour : 21 juillet 2026';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get dailyReminders => 'Rappels quotidiens';

  @override
  String get budgetAlerts => 'Alertes de budget';

  @override
  String get selectReminderTime => 'Choisir l’heure du rappel';

  @override
  String get preferredReminderTime => 'Heure de rappel préférée';

  @override
  String get reminderDeliveryTime => 'Heure d’envoi du rappel quotidien';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get notificationPermissionMessage =>
      'Autorisez les notifications pour recevoir les rappels quotidiens et les alertes de budget.';

  @override
  String get allow => 'Autoriser';

  @override
  String get deny => 'Refuser';

  @override
  String get notificationsBlocked => 'Notifications bloquées';

  @override
  String get notificationsBlockedMessage =>
      'Autorisez les notifications dans les paramètres de votre appareil pour recevoir les rappels et alertes.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAllData => 'Supprimer toutes mes données';

  @override
  String get deleteAllDataSummary =>
      'Efface définitivement tout le contenu de l’application.';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountSummary =>
      'Efface vos données et désactive votre connexion.';

  @override
  String get deleteAllDataQuestion => 'Supprimer toutes les données ?';

  @override
  String get deleteAllDataDetails =>
      'Les transactions, portefeuilles, enveloppes, budgets, objectifs, l’historique IA, les préférences et les fichiers seront supprimés. Votre compte et votre formule seront conservés.';

  @override
  String get deleteKeyword => 'SUPPRIMER';

  @override
  String get typeDeleteToConfirm => 'Saisissez SUPPRIMER pour confirmer.';

  @override
  String get allDataDeleted => 'Toutes vos données ont été supprimées.';

  @override
  String get deleteAccountQuestion => 'Supprimer définitivement le compte ?';

  @override
  String get deleteAccountDetails =>
      'Cette action supprime votre compte, votre formule, vos fichiers et toutes vos données. Elle est irréversible.';

  @override
  String typeValueToConfirm(Object value) {
    return 'Saisissez $value pour confirmer.';
  }

  @override
  String get accountDeleted => 'Votre compte a été supprimé.';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get chooseSource => 'Choisir une source';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get mediaPermissionMessage =>
      'Nous avons besoin de la caméra et de l’accès aux fichiers pour continuer.';

  @override
  String get cameraDenied => 'Accès à la caméra refusé.';

  @override
  String get mediaDenied => 'Accès aux médias refusé.';

  @override
  String get imageSelectionFailed => 'Impossible de sélectionner l’image.';

  @override
  String get usernameUpdateFailed =>
      'Impossible de mettre à jour le nom d’utilisateur.';

  @override
  String get profilePhotoUploadFailed =>
      'Impossible de téléverser la photo de profil.';

  @override
  String get back => 'Retour';

  @override
  String get enterEmail => 'Saisissez une adresse e-mail';

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get enterPassword => 'Saisissez un mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get passwordNeedsUppercase =>
      'Le mot de passe doit contenir au moins une majuscule.';

  @override
  String get passwordNeedsLowercase =>
      'Le mot de passe doit contenir au moins une minuscule.';

  @override
  String get passwordNeedsNumber =>
      'Le mot de passe doit contenir au moins un chiffre.';

  @override
  String get passwordNeedsSpecialCharacter =>
      'Le mot de passe doit contenir au moins un caractère spécial.';

  @override
  String get passwordRuleMinLength => '8 caractères ou plus';

  @override
  String get passwordRuleUppercase => 'Au moins une lettre majuscule';

  @override
  String get passwordRuleLowercase => 'Au moins une lettre minuscule';

  @override
  String get passwordRuleNumber => 'Au moins un chiffre';

  @override
  String get passwordRuleSpecialCharacter => 'Au moins un caractère spécial';

  @override
  String get netThisMonth => 'Solde net du mois';

  @override
  String get transactions => 'Transactions';

  @override
  String get averagePerDay => 'Moyenne / jour';

  @override
  String get expenses => 'Dépenses';

  @override
  String get income => 'Revenus';

  @override
  String get largestExpense => 'Plus grande dépense';

  @override
  String get dailySpending => 'Dépenses quotidiennes';

  @override
  String get topSpending => 'Principales dépenses';

  @override
  String get noExpensesThisMonth => 'Aucune dépense ce mois-ci';

  @override
  String moreThanLastMonth(String percentage) {
    return '$percentage % de plus que le mois dernier';
  }

  @override
  String lessThanLastMonth(String percentage) {
    return '$percentage % de moins que le mois dernier';
  }

  @override
  String get addEnvelope => 'Ajouter une enveloppe';

  @override
  String get createExpenseCategoryFirst =>
      'Créez une catégorie de dépense avant d’ajouter une autre enveloppe.';

  @override
  String get monthlyEnvelopes => 'Enveloppes mensuelles';

  @override
  String get availableAcrossEnvelopes => 'Disponible dans les enveloppes';

  @override
  String get budget => 'Budget';

  @override
  String get spent => 'Dépensé';

  @override
  String get newEnvelope => 'Nouvelle enveloppe';

  @override
  String get name => 'Nom';

  @override
  String get envelopeNameHint => 'ex. Courses';

  @override
  String get monthlyAmount => 'Montant mensuel';

  @override
  String get expenseCategory => 'Catégorie de dépense';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get create => 'Créer';

  @override
  String get noEnvelopesYet => 'Aucune enveloppe';

  @override
  String get envelopeEmptyDescription =>
      'Définissez un montant mensuel pour une catégorie de dépense. Les dépenses saisies dans le chat la mettront automatiquement à jour.';

  @override
  String get deleteEnvelope => 'Supprimer l’enveloppe';

  @override
  String overBudgetBy(String amount) {
    return 'Budget dépassé de $amount';
  }

  @override
  String amountSpent(String amount) {
    return '$amount dépensés';
  }

  @override
  String ofAmount(String amount) {
    return 'sur $amount';
  }

  @override
  String get feedbackPrompt => 'Dites-nous ce que vous en pensez';

  @override
  String get feedbackHint => 'Décrivez un problème ou partagez une idée';

  @override
  String get feedbackRequired => 'Veuillez saisir votre avis';

  @override
  String get sendFeedback => 'Envoyer l’avis';

  @override
  String get feedbackSent => 'Avis envoyé. Merci !';
}
