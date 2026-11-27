import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''export function middleware(request: Request) {
  const token = request.headers.get('authorization');

  if (!token) {
    return new Response('Unauthorized', { status: 401 });
  }

  return NextResponse.next();
}''';

class CodeBlockMarks extends StatelessWidget {
  const CodeBlockMarks({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.stretch,
      spacing: 4,
      children: <Widget>[
        NebaCodeBlock(
          code: _source,
          language: 'ts',
          lineNumbers: true,
          highlightLines: '4-6',
          title: Text("highlightLines: '4-6'"),
        ),
        NebaCodeBlock(
          code: _source,
          language: 'ts',
          lineNumbers: true,
          highlightLines: '2,4-6,9',
          theme: NebaCodeTheme.oneDark,
          title: Text("highlightLines: '2,4-6,9'"),
        ),
      ],
    );
  }
}
