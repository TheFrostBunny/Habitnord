import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leadingIcon = Icons.settings,
    this.onLeadingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final iconBg = isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF2F4F8);
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black12;

    return AppBar(
      elevation: 0,
      backgroundColor: bgColor,
      centerTitle: false,
      titleSpacing: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: onLeadingTap,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 16, right: 12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: Icon(
                leadingIcon,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}