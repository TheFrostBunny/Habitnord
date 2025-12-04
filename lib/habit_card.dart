import 'package:flutter/material.dart';
import 'hooks/translations.dart';

class HabitCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool checked;
  final Color heatmapColor;
  final ValueChanged<bool> onCheck;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.heatmapColor,
    required this.onCheck,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onLongPress:
            onDelete != null
                ? () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: Text(Translations.text('delete_habit')),
                              onTap: () {
                                Navigator.of(context).pop();
                                onDelete!();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.close),
                              title: Text(Translations.text('cancel')),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                : null,
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
