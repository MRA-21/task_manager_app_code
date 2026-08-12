import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'task_list_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _uuid = const Uuid();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  String _selectedCategory = 'Work';

  final List<String> _categories = ['Work', 'Personal', 'Fitness'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showCreateTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CREATE NEW TASK',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Task Title'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 20),
                    
                    Text('Category', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: _categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            onSelected: (_) => setModalState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Text('Priority', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: TaskPriority.values.map((priority) {
                        final isSel = _selectedPriority == priority;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(priority.name.toUpperCase()),
                            selected: isSel,
                            onSelected: (_) => setModalState(() => _selectedPriority = priority),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_titleController.text.trim().isEmpty) return;

                          final newTask = TaskModel(
                            id: _uuid.v4(),
                            title: _titleController.text.trim(),
                            description: _descController.text.trim(),
                            dueDate: DateTime.now().add(const Duration(days: 2)),
                            priority: _selectedPriority,
                            category: _selectedCategory,
                          );

                          Provider.of<TaskProvider>(context, listen: false).addTask(newTask);

                          _titleController.clear();
                          _descController.clear();
                          _selectedPriority = TaskPriority.medium;
                          _selectedCategory = 'Work';

                          Navigator.pop(context);
                        },
                        child: Text('Save Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color indigoPrimary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final username = Provider.of<AuthProvider>(context).currentUser ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('STUDIO DESK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF6C757D)),
            tooltip: 'Log Out',
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          final int totalCount = tasks.length;
          final int completedCount = tasks.where((t) => t.isCompleted).length;
          final double ratio = totalCount == 0 ? 0.0 : (completedCount / totalCount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK, ${username.toUpperCase()}',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: indigoPrimary),
                ),
                const SizedBox(height: 4),
                Text('Your Dashboard', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.0, color: const Color(0xFF1A1A1A))),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Task Progress', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                              const SizedBox(height: 4),
                              Text('You have completed $completedCount out of $totalCount tasks.', style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6C757D), height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: ratio,
                                strokeWidth: 6,
                                backgroundColor: const Color(0xFFE9ECEF),
                                color: indigoPrimary,
                              ),
                            ),
                            Text('${(ratio * 100).toStringAsFixed(0)}%', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('NAVIGATION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: const Color(0xFF6C757D))),
                const SizedBox(height: 12),
                
                _buildMenuRow(
                  context,
                  title: 'View Task List',
                  subtitle: 'View, filter, and manage your tasks',
                  icon: Icons.grid_view_rounded,
                  destination: const TaskListScreen(),
                ),
                const SizedBox(height: 12),
                _buildMenuRow(
                  context,
                  title: 'Task Analytics',
                  subtitle: 'See your task metrics and completion history',
                  icon: Icons.analytics_outlined,
                  destination: const AnalyticsScreen(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: indigoPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: () => _showCreateTaskSheet(context),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('New Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.2)),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destination,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination)),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6C757D))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFADB5BD)),
            ],
          ),
        ),
      ),
    );
  }
}