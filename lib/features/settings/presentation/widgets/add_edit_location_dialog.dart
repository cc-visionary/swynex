import 'package:flutter/material.dart';

// The function signature remains the same, but its implementation now uses showModalBottomSheet.
Future<List<String>?> showAddLocationsDialog(
  BuildContext context, {
  required String title,
}) async {
  return showModalBottomSheet<List<String>>(
    context: context,
    // Allows the sheet to be taller than half the screen, accommodating the keyboard.
    isScrollControlled: true,
    // Applies rounded top corners.
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      // We wrap the content in Padding to move it up when the keyboard appears.
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddMultipleLocationsDialogContent(title: title),
      );
    },
  );
}

class _AddMultipleLocationsDialogContent extends StatefulWidget {
  final String title;
  const _AddMultipleLocationsDialogContent({required this.title});

  @override
  State<_AddMultipleLocationsDialogContent> createState() =>
      _AddMultipleLocationsDialogContentState();
}

class _AddMultipleLocationsDialogContentState
    extends State<_AddMultipleLocationsDialogContent> {
  final _textController = TextEditingController();
  List<String> _names = [];

  @override
  void initState() {
    super.initState();
    // Add a listener to the text controller to update the preview live.
    _textController.addListener(_updatePreview);
  }

  void _updatePreview() {
    // Split the text by new lines, trim whitespace, and filter out empty lines.
    final newNames =
        _textController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // Update the state to rebuild the preview list.
    setState(() {
      _names = newNames;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_updatePreview);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a consistent theme.
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: theme.textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Multi-line text field for input
          TextField(
            controller: _textController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter structure names (one per line)',
              labelText: 'Names',
            ),
          ),
          const SizedBox(height: 24),
          // Preview section header
          if (_names.isNotEmpty)
            Text('Preview', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          // Live preview list
          if (_names.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _names.length,
                itemBuilder: (context, index) {
                  final name = _names[index];
                  return Card(
                    elevation: 0,
                    color: theme.scaffoldBackgroundColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          // This logic to remove an item is a bit more complex
                          // because we need to rebuild the text in the controller.
                          final currentNames = _textController.text.split('\n');
                          currentNames.removeWhere((n) => n.trim() == name);
                          _textController.text = currentNames.join('\n');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          // Bottom button to add the structures
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _names.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_names),
              child: Text(
                _names.isEmpty
                    ? 'Add Structures'
                    : 'Add ${_names.length} Structures',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showEditLocationDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _EditLocationDialogContent(
          title: title,
          initialValue: initialValue,
        ),
      );
    },
  );
}

class _EditLocationDialogContent extends StatefulWidget {
  final String title;
  final String initialValue;
  const _EditLocationDialogContent({
    required this.title,
    required this.initialValue,
  });

  @override
  State<_EditLocationDialogContent> createState() =>
      _EditLocationDialogContentState();
}

class _EditLocationDialogContentState
    extends State<_EditLocationDialogContent> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: theme.textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Single text field for editing the name
          TextField(
            controller: _textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 24),
          // Bottom button to save changes
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Return the new name
                Navigator.of(context).pop(_textController.text.trim());
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
