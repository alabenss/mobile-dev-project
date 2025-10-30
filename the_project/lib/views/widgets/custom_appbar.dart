import 'package:flutter/material.dart';
import '../../commons/config.dart';
import '../themes/style_simple/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(122);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + date (mirrors screenshot)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.account_circle_outlined,
                      size: 34, color: Colors.white),
                  Text(AppConfig.dateLabel, style: AppText.tinyDate),
                ],
              ),
              const SizedBox(height: 10),
              Text('Good morning , ${AppConfig.userName}', style: AppText.greeting),
            ],
          ),
        ),
      ),
    );
  }
}
