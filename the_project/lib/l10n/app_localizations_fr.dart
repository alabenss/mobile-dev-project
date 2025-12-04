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
  String get moodFeelingGreat => 'Vous vous sentez très bien';

  @override
  String get moodNice => 'Bien';

  @override
  String get moodOk => 'Moyen';

  @override
  String get moodLow => 'Humeur basse';

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
