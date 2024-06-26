import 'package:habit_tracker/models/habit.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/completion.dart';
import 'package:habit_tracker/widgets/habits_list/last_week_heatmap/last_week_heatmap_item.dart';
import 'package:habit_tracker/helpers/db_helper.dart';
import 'package:intl/intl.dart';

class LastWeekHeatmap extends StatelessWidget {
  const LastWeekHeatmap(
    this.habit, {
    super.key,
  });

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 6));
    DateTime habitStartDate = habit.startDate;
    if (startDate.isBefore(habitStartDate)) {
      startDate = habitStartDate;
    }
    return FutureBuilder<List<Completion>>(
      future: DatabaseHelper().getCompletions(
          habit, startDate, DateFormat('yyyy-MM-dd').format(DateTime.now())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: const Color(0xFF0E3311).withOpacity(0),
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
              ),
              const SizedBox(
                width: 3,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final completions = snapshot.data!;
          int i = 7 - completions.length;
          List<Widget> dummyHeatmapItems = List<Widget>.generate(i, (index) {
            return Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 0, 0),
                      border: Border.all(
                        color: Color.fromARGB(255, 47, 47, 47),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                ),
                const SizedBox(
                  width: 3,
                ),
              ],
            );
          });
          return Row(
            children: [
              ...dummyHeatmapItems,
              ...completions.map((completion) {
                return Row(
                  children: [
                    LastWeekHeatmapItem(completion),
                    const SizedBox(
                      width: 3,
                    )
                  ],
                );
              }).toList(),
            ],
          );
        }
      },
    );
  }
}
