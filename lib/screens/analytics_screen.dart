import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

/// An analytical dashboard that aggregates metrics, gauges operational output,
/// and presents historical logging metrics for completed tasks.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color indigoPrimary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('METRIC INSIGHTS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final allTasks = provider.tasks;
          final completedTasks = allTasks.where((t) => t.isCompleted).toList();
          
          final int totalCount = allTasks.length;
          final int completedCount = completedTasks.length;
          final int pendingCount = totalCount - completedCount;
          
          final double complianceRate = totalCount == 0 ? 0.0 : (completedCount / totalCount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                Text(
                  'PERFORMANCE METRICS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: indigoPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Core High-Fidelity Numeric Grid Layout
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Total Scope',
                        '$totalCount',
                        Icons.folder_open_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Completed',
                        '$completedCount',
                        Icons.assignment_turned_in_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'In Pipeline',
                        '$pendingCount',
                        Icons.hourglass_empty_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Success Rate',
                        '${(complianceRate * 100).toStringAsFixed(0)}%',
                        Icons.speed_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. Historical Ledger / Audit Stream
                Text(
                  'COMPLETED ARCHIVE RECORD (${completedTasks.length})',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(height: 12),

                if (completedTasks.isEmpty) ...[
                  _buildMinimalistEmptyState(context, textTheme),
                ] else ...[
                  _buildHistoryStreamBuilder(completedTasks, provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                Icon(icon, size: 16, color: Theme.of(context).primaryColor.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStreamBuilder(List<TaskModel> completedList, TaskProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: completedList.length,
      itemBuilder: (context, index) {
        final task = completedList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              title: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C757D),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                task.category.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.undo_rounded, size: 18, color: Color(0xFFADB5BD)),
                tooltip: 'Revert Checklist Objective',
                onPressed: () => provider.toggleTaskStatus(task.id),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalistEmptyState(BuildContext context, TextTheme textTheme) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 28,
                color: Theme.of(context).primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Historical Records Found',
              style: textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete scheduled workspace pipeline targets to populate your analytical metrics board.',
              style: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}