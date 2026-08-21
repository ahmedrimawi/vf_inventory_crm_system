import 'package:flutter/material.dart';

class AddItemField {
  final String name;
  final String label;
  final TextInputType keyboardType;
  final bool required;
  final bool obscureText;

  AddItemField({
    required this.name,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.required = false,
    this.obscureText = false,
  });
}

class AddItemDialog extends StatefulWidget {
  final String title;
  final List<AddItemField> fields;
  final String saveButtonText;

  final Future<void> Function(Map<String, String> values) onSave;

  const AddItemDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.saveButtonText = 'Save',
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final values = <String, String>{};

    for (final field in widget.fields) {
      values[field.name] = _controllers[field.name]!.text.trim();
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(values);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),

      content: SizedBox(
        width: 500,

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                for (final field in widget.fields) ...[
                  TextFormField(
                    controller: _controllers[field.name],
                    keyboardType: field.keyboardType,
                    obscureText: field.obscureText,

                    decoration: InputDecoration(
                      labelText: field.label,
                      border: const OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (field.required &&
                          (value == null || value.trim().isEmpty)) {
                        return '${field.label} is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.saveButtonText),
        ),
      ],
    );
  }
}
