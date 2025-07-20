import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;

  const HomeAppBar({super.key, required this.title, this.bottom, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // If custom actions are provided, display them first.
        if (actions != null) ...actions!,
        // Default actions
        IconButton(
          icon: Badge(
            label: const Text('3'),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.black,
            ),
          ),
          onPressed: () => context.push('/notifications'),
        ),
      ],
      // This will now work without an error
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
