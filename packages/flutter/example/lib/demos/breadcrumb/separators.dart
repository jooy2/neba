import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BreadcrumbSeparators extends StatelessWidget {
  const BreadcrumbSeparators({super.key});

  List<NebaBreadcrumbItem> _steps(String last) {
    return <NebaBreadcrumbItem>[
      NebaBreadcrumbItem(onPressed: () {}, href: Uri.parse('#home'), child: const Text('Home')),
      NebaBreadcrumbItem(
        onPressed: () {},
        href: Uri.parse('#projects'),
        child: const Text('Projects'),
      ),
      NebaBreadcrumbItem(child: Text(last)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, NebaBreadcrumbSeparator> named = <String, NebaBreadcrumbSeparator>{
      'chevron': NebaBreadcrumbSeparator.chevron,
      'arrow': NebaBreadcrumbSeparator.arrow,
      'slash': NebaBreadcrumbSeparator.slash,
      'dot': NebaBreadcrumbSeparator.dot,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        for (final MapEntry<String, NebaBreadcrumbSeparator> separator in named.entries)
          NebaBreadcrumb(
            separator: separator.value,
            label: separator.key,
            children: _steps(separator.key),
          ),
        // Anything else is drawn as it is given.
        NebaBreadcrumb(
          separator: const NebaBreadcrumbSeparator.widget(Text('»')),
          label: 'custom',
          children: _steps('custom'),
        ),
      ],
    );
  }
}
