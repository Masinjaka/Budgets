import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class FileOption extends StatefulWidget {
  const FileOption(
      {super.key,
      this.title = 'Titre',
      this.icon = Icons.file_upload,
      this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<FileOption> createState() => _FileOptionState();
}

class _FileOptionState extends State<FileOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Theme.of(context).iconTheme.color),
            SizedBox(height: 8),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: AppTypography.body,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
