import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/style_simple/colors.dart';
import '../widgets/app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🧭 Custom app bar (no profile picture, with back button)
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 2,
        centerTitle: true,
        title: Text(
          "Profile",
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

      // 🌈 Background gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👤 Profile Picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/icons/profile.png'),
                      backgroundColor: Colors.white,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPink,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () {
                          // edit profile picture
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 📝 Username
                Text(
                  "Selsabila Guettaf",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const SizedBox(height: 24),

                // 📋 Editable Info Fields
                _ProfileField(
                  label: "Email",
                  value: "selsabila@example.com",
                  icon: Icons.email_outlined,
                ),
                _ProfileField(
                  label: "Username",
                  value: "salsa123",
                  icon: Icons.person_outline,
                ),
                _ProfileField(
                  label: "Joined",
                  value: "March 2024",
                  icon: Icons.calendar_today_outlined,
                  editable: false,
                ),

                const SizedBox(height: 30),

                // 🔒 App Lock Option
                _OptionTile(
                  icon: Icons.lock_outline,
                  title: "App Lock",
                  subtitle: "Set or change your app lock",
                  onTap: () {
                    Navigator.pushNamed(context, '/app-lock');
                  },
                ),

                const SizedBox(height: 12),

                // 🌍 Language Option
                _OptionTile(
                  icon: Icons.language_outlined,
                  title: "Language",
                  subtitle: "Change app language",
                  onTap: () {
                    Navigator.pushNamed(context, '/language');
                  },
                ),

                const SizedBox(height: 24),

                // 🚪 Log out
                TextButton.icon(
                  onPressed: () {
                    // handle logout
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(
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
  }
}

// ------------------------------------------------------------
// 🔹 Profile Field Widget
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool editable;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
    this.editable = true,
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
                Text(label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    )),
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
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ⚙️ Option Tile Widget (App Lock, Language, etc.)
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
