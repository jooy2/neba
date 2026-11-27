import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/concepts/data/glyph.dart';

// Signing up for a product that does not exist: every kind of answer a form
// asks for, a line of text, a secret, one of a list, a date, a number, a file
// and a code from a phone, with the states around them, built out of Neba
// widgets alone. The Flutter twin of the documentation's sign-up concept; the
// copy stays in English, as the React screen's does.

const String _logo = 'M8 1.5 14 5v6l-6 3.5L2 11V5l6-3.5Z M8 8v6.5M8 8l6-3M8 8 2 5';
const String _mail =
    'M4 3.5h8a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2Z m2.75 5 5.25 3.5L13.25 5';
const String _lock =
    'M5 7h6a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2Z M5.5 7V5a2.5 2.5 0 0 1 5 0v2';
const String _user =
    'M10.75 5.5A2.75 2.75 0 1 1 5.25 5.5 2.75 2.75 0 0 1 10.75 5.5Z '
    'M2.75 13.5c.55-2.6 2.7-4.25 5.25-4.25s4.7 1.65 5.25 4.25';
const String _check = 'm3.5 8.5 3 3 6-7';
const String _at =
    'M10.5 8A2.5 2.5 0 1 1 5.5 8 2.5 2.5 0 0 1 10.5 8Z '
    'M10.5 8v1.25a2 2 0 0 0 3.25 1.56A6.5 6.5 0 1 0 11 13.6';

const List<String> _steps = <String>['Account', 'Workspace', 'Verify'];

const List<NebaSelectOption<String>> _countries = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'kr', label: Text('South Korea')),
  NebaSelectOption<String>(value: 'jp', label: Text('Japan')),
  NebaSelectOption<String>(value: 'de', label: Text('Germany')),
  NebaSelectOption<String>(value: 'us', label: Text('United States')),
  NebaSelectOption<String>(value: 'br', label: Text('Brazil')),
];

const List<NebaComboboxOption<String>> _roles = <NebaComboboxOption<String>>[
  NebaComboboxOption<String>(value: 'engineering', label: 'Engineering'),
  NebaComboboxOption<String>(value: 'design', label: 'Design'),
  NebaComboboxOption<String>(value: 'product', label: 'Product'),
  NebaComboboxOption<String>(value: 'data', label: 'Data'),
  NebaComboboxOption<String>(value: 'support', label: 'Support'),
  NebaComboboxOption<String>(value: 'ops', label: 'Operations'),
];

const List<NebaSelectOption<String>> _heardFrom = <NebaSelectOption<String>>[
  NebaSelectOption<String>(value: 'search', label: Text('Search')),
  NebaSelectOption<String>(value: 'friend', label: Text('A colleague')),
  NebaSelectOption<String>(value: 'conference', label: Text('A conference')),
  NebaSelectOption<String>(value: 'newsletter', label: Text('A newsletter')),
  NebaSelectOption<String>(value: 'other', label: Text('Somewhere else')),
];

const List<String> _perks = <String>[
  '14 days of Team, then Free',
  'Unlimited projects',
  'Delete it all in one click',
];

const List<(String, String)> _founders = <(String, String)>[
  ('Sam Arden', 'sam-arden'),
  ('Farah Wells', 'farah-wells'),
  ('Joon Mercer', 'joon-mercer'),
];

typedef _Strength = ({int score, String label, NebaColor color});

/// Roughly how strong a password is, on the four rules worth checking.
_Strength _strengthOf(String password) {
  final int score = <bool>[
    password.length >= 10,
    RegExp('[a-z]').hasMatch(password) && RegExp('[A-Z]').hasMatch(password),
    RegExp(r'\d').hasMatch(password),
    RegExp(r'[^\w\s]').hasMatch(password),
  ].where((bool met) => met).length;

  if (score <= 1) {
    return (score: score, label: 'Too easy to guess', color: NebaColor.danger);
  }

  if (score <= 3) {
    return (score: score, label: 'Getting there', color: NebaColor.warning);
  }

  return (score: score, label: 'Strong', color: NebaColor.success);
}

final RegExp _address = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final RegExp _slug = RegExp(r'^[a-z0-9-]{3,}$');

class ConceptsSignup extends StatefulWidget {
  const ConceptsSignup({super.key});

  @override
  State<ConceptsSignup> createState() => _ConceptsSignupState();
}

class _ConceptsSignupState extends State<ConceptsSignup> {
  int _step = 0;
  String? _accountType = 'team';

  String _name = '';
  String _email = '';
  String _password = '';
  DateTime? _birthday;
  String? _country;

