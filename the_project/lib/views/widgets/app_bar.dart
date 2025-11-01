import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/style_simple/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('EEE, MMM d').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentPink, AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 👤 Profile button (tap to go to Profile screen)
              GestureDetector(
                onTap: onProfileTap ??
                    () {
                      Navigator.pushNamed(context, '/profile');
                    },
                child: const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/icons/profile.png'),
                  backgroundColor: Colors.white24,
                ),
              ),

              // 🏷️ Optional title (centered if provided)
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                const Spacer(),

              // 📅 Current date
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
