import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../../logic/locale/locale_cubit.dart';
import '../../themes/style_simple/colors.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 2,
        centerTitle: true,
        title: Text(
          l10n.languageScreenTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // System Default Option
                  _LanguageTile(
                    languageName: l10n.languageSystemDefaultTitle,
                    nativeName: l10n.languageSystemDefaultSubtitle,
                    languageCode: 'system',
                    isSelected: localeState.isSystemDefault,
                    icon: Icons.phone_android,
                    onTap: () async {
                      await context.read<LocaleCubit>().useSystemDefault();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.languageSystemDefaultSnack),
                            backgroundColor: AppColors.accentGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      l10n.languageAvailableLanguagesSectionTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Language Options
                  ...LocaleCubit.availableLanguages.map((lang) {
                    final isSelected = !localeState.isSystemDefault &&
                        localeState.locale?.languageCode == lang['code'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LanguageTile(
                        languageName: lang['name']!,
                        nativeName: lang['nativeName']!,
                        languageCode: lang['code']!,
                        isSelected: isSelected,
                        onTap: () async {
                          await context
                              .read<LocaleCubit>()
                              .changeLocale(lang['code']!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.languageChangedSnack(lang['name']!),
                                ),
                                backgroundColor: AppColors.accentGreen,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String languageName;
  final String nativeName;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _LanguageTile({
    required this.languageName,
    required this.nativeName,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPink.withOpacity(0.2)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentPink : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isSelected
                    ? AppColors.accentPink
                    : AppColors.textSecondary,
                size: 28,
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentPink.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    languageCode.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.accentPink
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.accentPink
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentPink,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
