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
  final VoidCallback? onEdit;
  final List<DateTime> dates;

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
    this.onEdit,
    this.dates = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          ListTile(
                            leading: const Icon(Icons.edit, color: Colors.blue),
                            title: Text(Translations.text('edit_habit')),
                            onTap: () {
                              Navigator.of(context).pop();
                              onEdit!();
                            },
                          ),
                        if (onDelete != null)
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
            },
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
          if (dates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                'Utført på: ' +
                    dates
                        .map((d) => '${d.day}.${d.month}.${d.year}')
                        .join(', '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
