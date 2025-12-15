// ============= lock_type_selection_widget.dart =============
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

class LockTypeSelectionWidget extends StatelessWidget {
  final String? currentLock;
  final Function(String) onLockTypeSelected;
  final VoidCallback onRemoveLock;

  const LockTypeSelectionWidget({
    super.key,
    required this.currentLock,
    required this.onLockTypeSelected,
    required this.onRemoveLock,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appLockChooseType,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        _buildLockTypeCard(
          context,
          title: l10n.appLockPin,
          subtitle: l10n.appLockPinSubtitle,
          icon: Icons.pin_outlined,
          type: "pin",
        ),
        const SizedBox(height: 16),
        _buildLockTypeCard(
          context,
          title: l10n.appLockPattern,
          subtitle: l10n.appLockPatternSubtitle,
          icon: Icons.gesture_outlined,
          type: "pattern",
        ),
        const SizedBox(height: 16),
        _buildLockTypeCard(
          context,
          title: l10n.appLockPassword,
          subtitle: l10n.appLockPasswordSubtitle,
          icon: Icons.password_outlined,
          type: "password",
        ),

        const Spacer(),

        if (currentLock != null) ...[
          ElevatedButton.icon(
            onPressed: onRemoveLock,
            icon: const Icon(Icons.lock_open),
            label: Text(l10n.appLockRemoveExisting),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.kLight,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildLockTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: AppColors.accentPink),
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
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => onLockTypeSelected(type),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}