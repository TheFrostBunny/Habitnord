import 'package:flutter/material.dart';
import 'habit_storage.dart';
import 'hooks/translations.dart';
import 'icon_picker.dart';

class AddHabitDialog extends StatefulWidget {
  final Color defaultColor;
  final int defaultIconIndex;
  const AddHabitDialog({
    Key? key,
    this.defaultColor = Colors.blue,
    this.defaultIconIndex = 0,
  }) : super(key: key);
  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String subtitle = '';
  Color color = Colors.blue;
  int iconIndex = 0;
  String? errorText;

  @override
  void initState() {
    super.initState();
    color = widget.defaultColor;
    iconIndex = widget.defaultIconIndex;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'color': color,
        'icon': usedIcons[iconIndex],
        'iconIndex': iconIndex,
        'title': title.trim(),
        'subtitle': subtitle.trim(),
        'checked': false,
        'heatmapColor': color,
      });
    } else {
      setState(() {
        errorText = 'Fyll ut alle felter';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Translations.text('add_habit')),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: Translations.text('title'),
                  ),
                  onChanged: (v) => title = v,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Tittel kan ikke være tom'
                              : null,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: Translations.text('description'),
                  ),
                  onChanged: (v) => subtitle = v,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Beskrivelse kan ikke være tom'
                              : null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Velg ikon:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: IconPicker(
                    selectedIndex: iconIndex,
                    onSelect: (i) => setState(() => iconIndex = i),
                  ),
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Avbryt'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Legg til')),
      ],
    );
  }
}
