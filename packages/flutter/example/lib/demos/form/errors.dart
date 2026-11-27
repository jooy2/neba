import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Stands in for a server that already knows this address.
const String _taken = 'taken@example.com';

class FormErrors extends StatefulWidget {
  const FormErrors({super.key});

  @override
  State<FormErrors> createState() => _FormErrorsState();
}

class _FormErrorsState extends State<FormErrors> {
  final GlobalKey<NebaFormState> _form = GlobalKey<NebaFormState>();
  Map<String, Object> _errors = const <String, Object>{};

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaForm(
        key: _form,
        errors: _errors,
        onSubmit: (Map<String, Object?> values) {
          setState(() {
            _errors = values['email'] == _taken
                ? <String, Object>{'email': 'That address is already taken.'}
                : <String, Object>{};
          });
        },
        children: <Widget>[
          NebaFormField<String>(
            name: 'email',
            initialValue: _taken,
            validator: (String? value) {
              return value == null || value.isEmpty ? 'Enter an email address.' : null;
            },
            builder: (NebaFormFieldState<String> field) => NebaTextField(
              label: const Text('Email'),
              initialValue: field.value,
              keyboardType: TextInputType.emailAddress,
              description: const Text('Submit as $_taken to see the server answer.'),
              error: field.error,
              onChanged: field.didChange,
            ),
          ),
          NebaButton(onPressed: () => _form.currentState!.submit(), child: const Text('Check')),
        ],
      ),
    );
  }
}
