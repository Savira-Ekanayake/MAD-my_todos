import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/todo_model.dart';

class TodoTile extends StatefulWidget {
  final TodoModel todo;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool showMeta;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onComplete,
    required this.onDelete,
    this.onEdit,
    this.showMeta = false,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getCardColor(theme, isDarkMode),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: widget.todo.isCompleted
                      ? Colors.green.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onComplete,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Animated checkbox
                        GestureDetector(
                          onTap: widget.onComplete,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: widget.todo.isCompleted
                                  ? Colors.green
                                  : Colors.transparent,
                              border: Border.all(
                                color: widget.todo.isCompleted
                                    ? Colors.green
                                    : theme.colorScheme.outline,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: widget.todo.isCompleted
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: widget.todo.isCompleted
                                      ? theme.colorScheme.onSurface
                                      .withOpacity(0.6)
                                      : theme.colorScheme.onSurface,
                                  decoration: widget.todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: Text(
                                  widget.todo.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.todo.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: widget.todo.isCompleted
                                        ? theme.colorScheme.onSurface
                                        .withOpacity(0.4)
                                        : theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  child: Text(
                                    widget.todo.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],

                              // Meta info: created and completed dates
                              if (widget.showMeta) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${DateFormat.yMMMd().format(widget.todo.date)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (widget.todo.completedAt != null)
                                  Text(
                                    'Completed: ${DateFormat.yMMMd().add_jm().format(widget.todo.completedAt!)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button (only show for non-completed tasks)
                            if (widget.onEdit != null && !widget.todo.isCompleted)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: widget.onEdit,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: theme.colorScheme.primary.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Delete button
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _showDeleteConfirmation(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: theme.colorScheme.error.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCardColor(ThemeData theme, bool isDarkMode) {
    if (widget.todo.isCompleted) {
      return isDarkMode
          ? Colors.green.withOpacity(0.1)
          : Colors.green.withOpacity(0.05);
    }
    return theme.colorScheme.surface;
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _animateDelete();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _animateDelete() {
    _animationController.forward().then((_) {
      widget.onDelete();
    });
  }
}
