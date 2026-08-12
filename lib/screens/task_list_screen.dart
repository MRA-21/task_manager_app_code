import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_detail_screen.dart';

/// A dynamic workspace display screen for reviewing, filtering, 
/// and purging tasks with reactive persistence tracking.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _selectedCategory = 'All Tasks';

  @override
  Widget build(BuildContext context) {
    final Color indigoPrimary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TASKS LAB'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          // Extract dynamic category domains from real data points
          final Set<String> uniqueCategories = provider.tasks.map((t) => t.category).toSet();
          final List<String> filterOptions = ['All Tasks', ...uniqueCategories];

          // Apply state matching predicate rules
          final List<TaskModel> filteredTasks = _selectedCategory == 'All Tasks'
              ? provider.tasks
              : provider.tasks.where((t) => t.category == _selectedCategory).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Horizontal Operational Filtering Bar
              _buildFilterSegmentBar(filterOptions, indigoPrimary),
              
              const Divider(),

              // 2. Main ListView Builder Area
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyStateWidget(context, textTheme)
                    : _buildTaskStreamBuilder(filteredTasks, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSegmentBar(List<String> options, Color activeColor) {
    return Container(
      height: 64,
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final currentOption = options[index];
          final bool isSelected = _selectedCategory == currentOption;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = currentOption;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFE9ECEF),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  currentOption,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF495057),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskStreamBuilder(List<TaskModel> taskList, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final task = taskList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key('task_dismiss_${task.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Execute permanent data purge from local shared preferences
              provider.deleteTask(task.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task purged from device architecture.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
           background: Container(
  alignment: Alignment.centerRight,
  // FIXED: Changed from .right: 24 to .only(right: 24)
  padding: const EdgeInsets.only(right: 24), 
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.error.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Icon(
    Icons.delete_outline_rounded,
    color: Theme.of(context).colorScheme.error,
    size: 24,
  ),
),
            child: Card(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: task),
                  ),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Native persistent state checkbox mechanism
                      Transform.scale(
                        scale: 0.95,
                        child: Checkbox(
                          value: task.isCompleted,
                          activeColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (_) => provider.toggleTaskStatus(task.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Priority Indicator dot mapping
                      _buildPriorityIndicatorDot(task.priority),
                      const SizedBox(width: 12),

                      // Task Text elements
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: task.isCompleted 
                                    ? const Color(0xFFADB5BD) 
                                    : const Color(0xFF1A1A1A),
                                decoration: task.isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              task.category.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: const Color(0xFF6C757D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Icon(
                        Icons.arrow_forward_ios_rounded, 
                        size: 14, 
                        color: Color(0xFFCED4DA),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityIndicatorDot(TaskPriority priority) {
    Color dotColor;
    switch (priority) {
      case TaskPriority.high:
        dotColor = const Color(0xFFE63946); // Dynamic Studio Red
        break;
      case TaskPriority.medium:
        dotColor = const Color(0xFFF4A261); // Dynamic Studio Amber
        break;
      case TaskPriority.low:
        dotColor = const Color(0xFF2A9D8F); // Dynamic Studio Teal
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 32,
              color: Color(0xFFDEE2E6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Workspace Environment Clear',
            style: textTheme.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'No logged checkpoints match the selected domain parameters.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}