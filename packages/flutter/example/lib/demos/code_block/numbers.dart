import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const String _source = r'''  const collapse = useCollapsed(collapseBelow);
  const [ownOpen, setOwnOpen] = useState(defaultOpen);
  const open = controlled ? openProp : ownOpen;

  return collapse ? <Drawer open={open} /> : <aside>{children}</aside>;''';

class CodeBlockNumbers extends StatelessWidget {
  const CodeBlockNumbers({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaCodeBlock(
      code: _source,
      language: 'tsx',
      lineNumbers: true,
      startLine: 286,
      title: Text('Sidebar.tsx'),
    );
  }
}
