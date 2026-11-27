import {
  elevationRow,
  from,
  renamed,
  sizeRow,
  transitionRow,
  variantRow,
  WIDGET,
  type PropRow
} from './shared';

export default {
  Avatar: [
    renamed('Avatar', 'src', 'image', {
      type: 'ImageProvider?',
      description: {
        ko: '그림. AssetImage, NetworkImage처럼 어떤 ImageProvider든 됩니다. 로딩되기 전까지, 그리고 실패하면 계속 fallback이 그려집니다',
        en: 'The picture, as any ImageProvider: an AssetImage, a NetworkImage. Until it loads (and for good, if it fails) the fallback is what is drawn'
      }
    }),
    renamed('Avatar', 'alt', 'semanticLabel', {
      type: 'String?',
      description: {
        ko: '화면 낭독기가 읽는 이름으로, React의 alt에 해당합니다. 빈 문자열이면 아바타 전체가 읽히지 않습니다',
        en: "What a screen reader hears, React's alt. An empty string makes the whole avatar silent"
      }
    }),
    from('Avatar', 'name', { type: 'String?' }),
    from('Avatar', 'initials', { type: 'String?' }),
    from('Avatar', 'shape', { type: 'NebaAvatarShape', default: 'NebaAvatarShape.circle' }),
    variantRow('Avatar', 'NebaVariant.text'),
    sizeRow('Avatar'),
    from('Avatar', 'color', { type: 'NebaColor?', default: 'NebaColor.primary' }),
    elevationRow('Avatar'),
    from('Avatar', 'delay', {
      type: 'Duration?',
      description: {
        ko: '그림이 로딩되는 동안 fallback을 그리기까지 기다리는 시간. 캐시된 그림 앞에서 이니셜이 번쩍이는 것을 막습니다',
        en: 'How long to wait before drawing the fallback while the picture loads. Stops the initials flashing up in front of a cached picture'
      }
    }),
    from('Avatar', 'onLoadingStatusChange', {
      type: 'ValueChanged<NebaAvatarLoadingStatus>?',
      description: {
        ko: '그림이 idle, loading, loaded, error 사이를 오갈 때 호출됩니다',
        en: 'Called as the picture moves between idle, loading, loaded and error'
      }
    }),
    renamed('Avatar', 'children', 'child', {
      type: `${WIDGET}?`,
      description: {
        ko: '이니셜 대신 그릴 fallback. 아이콘, 로고, 이모지 하나. 아이콘은 아바타가 내려주는 IconTheme으로 상자의 55%가 됩니다',
        en: 'The fallback, drawn instead of the initials: an icon, a logo, a single emoji. An icon is drawn at 55% of the box through the IconTheme the avatar hands down'
      }
    }),
    transitionRow('Avatar')
  ]
} satisfies Record<string, PropRow[]>;
