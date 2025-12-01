import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/habit_repository.dart';
import '../models/habit.dart';

class MonthlyCalendarView extends StatelessWidget {
  final Habit habit;
  final DateTime month; // any date within the target month
  const MonthlyCalendarView({
    super.key,
    required this.habit,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<HabitRepository>();
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sun
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final totalCells =
        ((firstWeekday + daysInMonth + 6) ~/ 7) * 7; // round up weeks
    final cells = List<DateTime?>.generate(totalCells, (i) {
      final dayOffset = i - firstWeekday;
      if (dayOffset < 0 || dayOffset >= daysInMonth) return null;
      return DateTime(month.year, month.month, dayOffset + 1);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            '${month.year}-${month.month.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cells.length,
            itemBuilder: (ctx, i) {
              final d = cells[i];
              if (d == null) {
                return const SizedBox.shrink();
              }
              final completed = repo.logs.any(
                (l) =>
                    l.habitId == habit.id &&
                    l.date.year == d.year &&
                    l.date.month == d.month &&
                    l.date.day == d.day,
              );
              return GestureDetector(
                onTap: () => repo.toggleCompletion(habit, d),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        completed
                            ? Colors.green.shade400
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text('${d.day}', style: const TextStyle(fontSize: 12)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
