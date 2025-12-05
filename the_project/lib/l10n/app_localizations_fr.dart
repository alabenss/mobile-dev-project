// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get statistics => 'Statistiques';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get weekly => 'Semaine';

  @override
  String get monthly => 'Mois';

  @override
  String get yearly => 'Année';

  @override
  String get waterStats => 'Statistiques d\'eau';

  @override
  String get moodTracking => 'Suivi de l\'humeur';

  @override
  String get journaling => 'Journalisation';

  @override
  String get screenTime => 'Temps d\'écran';

  @override
  String glassesToday(int count) {
    return '$count verres aujourd\'hui';
  }

  @override
  String avgPerDay(int count) {
    return 'Moy. $count verres / jour';
  }

  @override
  String monthlyAvg(Object count) {
    return 'Moyenne mensuelle $count verres';
  }

  @override
  String yearlyAvg(Object count) {
    return 'Moyenne annuelle $count verres';
  }

  @override
  String get youWroteToday => 'Vous avez écrit aujourd\'hui';

  @override
  String get noEntryToday => 'Aucune entrée aujourd\'hui';

  @override
  String daysLogged(int count) {
    return '$count jours enregistrés';
  }

  @override
  String entriesThisMonth(int count) {
    return '$count entrées ce mois';
  }

  @override
  String totalEntries(int count) {
    return '$count entrées au total';
  }

  @override
  String get noData => 'Aucune donnée';

  @override
  String get noMoodData => 'Aucune donnée d’humeur disponible';

  @override
  String get noWaterData => 'Aucune donnée d’eau disponible';

  @override
  String get noScreenTimeData => 'Aucune donnée du temps d’écran';

  @override
  String get moodCalm => 'Calme';

  @override
  String get moodBalanced => 'Équilibré';

  @override
  String get moodLow => 'Humeur basse';

  @override
  String get moodFeelingGreat => 'Vous vous sentez très bien';

  @override
  String get moodNice => 'Bien';

  @override
  String get moodOkay => 'Correct';

  @override
  String get moodFeelingLow => 'Mauvaise humeur';

  @override
  String get statsNoData => 'Aucune donnée';

  @override
  String get statsNoMoodData => 'Aucune donnée d’humeur disponible';

  @override
  String get appLockTitle => 'Verrouillage de l\'application';

  @override
  String get appLockChooseType => 'Choisir le type de verrouillage :';

  @override
  String get appLockPin => 'PIN';

  @override
  String get appLockPinSubtitle => 'Sécuriser avec un code PIN numérique';

  @override
  String get appLockPattern => 'Schéma';

  @override
  String get appLockPatternSubtitle => 'Dessinez un schéma pour déverrouiller';

  @override
  String get appLockPassword => 'Mot de passe';

  @override
  String get appLockPasswordSubtitle => 'Utiliser un mot de passe alphanumérique';

  @override
  String get appLockRemoveExisting => 'Supprimer le verrouillage existant';

  @override
  String appLockSetYour(Object type) {
    return 'Définir votre $type';
  }

  @override
  String appLockConfirmYour(Object type) {
    return 'Confirmer votre $type';
  }

  @override
  String appLockCreateLock(Object type) {
    return 'Créez votre verrou $type';
  }

  @override
  String appLockReenterLock(Object type) {
    return 'Resaisissez votre $type pour confirmer';
  }

  @override
  String get appLockEnterPin => 'Entrez un code PIN de 4 à 6 chiffres';

  @override
  String get appLockConfirmPin => 'Confirmez votre code PIN';

  @override
  String get appLockDrawPattern => 'Dessinez votre schéma';

  @override
  String get appLockDrawPatternAgain => 'Dessinez à nouveau votre schéma';

  @override
  String appLockPointsSelected(Object count) {
    return 'Points sélectionnés : $count';
  }

  @override
  String get appLockRedrawPattern => 'Redessiner le schéma';

  @override
  String get appLockEnterPassword => 'Entrez le mot de passe';

  @override
  String get appLockConfirmPassword => 'Confirmez votre mot de passe';

  @override
  String get appLockMismatch => 'Les valeurs ne correspondent pas.';

  @override
  String get appLockContinue => 'Continuer';

  @override
  String get appLockSaveLock => 'Enregistrer le verrouillage';

  @override
  String get appLockSaved => 'Verrouillage enregistré avec succès.';

  @override
  String get appLockSaveError => 'Erreur lors de l\'enregistrement du verrouillage.';

  @override
  String get appLockRemoved => 'Verrouillage supprimé.';

  @override
  String appLockEnterToUnlock(Object type) {
    return 'Entrez $type pour déverrouiller';
  }

  @override
  String appLockWrongAttempt(Object type) {
    return 'Le $type est incorrect. Veuillez réessayer.';
  }

  @override
  String get appLockUnlock => 'Déverrouiller';

  @override
  String appLockForgotLock(Object type) {
    return '$type oublié ?';
  }

  @override
  String get appLockVerifyIdentity => 'Vérifiez votre identité pour réinitialiser le verrou';

  @override
  String appLockCurrentType(Object type) {
    return 'Verrouillage actuel : $type';
  }

  @override
  String get appLockChangeOrRemove => 'Vous pouvez modifier ou supprimer votre verrouillage actuel.';

  @override
  String get appLockEnabled => 'App Lock Enabled';

  @override
  String get appLockChangeLock => 'Change Lock';

  @override
  String get appLockRemove => 'Remove';

  @override
  String get appLockCurrentSettings => 'Current Settings';

  @override
  String get appLockRemoveConfirm => 'Remove App Lock?';

  @override
  String get appLockRemoveMessage => 'Are you sure you want to remove the app lock?';

  @override
  String get appLockCancel => 'Cancel';

  @override
  String get statsRefreshingData => 'Actualisation des données...';

  @override
  String get statsLoading => 'Chargement des statistiques...';

  @override
  String get statsErrorTitle => 'Une erreur est survenue';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get statsEmptyTitle => 'Aucune donnée';

  @override
  String get statsEmptySubtitle => 'Commencez à utiliser l\'application pour voir vos statistiques';

  @override
  String get statsEmptyTrackMood => 'Suivez votre humeur chaque jour';

  @override
  String get statsEmptyLogWater => 'Enregistrez votre consommation d\'eau';

  @override
  String get statsEmptyWriteJournal => 'Écrivez dans votre journal';

  @override
  String get moodOk => 'Moyen';

  @override
  String get calm => 'Calme';

  @override
  String get balanced => 'Équilibré';

  @override
  String get low => 'Basse';

  @override
  String get social => 'Réseaux sociaux';

  @override
  String get entertainment => 'Divertissement';

  @override
  String get productivity => 'Productivité';

  @override
  String hoursPerDay(Object count) {
    return '$count h/jour';
  }
}
