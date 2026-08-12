import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

/// A rich, stateful view layer capable of displaying deep metadata profiles
/// or contextually mutating task schemas directly inside persistent memory.
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isEditMode = false;
  
  // Controllers and active state tracking fields
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _activePriority;
  late DateTime _activeDueDate;
  late String _activeCategory;

  @override
  void initState() {
    super.initState();
    _initializeStateFields();
  }

  void _initializeStateFields() {
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _activePriority = widget.task.priority;
    _activeDueDate = widget.task.dueDate;
    _activeCategory = widget.task.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Selects a future timestamp target and triggers a UI update layer.
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _activeDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _activeDueDate) {
      setState(() {
        _activeDueDate = picked;
      });
    }
  }

  /// Commits current contextual state structures back into local storage via TaskProvider.
  void _saveTaskChanges() {
    if (_titleController.text.trim().isEmpty) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priority: _activePriority,
      dueDate: _activeDueDate,
      category: _activeCategory,
    );

    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
    
    setState(() {
      _isEditMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes synced cleanly with disk runtime cache.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color indigoPrimary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'EDIT METADATA' : 'TASK PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close_rounded : Icons.edit_note_rounded, size: 24),
            color: _isEditMode ? Colors.redAccent : indigoPrimary,
            onPressed: () {
              setState(() {
                if (_isEditMode) {
                  // Revert parameters if canceling active edits
                  _initializeStateFields();
                }
                _isEditMode = !_isEditMode;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Structural Category Domain Header Label
            _buildCategoryLabel(indigoPrimary),
            const SizedBox(height: 12),

            // Main Core Fields Layout Matrix
            if (!_isEditMode) ...[
              _buildReadOnlyProfile(textTheme),
            ] else ...[
              _buildEditableFormLayout(context),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _isEditMode 
          ? _buildStickyActionSaveBar(indigoPrimary) 
          : null,
    );
  }

  Widget _buildCategoryLabel(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Text(
        _activeCategory.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildReadOnlyProfile(TextTheme textTheme) {
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(_activeDueDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleController.text,
          style: textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPriorityBadge(_activePriority),
            const SizedBox(width: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6C757D)),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF495057), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),
        Text(
          'Detailed Scope Context',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2, color: const Color(0xFF6C757D)),
        ),
        const SizedBox(height: 10),
        Text(
          _descController.text.isNotEmpty 
              ? _descController.text 
              : 'No extended documentation provided for this logged task element.',
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF343A40), height: 1.6),
        ),
      ],
    );
  }

  Widget _buildEditableFormLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleController,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(labelText: 'Task Objective Title'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descController,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: const InputDecoration(labelText: 'Scope Context Documentation'),
        ),
        const SizedBox(height: 20),
        
        // Priority Scale Selection Blocks
        Text('Urgency Priority Scale', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _activePriority == priority;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(priority.name.toUpperCase()),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.12),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF495057),
                ),
                onSelected: (_) => setState(() => _activePriority = priority),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Date Picker Action Trigger Field
        Text('Target Checkpoint Deadline', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range_rounded),
            title: Text(
              DateFormat('MMMM dd, yyyy').format(_activeDueDate),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_drop_down_rounded),
            onTap: () => _selectDueDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color baseColor;
    switch (priority) {
      case TaskPriority.high:
        baseColor = const Color(0xFFE63946);
        break;
      case TaskPriority.medium:
        baseColor = const Color(0xFFF4A261);
        break;
      case TaskPriority.low:
        baseColor = const Color(0xFF2A9D8F);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: baseColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            priority.name.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: baseColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionSaveBar(Color primaryColor) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: _saveTaskChanges,
          child: Text(
            'Save Changes Securely',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}