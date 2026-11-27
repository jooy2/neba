import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''# One long line, so there is something for wrap to actually do.
curl --fail --silent --show-error --location --retry 3 --retry-delay 2 --header "authorization: Bearer $NEBA_TOKEN" --header "content-type: application/json" --data '{"region":"icn","runtime":"node22","memory":512}' https://api.example.com/v1/projects/neba/deployments
echo "queued"

# And a second one, because a single wrapped line is easy to mistake for two.
docker run --rm --interactive --tty --volume "$PWD:/work" --workdir /work --env CI=1 --env NODE_OPTIONS=--max-old-space-size=4096 node:22-bookworm npm run build -- --profile
echo "built"''';

class CodeBlockScroll extends StatefulWidget {
  const CodeBlockScroll({super.key});

  @override
  State<CodeBlockScroll> createState() => _CodeBlockScrollState();
}

class _CodeBlockScrollState extends State<CodeBlockScroll> {
  bool _wrap = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: NebaSegmentedButton<String>(
            size: NebaSize.sm,
            value: _wrap ? 'wrap' : 'scroll',
            onValueChange: (String? next) => setState(() => _wrap = next == 'wrap'),
            children: const <NebaSegment<String>>[
              NebaSegment<String>(value: 'scroll', child: Text('scroll')),
              NebaSegment<String>(value: 'wrap', child: Text('wrap')),
            ],
          ),
        ),
        NebaCodeBlock(
          code: _source,
          language: 'bash',
          wrap: _wrap,
          maxHeight: 220,
          lineNumbers: true,
          title: const Text('deploy.sh'),
        ),
      ],
    );
  }
}
