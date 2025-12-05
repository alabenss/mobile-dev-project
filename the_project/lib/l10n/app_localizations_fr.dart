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

  @override
  String get detoxProgress => 'Progrès de détox';

  @override
  String get detoxExcellent => 'Excellent progrès !';

  @override
  String get detoxGood => 'Bon progrès';

  @override
  String get detoxModerate => 'Progrès modéré';

  @override
  String get detoxLow => 'Continuez';

  @override
  String get detoxStart => 'Début';

  @override
  String get detoxInfo => 'Progrès moyen de détox pour la période sélectionnée';

  @override
  String failedToLoadActivities(String error) {
    return 'Échec du chargement des activités\\n$error';
  }

  @override
  String get breathingTitle => 'Respiration';

  @override
  String get breathingDescription => 'Prenez une grande inspiration et laissez votre corps se détendre\\npour la fin de la journée.';

  @override
  String get breathingStart => 'Commencer';

  @override
  String get breathingStop => 'Arrêter';

  @override
  String get bubblePopperTitle => 'Pop It';

  @override
  String get bubblePopperDescription => 'Trouvez le calme et la concentration en faisant éclater le stress, bulle après bulle.';

  @override
  String get coloringTitle => 'Coloriage';

  @override
  String get coloringSaved => 'Enregistré ! (export à venir plus tard)';

  @override
  String get coloringPickColorTitle => 'Choisissez une couleur';

  @override
  String get coloringHue => 'Teinte';

  @override
  String get coloringSaturation => 'Saturation';

  @override
  String get coloringBrightness => 'Luminosité';

  @override
  String get coloringOpacity => 'Opacité';

  @override
  String get coloringUseColor => 'Utiliser la couleur';

  @override
  String get coloringTemplateSpace => 'Espace';

  @override
  String get coloringTemplateGarden => 'Jardin';

  @override
  String get coloringTemplateFish => 'Poisson';

  @override
  String get coloringTemplateButterfly => 'Papillon';

  @override
  String get coloringTemplateHouse => 'Maison';

  @override
  String get coloringTemplateMandala => 'Mandala';

  @override
  String coloringLoadError(String error) {
    return 'Erreur lors du chargement de la page de coloriage :\\n$error';
  }

  @override
  String get growPlantTitle => 'Fais pousser la plante';

  @override
  String get growPlantHeadline => 'Prends soin de ta plante avec de l\'eau et de la lumière.\\nUtilise des points d\'activité pour l\'aider à grandir !';

  @override
  String growPlantStars(int count) {
    return 'Étoiles : $count';
  }

  @override
  String get growPlantStage => 'Étape';

  @override
  String growPlantAvailablePoints(int count) {
    return 'Points disponibles : $count';
  }

  @override
  String get growPlantGetPoints => 'Obtenir des points';

  @override
  String get growPlantWaterLabel => 'Eau';

  @override
  String get growPlantSunlightLabel => 'Lumière du soleil';

  @override
  String growPlantWaterAction(int cost) {
    return 'Eau ($cost)';
  }

  @override
  String growPlantSunAction(int cost) {
    return 'Soleil ($cost)';
  }

  @override
  String growPlantWaterHelper(int cost) {
    return 'Dépenser $cost pts';
  }

  @override
  String growPlantSunHelper(int cost) {
    return 'Dépenser $cost pts';
  }

  @override
  String get growPlantTip => 'Astuce : lorsque les deux barres sont pleines, ta plante passe au niveau suivant.';

  @override
  String get paintingTitle => 'Dessiner';

  @override
  String get paintingPrompt => 'Prenez une grande inspiration, choisissez votre couleur et laissez votre créativité s\'exprimer.';

  @override
  String get paintingSaved => 'Image enregistrée !.';

  @override
  String get paintingColorsTitle => 'Couleurs';

  @override
  String get paintingHue => 'Teinte';

  @override
  String get paintingSaturation => 'Saturation';

  @override
  String get paintingValue => 'Valeur';

  @override
  String get paintingOpacity => 'Opacité';

  @override
  String get paintingUseColor => 'Utiliser la couleur';

  @override
  String get puzzleTitle => 'Puzzle';

  @override
  String get puzzleInstruction => 'Faites glisser les tuiles pour les remettre dans le bon ordre.';

  @override
  String get puzzleShuffle => 'Mélanger';

  @override
  String get puzzleReset => 'Réinitialiser';

  @override
  String get puzzleSolved => 'Résolu ! 🎉';

  @override
  String get plantArticleTitle => 'L\'effet apaisant des plantes';

  @override
  String get plantArticleIntro => 'La verdure fait plus que décorer votre espace — elle apaise votre esprit. Prendre soin d\'une plante vous ralentit et ramène votre attention au moment présent.';

  @override
  String get plantArticleBenefitsTitle => 'Bénéfices en un coup d\'œil';

  @override
  String get plantArticleBullet1 => 'Réduit le stress et la fatigue mentale';

  @override
  String get plantArticleBullet2 => 'Améliore la concentration et la créativité';

  @override
  String get plantArticleBullet3 => 'Ajoute une touche de couleur naturelle à votre pièce';

  @override
  String get plantArticleBullet4 => 'Crée un petit rituel quotidien (arroser, tailler, observer)';

  @override
  String get plantArticleQuote => '« Cultiver un jardin, c\'est nourrir non seulement le corps, mais aussi l\'âme. »';

  @override
  String get plantArticleTipTitle => 'Astuce du jour';

  @override
  String get plantArticleTipBody => 'Placez une petite plante près de l\'endroit où vous travaillez le plus. Vérifiez-la une fois par jour — une pause de 30 secondes pour votre esprit.';

  @override
  String get plantArticleFooter => 'Continuez de grandir — une feuille à la fois 🌿';

  @override
  String get sportArticleTitle => 'Booster votre humeur avec le sport';

  @override
  String get sportArticleHeroText => 'Un peu de mouvement\\ncrée beaucoup d\'émotion 💪✨';

  @override
  String get sportArticleIntro => 'Bouger votre corps est l’un des moyens les plus rapides pour améliorer votre humeur. L’activité libère des endorphines — les “hormones du bien-être” de votre cerveau.';

  @override
  String get sportArticleEasyWaysTitle => 'Des façons simples de commencer';

  @override
  String get sportArticleBullet1 => 'Marche de 5–10 minutes après les repas';

  @override
  String get sportArticleBullet2 => 'Petite danse sur une chanson pendant le café';

  @override
  String get sportArticleBullet3 => 'Étirements légers devant la télé';

  @override
  String get sportArticleBullet4 => 'Invitez un ami pour un petit jogging ou une balade à vélo';

  @override
  String get sportArticleQuote => 'Présentez-vous pendant 5 minutes. La plupart du temps, c’est tout ce qu’il faut pour démarrer.';

  @override
  String get sportArticleRememberTitle => 'À retenir';

  @override
  String get sportArticleRememberBody => 'Choisissez un mouvement qui vous fait sourire — pas seulement transpirer. La joie crée la régularité, et la régularité améliore l’humeur.';

  @override
  String get sportArticleStartActivityCta => 'Commencer une activité';
}
