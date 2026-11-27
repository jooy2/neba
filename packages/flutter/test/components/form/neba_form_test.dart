// NebaForm: the suite the React package runs on Form, asked the way Flutter
// asks it — the semantics and the gaps it builds, what a submit checks, hands
// over and focuses, and when a field's error comes and goes — rather than the
// element, the classes and the events it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  final GlobalKey<NebaFormState> form = GlobalKey<NebaFormState>();

  Future<void> pump(WidgetTester tester, Widget child, {NebaDefaults? defaults}) {
    final Widget placed = Overlay.wrap(
      child: Center(child: SizedBox(width: 320, child: child)),
    );

    return tester.pumpWidget(
      host(defaults == null ? placed : NebaProvider(defaults: defaults, child: placed)),
    );
  }

  String? required(String? value) {
    return value == null || value.isEmpty ? 'Enter your email.' : null;
  }

  /// A text field named [name] that a form checks with [validator].
  Widget email({
    String name = 'email',
    String label = 'Email',
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool disabled = false,
  }) {
    return NebaFormField<String>(
      name: name,
      initialValue: initialValue,
      validator: validator,
      disabled: disabled,
      builder: (NebaFormFieldState<String> field) => NebaTextField(
        label: Text(label),
        initialValue: field.value,
        error: field.error,
        disabled: disabled,
        onChanged: field.didChange,
      ),
    );
  }

  bool focused(WidgetTester tester, String label) {
    final Finder editable = find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(NebaTextField)),
      matching: find.byType(EditableText),
    );

    return tester.widget<EditableText>(editable).focusNode.hasFocus;
  }

  Future<void> submit(WidgetTester tester) async {
    form.currentState!.submit();
    await tester.pump();
    await tester.pump();
  }

  group('rendering', () {
    testWidgets('builds a form a screen reader hears by its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaForm(semanticLabel: 'Sign up', children: <Widget>[email()]));

      final SemanticsData data = tester
          .getSemantics(find.bySemanticsLabel('Sign up'))
          .getSemanticsData();

      expect(data.role, SemanticsRole.form);
      // Each field keeps a node of its own inside the form.
      expect(find.bySemanticsLabel('Email'), findsOneWidget);

      semantics.dispose();
    });

    double gap(WidgetTester tester) {
      return tester.getRect(find.byType(NebaTextField).last).top -
          tester.getRect(find.byType(NebaTextField).first).bottom;
    }

    List<Widget> twoFields() => <Widget>[email(), email(name: 'name', label: 'Name')];

    testWidgets('stacks its children on the size ladder', (WidgetTester tester) async {
      await pump(tester, NebaForm(size: NebaSize.xl, children: twoFields()));

      expect(gap(tester), NebaScale.sheetSectionGap[NebaSize.xl]);
      expect(tester.getSize(find.byType(NebaTextField).first).width, 320);
    });

    testWidgets('stands its children spacing apart instead, 0 included', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaForm(spacing: 8, children: twoFields()));
      expect(gap(tester), 32);

      await pump(tester, NebaForm(spacing: 0, children: twoFields()));
      expect(gap(tester), 0);
    });

    testWidgets("takes NebaProvider's spacing, and its own over it", (WidgetTester tester) async {
      const NebaDefaults defaults = NebaDefaults(spacing: 7);

      await pump(tester, NebaForm(children: twoFields()), defaults: defaults);
      expect(gap(tester), 28);

      await pump(tester, NebaForm(spacing: 2, children: twoFields()), defaults: defaults);
      expect(gap(tester), 8);
    });
  });

  group('submitting', () {
    testWidgets('hands the values over from a button inside it', (WidgetTester tester) async {
      Map<String, Object?>? submitted;

      await pump(
        tester,
        NebaForm(
          onSubmit: (Map<String, Object?> values) => submitted = values,
          children: <Widget>[
            email(initialValue: 'a@b.com', validator: required),
            NebaFormField<bool>(
              name: 'terms',
              initialValue: false,
              builder: (NebaFormFieldState<bool> field) => NebaCheckbox(
                label: const Text('I agree'),
                checked: field.value ?? false,
                onCheckedChange: field.didChange,
              ),
            ),
            Builder(
              builder: (BuildContext context) => NebaButton(
                onPressed: () => NebaForm.of(context).submit(),
                child: const Text('Sign up'),
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.text('I agree'));
      await tester.pump();
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(submitted, <String, Object?>{'email': 'a@b.com', 'terms': true});
    });

    testWidgets('does not submit while a field is invalid, and says why', (
      WidgetTester tester,
    ) async {
      int submits = 0;

      await pump(
        tester,
        NebaForm(
          key: form,
          onSubmit: (Map<String, Object?> _) => submits++,
          children: <Widget>[email(validator: required)],
        ),
      );

      expect(find.text('Enter your email.'), findsNothing);

      expect(form.currentState!.submit(), isFalse);
      await tester.pump();

      expect(submits, 0);
      expect(find.text('Enter your email.'), findsOneWidget);
    });

    testWidgets('focuses the first field that failed, in the order they stand', (
      WidgetTester tester,
    ) async {
      Widget build({required bool withName}) {
        return NebaForm(
          key: form,
          children: <Widget>[
            // Built after the email field, and standing before it.
            if (withName) email(name: 'name', label: 'Name', validator: required),
            email(validator: required),
          ],
        );
      }

      await pump(tester, build(withName: false));
      await pump(tester, build(withName: true));
      await submit(tester);

      expect(focused(tester, 'Name'), isTrue);
      expect(focused(tester, 'Email'), isFalse);
    });

    testWidgets('passes over a field that is valid on its way to one that is not', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaForm(
          key: form,
          children: <Widget>[
            email(name: 'name', label: 'Name', initialValue: 'Jane', validator: required),
            email(validator: required),
          ],
        ),
      );

      await submit(tester);

      expect(focused(tester, 'Email'), isTrue);
    });

    testWidgets('leaves a disabled field out, its own or a fieldset’s', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;

      await pump(
        tester,
        NebaForm(
          key: form,
          onSubmit: (Map<String, Object?> values) => submitted = values,
          children: <Widget>[
            email(name: 'name', label: 'Name', initialValue: 'Jane'),
            email(validator: required, disabled: true),
            NebaFieldset(
              disabled: true,
              children: <Widget>[email(name: 'city', label: 'City', validator: required)],
            ),
          ],
        ),
      );

      await submit(tester);

      expect(submitted, <String, Object?>{'name': 'Jane'});
      expect(find.text('Enter your email.'), findsNothing);
    });
  });

  group('errors', () {
    testWidgets('puts an error from outside onto the field it belongs to', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaForm(
          errors: const <String, Object>{'email': 'That address is already taken.'},
          children: <Widget>[email()],
        ),
      );

      expect(find.text('That address is already taken.'), findsOneWidget);
    });

    testWidgets('draws a list of them one to a line', (WidgetTester tester) async {
      await pump(
        tester,
        NebaForm(
          errors: const <String, Object>{
            'email': <String>['Too short.', 'Not an address.'],
          },
          children: <Widget>[email()],
        ),
      );

      expect(find.text('Too short.\nNot an address.'), findsOneWidget);
    });

    testWidgets('drops it once the field changes, and shows a new map again', (
      WidgetTester tester,
    ) async {
      Widget build(Map<String, Object> errors) {
        return NebaForm(errors: errors, children: <Widget>[email()]);
      }

      await pump(tester, build(const <String, Object>{'email': 'Taken.'}));
      await tester.enterText(find.byType(EditableText), 'someone@else.com');
      await tester.pump();

      expect(find.text('Taken.'), findsNothing);

      await pump(tester, build(<String, Object>{'email': 'Taken.'}));

      expect(find.text('Taken.'), findsOneWidget);
    });

    testWidgets('does not stop a submit', (WidgetTester tester) async {
      int submits = 0;

      await pump(
        tester,
        NebaForm(
          key: form,
          errors: const <String, Object>{'email': 'Taken.'},
          onSubmit: (Map<String, Object?> _) => submits++,
          children: <Widget>[email(initialValue: 'a@b.com', validator: required)],
        ),
      );

      expect(form.currentState!.submit(), isTrue);
      expect(submits, 1);
    });
  });

  group('validationMode', () {
    Widget build(NebaFormValidationMode mode) {
      return NebaForm(
        key: form,
        validationMode: mode,
        children: <Widget>[
          email(validator: required),
          email(name: 'name', label: 'Name'),
        ],
      );
    }

    Finder emailField() => find.byType(EditableText).first;

    testWidgets('onSubmit checks nothing before a submit, and every change after', (
      WidgetTester tester,
    ) async {
      await pump(tester, build(NebaFormValidationMode.onSubmit));

      await tester.enterText(emailField(), 'a');
      await tester.enterText(emailField(), '');
      await tester.pump();
      expect(find.text('Enter your email.'), findsNothing);

      await submit(tester);
      expect(find.text('Enter your email.'), findsOneWidget);

      await tester.enterText(emailField(), 'a@b.com');
      await tester.pump();
      expect(find.text('Enter your email.'), findsNothing);
    });

    testWidgets('onBlur checks a field when the focus leaves it', (WidgetTester tester) async {
      await pump(tester, build(NebaFormValidationMode.onBlur));

      await tester.tap(emailField());
      await tester.pump();
      expect(find.text('Enter your email.'), findsNothing);

      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(find.text('Enter your email.'), findsOneWidget);
    });

    testWidgets('onChange checks a field on every change', (WidgetTester tester) async {
      await pump(tester, build(NebaFormValidationMode.onChange));

      await tester.enterText(emailField(), 'a');
      await tester.pump();
      expect(find.text('Enter your email.'), findsNothing);

      await tester.enterText(emailField(), '');
      await tester.pump();
      expect(find.text('Enter your email.'), findsOneWidget);
    });
  });
}
