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
  String get noMoodData => 'Aucune donnée d\'humeur disponible';

  @override
  String get noWaterData => 'Aucune donnée d\'eau disponible';

  @override
  String get noScreenTimeData => 'Aucune donnée du temps d\'écran';

  @override
  String get moodCalm => 'Calme';

  @override
  String get moodBalanced => 'Équilibré';

  @override
  String get moodLow => 'Bas';

  @override
  String get moodFeelingGreat => 'Très bien';

  @override
  String get moodNice => 'Bonne humeur';

  @override
  String get moodOkay => 'Correct';

  @override
  String get moodFeelingLow => 'Mauvaise humeur';

  @override
  String get statsNoData => 'Aucune donnée';

  @override
  String get statsNoMoodData => 'Aucune donnée d\'humeur disponible';

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

  @override
  String get addNewHabit => 'Ajouter une nouvelle habitude';

  @override
  String get selectHabit => 'Sélectionner une habitude';

  @override
  String get customHabitName => 'Nom personnalisé de l\'habitude';

  @override
  String get customHabit => 'Habitude personnalisée';

  @override
  String get frequency => 'Fréquence';

  @override
  String get rewardPoints => 'Points de récompense';

  @override
  String get pointsEarnedOnCompletion => 'Points gagnés à la complétion';

  @override
  String get customizeReward => 'Personnalisez la récompense pour cette habitude';

  @override
  String get time => 'Heure';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String get setReminder => 'Définir un rappel';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String habitAlreadyExists(String frequency) {
    return 'Cette habitude existe déjà avec une fréquence $frequency !';
  }

  @override
  String get pointsMustBeGreaterThanZero => 'Les points doivent être supérieurs à 0 !';

  @override
  String get habitDrinkWater => 'Boire de l\'eau';

  @override
  String get habitExercise => 'Exercice';

  @override
  String get habitMeditate => 'Méditer';

  @override
  String get habitRead => 'Lire';

  @override
  String get habitSleepEarly => 'Dormir tôt';

  @override
  String get habitStudy => 'Étudier';

  @override
  String get habitWalk => 'Marcher';

  @override
  String get habitOther => 'Autre';

  @override
  String get noHabitsYet => 'Aucune habitude pour l\'instant !\nAppuyez sur + pour ajouter votre première habitude';

  @override
  String get todaysHabits => 'Habitudes d\'aujourd\'hui';

  @override
  String get completed => 'Terminé';

  @override
  String get skipped => 'Ignoré';

  @override
  String get skipHabit => 'Ignorer l\'habitude ?';

  @override
  String skipHabitConfirmation(String habit) {
    return 'Voulez-vous vraiment ignorer \"$habit\" ?';
  }

  @override
  String get skip => 'Ignorer';

  @override
  String get deleteHabit => 'Supprimer l\'habitude ?';

  @override
  String deleteHabitConfirmation(String habit) {
    return 'Voulez-vous vraiment supprimer définitivement \"$habit\" ?';
  }

  @override
  String get actionCannotBeUndone => 'Cette action ne peut pas être annulée.';

  @override
  String get delete => 'Supprimer';

  @override
  String habitCompleted(String habit) {
    return '$habit terminé !';
  }

  @override
  String habitSkipped(String habit) {
    return '$habit ignoré';
  }

  @override
  String habitDeleted(String habit) {
    return '🗑️ $habit supprimé';
  }

  @override
  String get noDailyHabits => 'Aucune habitude quotidienne pour l\'instant';

  @override
  String get noWeeklyHabits => 'Aucune habitude hebdomadaire pour l\'instant';

  @override
  String get noMonthlyHabits => 'Aucune habitude mensuelle pour l\'instant';

  @override
  String get tapToAddHabit => 'Appuyez sur le bouton + pour ajouter une habitude';
}
