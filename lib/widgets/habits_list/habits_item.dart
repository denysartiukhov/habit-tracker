import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/helpers/db_helper.dart';
import 'package:habit_tracker/models/completion.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/widgets/edit_habit/edit_habit.dart';
import 'package:habit_tracker/widgets/habits_list/last_week_heatmap/last_week_heatmap.dart';
import 'package:habit_tracker/widgets/habits_list/streak.dart';
import 'package:intl/intl.dart';

class HabitsItemNew extends StatefulWidget {
  const HabitsItemNew(
    this.habit, {
    super.key,
    required this.onRemoveHabit,
  });

  final void Function(Habit habit) onRemoveHabit;
  final Habit habit;

  @override
  State<HabitsItemNew> createState() {
    return _HabitsItemNewState();
  }
}

class _HabitsItemNewState extends State<HabitsItemNew> {
  Future<void> _updateHabit(Habit habit) async {
    setState(() {
      DatabaseHelper().updateHabit(habit.id, habit.name);
    });
  }

  void _toggleHabit(Habit habit) {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      habit.isCompleted = !habit.isCompleted;
    });
    DatabaseHelper().toggleCompletion(habit.id, date, habit.isCompleted);
  }

  static int calculateCurrentStreak(List<Completion> completions) {
    if (completions.isEmpty) {
      return 0;
    }

    completions.sort((a, b) => b.completionDate.compareTo(a.completionDate));

    if (completions[0].isCompleted == false) {
      return 0;
    }

    int currentStreak = 1;

    for (int i = 1; i < completions.length; i++) {
      if (completions[i].isCompleted &&
          completions[i - 1].isCompleted &&
          i != completions.length - 1) {
        currentStreak++;
      } else {
        break;
      }
    }

    return currentStreak;
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete habit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveHabit(widget.habit);
              Navigator.pop(context, 'Delete');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context, Habit habit) async {
    final RenderBox cardRenderBox = context.findRenderObject() as RenderBox;
    final RenderBox overlayRenderBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset cardPosition =
        cardRenderBox.localToGlobal(Offset.zero, ancestor: overlayRenderBox);

    final RelativeRect position = RelativeRect.fromLTRB(
      cardPosition.dx,
      cardPosition.dy + cardRenderBox.size.height,
      overlayRenderBox.size.width - cardPosition.dx - cardRenderBox.size.width,
      overlayRenderBox.size.height -
          cardPosition.dy -
          cardRenderBox.size.height,
    );

    await showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text(
            'Edit',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'yesterday',
          child: Text(
            'Toggle yesterday',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // const PopupMenuItem<String>(
        //   value: 'completions',
        //   child: Text(
        //     'Past completions',
        //     style: TextStyle(
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).then((String? value) async {
      if (value == "delete") {
        //Navigator.pop(context);
        _showDeleteConfirmationDialog(context);
      }
      if (value == "edit") {
        //Navigator.pop(context);
        showModalBottomSheet(
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) {
              return EditHabit(habit: habit, onUpdateHabit: _updateHabit);
            });
      }
      if (value == "yesterday") {
        String yesterdayDate = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1)));
        List<Completion> completions = await DatabaseHelper()
            .getCompletions(habit, yesterdayDate, yesterdayDate);
        DatabaseHelper().toggleCompletion(
            habit.id, yesterdayDate, !completions[0].isCompleted);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Habit>(
      future: DatabaseHelper().getHabit(widget.habit),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final habit = snapshot.data;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleHabit(habit);
            },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              _showActionSheet(context, habit);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: habit!.isCompleted
                      ? const Color.fromARGB(255, 0, 28, 59)
                      : const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(13.0),
                  border: Border.all(
                    color: habit.isCompleted
                        ? Colors.transparent
                        : const Color.fromARGB(255, 43, 43, 43),
                    width: 1.0,
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.48,
                height: MediaQuery.of(context).size.width * 0.24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              habit.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: 10.0,
                              maxLines: 1,
                            ),
                          ),
                          Streak(habit: habit,),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          LastWeekHeatmap(
                            habit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
