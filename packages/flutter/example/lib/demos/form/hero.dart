import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

String? _email(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter an email address.';
  }

  return value.contains('@') ? null : 'An email address has an @ in it.';
}

String? _password(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter a password.';
  }

  return value.length < 8 ? 'Use 8 characters or more.' : null;
}

class FormHero extends StatefulWidget {
  const FormHero({super.key});

  @override
  State<FormHero> createState() => _FormHeroState();
}

class _FormHeroState extends State<FormHero> {
  final GlobalKey<NebaFormState> _form = GlobalKey<NebaFormState>();
  String? _submitted;

  @override
  Widget build(BuildContext context) {
    final String? submitted = _submitted;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaForm(
        key: _form,
        onSubmit: (Map<String, Object?> values) {
          setState(() => _submitted = '${values['email'] ?? ''}');
        },
        children: <Widget>[
          NebaFormField<String>(
            name: 'email',
            validator: _email,
            builder: (NebaFormFieldState<String> field) => NebaTextField(
              label: const Text('Email'),
              placeholder: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const <String>[AutofillHints.email],
              error: field.error,
              onChanged: field.didChange,
            ),
          ),
          NebaFormField<String>(
            name: 'password',
            validator: _password,
            builder: (NebaFormFieldState<String> field) => NebaTextField(
              label: const Text('Password'),
              obscureText: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              error: field.error,
              onChanged: field.didChange,
              onSubmitted: (String _) => _form.currentState!.submit(),
            ),
          ),
          NebaButton(
            onPressed: () => _form.currentState!.submit(),
            fullWidth: true,
            child: const Text('Create account'),
          ),
          if (submitted != null)
            NebaTypography('Submitted as $submitted.', level: NebaTypographyLevel.caption),
        ],
      ),
    );
  }
}
