import {
  colorRow,
  densityRow,
  elevationRow,
  focusRows,
  from,
  sizeRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  FilePicker: [
    variantRow('FilePicker', 'NebaVariant.outline'),
    sizeRow('FilePicker'),
    colorRow('FilePicker'),
    densityRow('FilePicker'),
    elevationRow('FilePicker'),
    {
      name: 'onPick',
      type: 'Future<List<NebaFile>?> Function()?',
      description: {
        ko: '앱의 파일 창을 열고 고른 파일을 돌려줍니다. 닫혔으면 null이나 빈 목록입니다. 상자를 누르거나 Enter, Space를 누르면 불립니다. 없으면 상자는 드롭된 파일만 받고 focus 순서에도 들지 않습니다',
        en: "Opens the app's file dialog and hands back what was chosen, or null or nothing when it was dismissed. A press on the box, Enter or Space call it. Without it the box takes only dropped files and is not in the focus order"
      }
    },
    from('FilePicker', 'accept', {
      type: 'String?',
      description: {
        ko: "받는 파일의 종류, 'image/*,.pdf'. 고른 파일이든 드롭한 파일이든 모두 이 문자열로 검사합니다. onPick이 여는 창에도 같은 문자열을 넘겨 그 파일만 보이게 하세요",
        en: "Which files are taken: 'image/*,.pdf'. Every file is checked against it, picked or dropped; hand the same string to the dialog onPick opens so it offers only those"
      }
    }),
    from('FilePicker', 'multiple', { type: 'bool' }),
    from('FilePicker', 'maxSize', { type: 'int?' }),
    from('FilePicker', 'maxFiles', { type: 'int?' }),
    from('FilePicker', 'value', { type: 'List<NebaFile>?' }),
    from('FilePicker', 'defaultValue', { type: 'List<NebaFile>', default: '[]' }),
    from('FilePicker', 'onFilesChange', { type: 'ValueChanged<List<NebaFile>>?' }),
    from('FilePicker', 'onReject', { type: 'ValueChanged<List<NebaFileRejection>>?' }),
    from('FilePicker', 'label', { type: `${WIDGET}?` }),
    from('FilePicker', 'description', { type: `${WIDGET}?` }),
    from('FilePicker', 'error', { type: `${WIDGET}?` }),
    from('FilePicker', 'invalid', { type: 'bool?', default: 'error != null' }),
    from('FilePicker', 'title', { type: `${WIDGET}?` }),
    from('FilePicker', 'hint', { type: `${WIDGET}?` }),
    from('FilePicker', 'icon', {
      type: `${WIDGET}?`,
      description: {
        ko: '문장 위의 글리프. 업로드 화살표 대신 그립니다',
        en: 'The glyph above the title, in place of the upload arrow'
      }
    }),
    {
      name: 'showIcon',
      type: 'bool',
      default: 'true',
      description: {
        ko: '문장 위에 글리프를 그릴지 여부. false가 React의 icon={null}입니다',
        en: 'Whether the box draws a glyph above its title at all: false is React’s icon={null}'
      }
    },
    from('FilePicker', 'showList', { type: 'bool' }),
    from('FilePicker', 'removeLabel', { type: 'String Function(String name)?' }),
    from('FilePicker', 'locale', { type: 'Locale?' }),
    from('FilePicker', 'fullWidth', {
      type: 'bool',
      description: {
        ko: '주어진 너비만큼 늘어납니다. 아니면 상자 안 문장만큼의 너비입니다',
        en: 'Stretches to the width it is given. Otherwise as wide as what the box says'
      }
    }),
    from('FilePicker', 'disabled', { type: 'bool' }),
    from('FilePicker', 'readOnly', { type: 'bool' }),
    ...focusRows
  ],

  NebaFile: [
    {
      name: 'name',
      type: 'String',
      required: true,
      description: { ko: '확장자를 포함한 파일 이름', en: "The file's name, with its extension" }
    },
    {
      name: 'size',
      type: 'int',
      required: true,
      description: { ko: '파일 크기(바이트)', en: 'How long the file is, in bytes' }
    },
    {
      name: 'type',
      type: 'String',
      default: "''",
      description: {
        ko: '파일의 미디어 타입, image/png. 모르면 빈 문자열입니다',
        en: "The file's media type, image/png, or empty when it is not known"
      }
    },
    {
      name: 'lastModified',
      type: 'DateTime?',
      description: { ko: '마지막으로 바뀐 때', en: 'When the file was last changed' }
    },
    {
      name: 'data',
      type: 'Object?',
      description: {
        ko: '앱이 이 파일을 가리키는 방식. 경로, 바이트, 플러그인의 파일 객체 등이며, picker는 읽지 않습니다',
        en: "The app's own handle on the file: a path, the bytes, a plugin's file object. The picker never reads it"
      }
    }
  ]
} satisfies Record<string, PropRow[]>;
