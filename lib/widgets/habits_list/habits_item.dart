import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

class HabitsItem extends StatelessWidget {
  const HabitsItem(this.habit, {super.key});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          children: [
            Text(habit.name),
          ],
        ),
      ),
    );
  }
}