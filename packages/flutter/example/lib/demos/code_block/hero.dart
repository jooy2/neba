import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''import { createServer } from 'node:http';

const server = createServer((request, response) => {
  response.writeHead(200, { 'content-type': 'application/json' });
  response.end(JSON.stringify({ ok: true, path: request.url }));
});

server.listen(3000, () => console.log('listening on :3000'));''';

class CodeBlockHero extends StatelessWidget {
  const CodeBlockHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCodeBlock(
      code: _source,
      language: 'ts',
      title: Text('server.ts'),
      lineNumbers: true,
    );
  }
}
