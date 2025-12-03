import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool checked;
  final Color heatmapColor;
  final ValueChanged<bool> onCheck;

  const HabitCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.heatmapColor,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: checked,
          activeColor: heatmapColor,
          onChanged: (val) => onCheck(val ?? false),
        ),
      ),
    );
  }
}
