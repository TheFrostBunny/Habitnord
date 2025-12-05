import 'package:flutter/material.dart';
import 'habit_storage.dart';

class IconPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const IconPicker({
    Key? key,
    required this.selectedIndex,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: usedIcons.length,
      itemBuilder: (context, i) {
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              usedIcons[i],
              size: 32,
              color: selected ? Colors.blue : Colors.grey[700],
            ),
          ),
        );
      },
    );
  }
}