  String _workspace = '';
  double? _seats = 5;
  List<String> _chosenRoles = <String>['engineering'];
  String _plan = 'team';
  String? _heard;
  List<NebaFile> _logoFiles = <NebaFile>[];

  String _code = '';
  bool _terms = false;
  bool _newsletter = true;
  bool _submitting = false;
  bool _done = false;
  Timer? _sending;

  final Set<String> _touched = <String>{};

  @override
  void dispose() {
    _sending?.cancel();
    super.dispose();
  }

  bool get _emailValid => _address.hasMatch(_email);

  bool get _slugValid => _slug.hasMatch(_workspace);

  bool get _accountReady => _name.trim().length >= 2 && _emailValid && _password.length >= 10;

  bool get _workspaceReady => _slugValid && (_seats ?? 0) >= 1;

  bool get _verifyReady => _code.length == 6 && _terms;

  String? _error(String field) {
    if (!_touched.contains(field)) {
      return null;
    }

    return switch (field) {
      'name' when _name.trim().length < 2 => 'Tell us what to call you.',
      'email' when !_emailValid => 'That address does not look right.',
      'password' when _password.length < 10 => 'At least ten characters.',
      'workspace' when !_slugValid => 'Lowercase letters, numbers and hyphens, three or more.',
      _ => null,
    };
  }

  void _submit() {
    setState(() => _submitting = true);
    _sending = Timer(const Duration(milliseconds: 900), () {
      setState(() {
        _submitting = false;
        _done = true;
      });
    });
  }

