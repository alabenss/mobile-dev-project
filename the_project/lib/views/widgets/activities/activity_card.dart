import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodCard extends StatelessWidget {
  final dynamic data;
  final Color bg;
  final Color border;

  const MoodCard({
    required this.data,
    required this.bg,
    required this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                data.asset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: border,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: border.withOpacity(.78),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
