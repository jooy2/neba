/// What holds a control open at the width of the widest thing it could say:
/// the React package's `internal/sizer.tsx`.
///
/// A control that is not told to stretch is as wide as what it is saying, so
/// a Select showing `Seoul` is narrower than the same Select showing
/// `Washington DC`, and the field moves under the pointer that just chose.
/// [NebaWidthSizer] lays out every alternative and is never drawn, so the
/// widest of them decides the control's width whatever its value is.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Characters drawn about twice as wide as a Latin letter: Hangul, the CJK
/// blocks and the fullwidth forms.
final RegExp _wide = RegExp('[ᄀ-ᅟ⺀-꓏가-힣豈-﫿︰-﹏＀-｠￠-￦]');

/// The share of the longest sample's length another has to reach to be laid
/// out at all. A length is not a width, but across the labels a list holds
/// one character never takes more than two and a half times the room another
/// does, so a sample under two fifths of the longest one's length is never
/// the widest.
const double _contender = 0.4;

/// The words a sample draws, when it is a `Text` or a `RichText`, and `null`
/// for any other widget, whose width nothing short of laying it out says.
String? _sampleText(Widget sample) {
  if (sample is Text) {
    return sample.data ?? sample.textSpan?.toPlainText() ?? '';
  }

  if (sample is RichText) {
    return sample.text.toPlainText();
  }

  return null;
}

/// A string's length in units of roughly half an em.
int _roughLength(String text) => text.length + _wide.allMatches(text).length;

/// The samples a [NebaWidthSizer] needs, out of all of them: those whose text
/// is long enough to be the widest, and every one that is not text, which is
/// kept whatever its neighbours say. A list of two hundred and fifty
/// countries then lays out a handful of names rather than all of them.
List<Widget> nebaWidestSamples(List<Widget> samples) {
  final List<int?> lengths = <int?>[
    for (final Widget sample in samples)
      switch (_sampleText(sample)) {
        final String text => _roughLength(text),
        null => null,
      },
  ];
  final int longest = lengths.fold(0, (int most, int? length) => math.max(most, length ?? 0));

  return <Widget>[
    for (int i = 0; i < samples.length; i++)
      if (lengths[i] == null || lengths[i]! >= longest * _contender) samples[i],
  ];
}

/// [sample] as a sizer lays it out: on one line, in the ambient style with
/// [style] laid over it.
///
/// A `Text` is drawn again as a `RichText` of the same words, which reserves
/// the same width and leaves nothing for a `find.text` to match a second time
/// in a caller's tests. Only a sample that is not a `Text` is built twice.
Widget nebaSizerSample(BuildContext context, Widget sample, {TextStyle? style}) {
  if (sample is Text) {
    final TextStyle merged = DefaultTextStyle.of(context).style.merge(sample.style).merge(style);

    return RichText(
      maxLines: 1,
      softWrap: false,
      textScaler: sample.textScaler ?? MediaQuery.textScalerOf(context),
      text: TextSpan(
        style: merged,
        text: sample.data,
        children: sample.textSpan == null ? null : <InlineSpan>[sample.textSpan!],
      ),
    );
  }

  return DefaultTextStyle.merge(style: style, maxLines: 1, softWrap: false, child: sample);
}

/// Every one of [samples], one under the other, so that its width is the
/// widest of theirs. It is meant to be measured and never drawn: a field's
/// `NebaFieldWidth` takes it as its sizer, and it is kept out of what a
/// screen reader hears.
class NebaWidthSizer extends StatelessWidget {
  /// A sizer for [samples], drawn in [style] over the ambient one.
  const NebaWidthSizer({required this.samples, this.style, super.key});

  /// Everything the control could say.
  final List<Widget> samples;

  /// The control's own text style, laid over the ambient one.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final Widget sample in nebaWidestSamples(samples))
            nebaSizerSample(context, sample, style: style),
        ],
      ),
    );
  }
}