  /// [field] wrapped so that it counts as touched once the focus leaves it,
  /// as `onBlur` does on the React screen.
  Widget _touches(String name, Widget field) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool focused) {
        if (!focused && !_touched.contains(name)) {
          setState(() => _touched.add(name));
        }
      },
      child: field,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= NebaBreakpoint.md.width;

    return NebaContainer(
      maxWidth: const NebaMeasure.size(NebaSize.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: <Widget>[
            _header(),
            NebaGridContainer(
              spacing: 4,
              padded: false,
              children: <Widget>[
                NebaGrid(span: NebaGridSpan.columns(wide ? 7 : 12), child: _form(width)),
                NebaGrid(span: NebaGridSpan.columns(wide ? 5 : 12), child: _aside()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: <Widget>[
        const Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            NebaIcon(
              icon: ConceptGlyph(_logo),
              size: NebaSize.lg,
              color: NebaColor.primary,
              semanticLabel: 'Kestrel',
            ),
            NebaTypography('Kestrel', level: NebaTypographyLevel.h6),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            const NebaTypography('Already have an account?', level: NebaTypographyLevel.caption),
            NebaButton(
              onPressed: () {},
              size: NebaSize.xs,
              variant: NebaVariant.text,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _form(double width) {
    final bool last = _step == _steps.length - 1;

    return NebaCard(
      title: const Text('Create your account'),
      subtitle: const Text('Three short steps. Nothing is charged today.'),
      dividers: true,
      footer: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          NebaButton(
            onPressed: _step == 0 || _done ? null : () => setState(() => _step -= 1),
            variant: NebaVariant.text,
            color: NebaColor.secondary,
            child: const Text('Back'),
          ),
          if (!last)
            NebaButton(
              onPressed: (_step == 0 ? _accountReady : _workspaceReady)
                  ? () => setState(() => _step += 1)
                  : null,
              child: const Text('Continue'),
            )
          else
            NebaButton(
              onPressed: _verifyReady && !_done ? _submit : null,
              loading: _submitting,
              child: Text(_done ? 'Workspace ready' : 'Create workspace'),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: <Widget>[
              NebaProgressLinear(
                size: NebaSize.sm,
                value: (_step + 1) / _steps.length * 100,
                label: Text('Step ${_step + 1} of ${_steps.length} · ${_steps[_step]}'),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  for (int index = 0; index < _steps.length; index++)
                    NebaChip(
                      size: NebaSize.xs,
                      variant: index == _step ? NebaVariant.solid : NebaVariant.text,
                      color: index < _step
                          ? NebaColor.success
                          : index == _step
                          ? NebaColor.primary
                          : NebaColor.secondary,
                      startIcon: index < _step ? const ConceptGlyph(_check, width: 1.75) : null,
                      child: Text(_steps[index]),
                    ),
                ],
              ),
            ],
          ),
          if (_done)
            NebaAlert(
              color: NebaColor.success,
              title: const Text("You're in"),
              child: Text(
                'We sent the workspace URL to ${_email.isEmpty ? 'your inbox' : _email}.',
              ),
            ),
          ...switch (_step) {
            0 => _account(width),
            1 => _workspaceStep(),
            _ => _verify(),
          },
        ],
      ),
    );
  }

  List<Widget> _account(double width) {
    final _Strength strength = _strengthOf(_password);
    final String? nameError = _error('name');
    final String? emailError = _error('email');
    final String? passwordError = _error('password');
    final NebaGridSpan half = NebaGridSpan.columns(width >= NebaBreakpoint.sm.width ? 6 : 12);

    return <Widget>[
      NebaSegmentedButton<String>(
        fullWidth: true,
        semanticLabel: 'Account type',
        value: _accountType,
        onValueChange: (String? value) => setState(() => _accountType = value),
        children: const <NebaSegment<String>>[
          NebaSegment<String>(value: 'personal', child: Text('Just me')),
          NebaSegment<String>(value: 'team', child: Text('My team')),
        ],
      ),
      _touches(
        'name',
        NebaTextField(
          fullWidth: true,
          label: const Text('Full name'),
          placeholder: 'Ada Bell',
          autofillHints: const <String>[AutofillHints.name],
          startIcon: const ConceptGlyph(_user),
          initialValue: _name,
          onChanged: (String value) => setState(() => _name = value),
          error: nameError == null ? null : Text(nameError),
        ),
      ),
      _touches(
        'email',
        NebaTextField(
          fullWidth: true,
          label: const Text('Work email'),
          placeholder: 'ada@company.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          startIcon: const ConceptGlyph(_mail),
          description: const Text('This is where the verification code goes.'),
          initialValue: _email,
          onChanged: (String value) => setState(() => _email = value),
          error: emailError == null ? null : Text(emailError),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          _touches(
            'password',
            NebaTextField(
              fullWidth: true,
              label: const Text('Password'),
              obscureText: true,
              autofillHints: const <String>[AutofillHints.newPassword],
              startIcon: const ConceptGlyph(_lock),
              initialValue: _password,
              onChanged: (String value) => setState(() => _password = value),
              error: passwordError == null ? null : Text(passwordError),
            ),
          ),
          if (_password.isNotEmpty)
            NebaProgressLinear(
              size: NebaSize.sm,
              color: strength.color,
              value: strength.score.toDouble(),
              max: 4,
              label: Text(strength.label),
            ),
        ],
      ),
      NebaGridContainer(
        spacing: 3,
        padded: false,
        children: <Widget>[
          NebaGrid(
            span: half,
            child: NebaDatePicker(
              fullWidth: true,
              label: const Text('Date of birth'),
              placeholder: const Text('Pick a day'),
              description: const Text('We ask because of local age rules.'),
              maxDate: DateTime.now(),
              value: _birthday,
              onValueChange: (DateTime? value) => setState(() => _birthday = value),
              clearable: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: NebaSelect<String>(
              fullWidth: true,
              label: const Text('Country'),
              placeholder: const Text('Choose one'),
              items: _countries,
              value: _country,
              onValueChange: (String value) => setState(() => _country = value),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _workspaceStep() {
    final String? workspaceError = _error('workspace');

    return <Widget>[
      _touches(
        'workspace',
        NebaTextField(
          fullWidth: true,
          label: const Text('Workspace URL'),
          placeholder: 'northwind',
          startIcon: const ConceptGlyph(_at),
          endIcon: const NebaTypography('.kestrel.app', level: NebaTypographyLevel.caption),
          description: const Text('Lowercase letters, numbers and hyphens.'),
          initialValue: _workspace,
          inputFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction(
              (TextEditingValue old, TextEditingValue next) =>
                  next.copyWith(text: next.text.toLowerCase()),
            ),
          ],
          onChanged: (String value) => setState(() => _workspace = value),
          error: workspaceError == null ? null : Text(workspaceError),
        ),
      ),
      NebaNumberField(
        fullWidth: true,
        label: const Text('Seats to start with'),
        description: const Text('Add or remove them at any time.'),
        min: 1,
        max: 200,
        value: _seats,
        onValueChange: (double? value) => setState(() => _seats = value),
      ),
      NebaCombobox<String>.multiple(
        fullWidth: true,
        label: const Text('What does your team do?'),
        placeholder: 'Add a discipline',
        description: const Text('Anything the list does not have is offered as the last row.'),
        items: _roles,
        value: _chosenRoles,
        onValueChange: (List<String> value) => setState(() => _chosenRoles = value),
      ),
      NebaRadioGroup<String>(
        label: const Text('Plan'),
        value: _plan,
        onValueChange: (String? value) => setState(() => _plan = value ?? _plan),
        children: const <Widget>[
          NebaRadio<String>(
            value: 'free',
            label: Text('Free'),
            description: Text('50k events a month, 3 seats.'),
          ),
          NebaRadio<String>(
            value: 'team',
            label: Text('Team, free for 14 days'),
            description: Text('5M events a month, unlimited seats.'),
          ),
        ],
      ),
      NebaSelect<String>(
        fullWidth: true,
        label: const Text('How did you hear about us?'),
        placeholder: const Text('Optional'),
        items: _heardFrom,
        value: _heard,
        onValueChange: (String value) => setState(() => _heard = value),
      ),
      const NebaDivider(child: Text('Optional')),
      NebaFilePicker(
        size: NebaSize.sm,
        density: NebaDensity.compact,
        accept: 'image/*',
        maxSize: 2000000,
        maxFiles: 1,
        title: const Text('Drop a workspace logo'),
        hint: const Text('PNG or SVG · up to 2 MB'),
        value: _logoFiles,
        onFilesChange: (List<NebaFile> files) => setState(() => _logoFiles = files),
      ),
    ];
  }

  List<Widget> _verify() {
    return <Widget>[
      NebaAlert(
        color: NebaColor.info,
        title: const Text('Check your email'),
        child: Text(
          'A six-digit code is on its way to ${_email.isEmpty ? 'your inbox' : _email}. '
          'It expires in ten minutes.',
        ),
      ),
      NebaOtpField(
        label: const Text('Verification code'),
        description: const Text('Six digits, from the email we just sent.'),
        length: 6,
        groupSize: 3,
        value: _code,
        onValueChange: (String value) => setState(() => _code = value),
        error: _code.isNotEmpty && _code.length < 6 ? const Text('Six digits.') : null,
      ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: NebaButton(
          onPressed: () {},
          size: NebaSize.sm,
          variant: NebaVariant.text,
          child: const Text('Send it again'),
        ),
      ),
      const NebaDivider(),
      NebaCheckbox(
        label: const Text('I agree to the terms of service and the privacy notice'),
        description: const Text('Both are two pages, and both are in plain language.'),
        checked: _terms,
        onCheckedChange: (bool value) => setState(() => _terms = value),
      ),
      NebaSwitch(
        labelSide: NebaSwitchLabelSide.start,
        label: const Text('Send me the monthly product note'),
        description: const Text('One email a month. Unsubscribe from any of them.'),
        checked: _newsletter,
        onCheckedChange: (bool value) => setState(() => _newsletter = value),
      ),
    ];
  }

  Widget _aside() {
    final NebaTokens tokens = NebaTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        NebaCard(
          variant: NebaVariant.solid,
          color: NebaColor.primary,
          title: const Text('What the free trial includes'),
          child: NebaList(
            variant: NebaVariant.text,
            size: NebaSize.sm,
            density: NebaDensity.compact,
            children: <Widget>[
              for (final String perk in _perks)
                NebaListItem(
                  startIcon: const NebaIcon(
                    icon: ConceptGlyph(_check, width: 1.75),
                    size: NebaSize.sm,
                    color: NebaColor.primary,
                  ),
                  child: Text(perk),
                ),
            ],
          ),
        ),
        NebaCard(
          size: NebaSize.sm,
          title: const Text('After you sign up'),
          child: NebaTimeline(
            size: NebaSize.sm,
            density: NebaDensity.compact,
            active: _step + 1,
            color: NebaColor.primary,
            children: const <NebaTimelineItem>[
              NebaTimelineItem(title: Text('Account created'), meta: Text('Now')),
              NebaTimelineItem(title: Text('Workspace named'), meta: Text('30 seconds')),
              NebaTimelineItem(title: Text('Email verified'), meta: Text('1 minute')),
              NebaTimelineItem(title: Text('First event received'), meta: Text('Up to you')),
            ],
          ),
        ),
        const NebaBlockquote(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          author: Text('Jun Park'),
          source: Text('CTO, Acme Rail'),
          child: Text('Signing up took less time than the meeting where we decided to.'),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            _Faces(ring: tokens.surface),
            const NebaTypography(
              '1,208 workspaces created this month',
              level: NebaTypographyLevel.caption,
            ),
          ],
        ),
      ],
    );
  }
}

/// The founders' faces, each overlapping the one before it by a quarter and
/// ringed in the page's own colour.
class _Faces extends StatelessWidget {
  const _Faces({required this.ring});

  final Color ring;

  @override
  Widget build(BuildContext context) {
    const double face = 32;
    const double step = face - 8;

    return SizedBox(
      width: step * (_founders.length - 1) + face + 4,
      height: face + 4,
      child: Stack(
        children: <Widget>[
          for (int index = 0; index < _founders.length; index++)
            PositionedDirectional(
              start: step * index,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ring),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: NebaAvatar(
                    size: NebaSize.sm,
                    name: _founders[index].$1,
                    image: AssetImage('assets/samples/people/${_founders[index].$2}.jpg'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
