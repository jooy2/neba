import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

String? _email(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter an email address.';
  }

  return value.contains('@') ? null : 'An email address has an @ in it.';
}

class FormValidationMode extends StatelessWidget {
  const FormValidationMode({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 6,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final NebaFormValidationMode mode in NebaFormValidationMode.values)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: _ModeForm(mode: mode),
            ),
        ],
      ),
    );
  }
}

class _ModeForm extends StatefulWidget {
  const _ModeForm({required this.mode});

  final NebaFormValidationMode mode;

  @override
  State<_ModeForm> createState() => _ModeFormState();
}

class _ModeFormState extends State<_ModeForm> {
  final GlobalKey<NebaFormState> _form = GlobalKey<NebaFormState>();

  @override
  Widget build(BuildContext context) {
    return NebaForm(
      key: _form,
      size: NebaSize.sm,
      validationMode: widget.mode,
      onSubmit: (Map<String, Object?> _) {},
      children: <Widget>[
        NebaFormField<String>(
          name: 'email',
          validator: _email,
          builder: (NebaFormFieldState<String> field) => NebaTextField(
            size: NebaSize.sm,
            label: Text(widget.mode.name),
            placeholder: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            error: field.error,
            onChanged: field.didChange,
          ),
        ),
        NebaButton(
          onPressed: () => _form.currentState!.submit(),
          size: NebaSize.sm,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
