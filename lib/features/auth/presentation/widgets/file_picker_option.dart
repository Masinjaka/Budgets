import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Theme.of(context).iconTheme.color),
            SizedBox(height: 1.h),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15.5.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
