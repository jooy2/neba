import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

final RegExp _address = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class TextFieldControlled extends StatefulWidget {
  const TextFieldControlled({super.key});

  @override
  State<TextFieldControlled> createState() => _TextFieldControlledState();
}

class _TextFieldControlledState extends State<TextFieldControlled> {
  String _email = '';

  @override
  Widget build(BuildContext context) {
    final bool valid = _email.isEmpty || _address.hasMatch(_email);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaTextField(
        label: const Text('Email'),
        onChanged: (String value) => setState(() => _email = value),
        error: valid ? null : const Text('Enter a valid address.'),
        description: valid ? Text('${_email.length} characters') : null,
        placeholder: 'jane@example.com',
        fullWidth: true,
      ),
    );
  }
}
