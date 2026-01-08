import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../themes/style_simple/colors.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/locale/locale_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().refreshUserData();
    });
  }

  String _formatJoinedDate(String? dateString) {
    final l10n = AppLocalizations.of(context)!;

    if (dateString == null || dateString.isEmpty) {
      return l10n.profileJoinedRecently;
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      return l10n.profileJoinedRecently;
    }
  }

  String _getLanguageDisplayName(LocaleState localeState) {
    final l10n = AppLocalizations.of(context)!;

    if (localeState.isSystemDefault || localeState.locale == null) {
      return l10n.languageSystemDefaultTitle;
    }

    switch (localeState.locale!.languageCode) {
      case 'en':
        return l10n.languageEnglish;
      case 'fr':
        return l10n.languageFrench;
      case 'ar':
        return l10n.languageArabic;
      default:
        return l10n.languageEnglish;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 2,
        centerTitle: true,
        title: Text(
          l10n.profileTitle,
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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          final user = authState.user;

          if (user == null) {
            return Center(
              child: Text(l10n.profileNoUserLoggedIn),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
  color: AppColors.accentPink,
  onRefresh: () async {
    await context.read<AuthCubit>().refreshUserData();
  },
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              AppColors.accentPink.withOpacity(0.2),
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentPink,
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentPink,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.profileEditPictureComingSoon,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Full Name
                    Text(
                      user.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Username
                    Text(
                      '@${user.username}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Points and Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                color: AppColors.accentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${user.totalPoints} ${l10n.profilePointsLabel}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${user.stars} ${l10n.profileStarsLabel}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Editable Info Fields
                    _ProfileField(
                      label: 'First Name',
                      value: user.firstName,
                      icon: Icons.person_outline,
                      editable: true,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          'Edit First Name',
                          user.firstName,
                          (newValue) async {
                            try {
                              await context
                                  .read<AuthCubit>()
                                  .updateUserFirstName(newValue);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('First name updated'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                    _ProfileField(
                      label: 'Last Name',
                      value: user.lastName,
                      icon: Icons.person_outline,
                      editable: true,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          'Edit Last Name',
                          user.lastName,
                          (newValue) async {
                            try {
                              await context
                                  .read<AuthCubit>()
                                  .updateUserLastName(newValue);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Last name updated'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                    _ProfileField(
                      label: 'Username',
                      value: user.username,
                      icon: Icons.alternate_email,
                      editable: true,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          'Edit Username',
                          user.username,
                          (newValue) async {
                            try {
                              await context
                                  .read<AuthCubit>()
                                  .updateUsername(newValue);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Username updated'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString().contains('already taken') ? 'Username already taken' : e}'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username cannot be empty';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (value.contains(' ')) {
                              return 'Username cannot contain spaces';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    _ProfileField(
                      label: l10n.profileEmailLabel,
                      value: user.email,
                      icon: Icons.email_outlined,
                      editable: true,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          l10n.profileEditEmailTitle,
                          user.email,
                          (newValue) async {
                            try {
                              await context
                                  .read<AuthCubit>()
                                  .updateUserEmail(newValue);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.profileEmailUpdated),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString().contains('already taken') ? 'Email already taken' : e}'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    _ProfileField(
                      label: l10n.profileJoinedLabel,
                      value: _formatJoinedDate(user.createdAt),
                      icon: Icons.calendar_today_outlined,
                      editable: false,
                    ),

                    const SizedBox(height: 30),

                    // App Lock Option
                    _OptionTile(
                      icon: Icons.lock_outline,
                      title: l10n.profileAppLockTitle,
                      subtitle: l10n.profileAppLockSubtitle,
                      onTap: () {
                        Navigator.pushNamed(context, '/app-lock');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Language Option
                    BlocBuilder<LocaleCubit, LocaleState>(
                      builder: (context, localeState) {
                        return _OptionTile(
                          icon: Icons.language_outlined,
                          title: l10n.profileLanguageTitle,
                          subtitle: _getLanguageDisplayName(localeState),
                          onTap: () {
                            Navigator.pushNamed(context, '/language');
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Log out
                    TextButton.icon(
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            final l = AppLocalizations.of(context)!;
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                l.profileLogoutDialogTitle,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                l.profileLogoutDialogContent,
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l.profileLogoutDialogCancel),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                  ),
                                  child: Text(l.profileLogoutDialogConfirm),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true) {
                          await context.read<AuthCubit>().logout();
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: Text(
                        l10n.profileLogoutButton,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Function(String) onSave, {
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: currentValue);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.accentPink,
                    width: 2,
                  ),
                ),
              ),
              validator: validator,
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.profileDialogCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onSave(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.profileDialogSave),
            ),
          ],
        );
      },
    );
  }
}

// Profile Field Widget
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool editable;
  final VoidCallback? onEdit;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
    this.editable = true,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: AppColors.accentPink),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

// Option Tile Widget
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: AppColors.accentPink, size: 28),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }
}