import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  Gallery: [
    from('Gallery', 'items', { type: 'List<NebaGalleryItem>' }),
    from('Gallery', 'layout', { type: 'NebaGalleryLayout', default: 'NebaGalleryLayout.grid' }),
    from('Gallery', 'columns', {
      type: 'int?',
      default: { ko: '창 너비에 따라 2 · 3 · 4', en: '2, 3 or 4 by the window' },
      description: {
        ko: '한 줄에 몇 장인지. grid · masonry · quilted가 읽고, justified는 rowHeight로 스스로 정합니다. 생략하면 창이 sm보다 좁을 때 2, sm부터 3, lg부터 4입니다',
        en: 'How many tiles across. Read by grid, masonry and quilted; justified decides for itself from rowHeight. Left out, two in a window below sm, three from sm and four from lg'
      }
    }),
    from('Gallery', 'gap', {
      type: 'double?',
      default: '8',
      description: {
        ko: '타일 사이의 간격(논리 픽셀). 사다리의 단계는 NebaGallery.gaps에 있습니다',
        en: 'The space between tiles, in logical pixels. The ladder’s steps are in NebaGallery.gaps'
      }
    }),
    from('Gallery', 'ratio', {
      type: 'double',
      description: {
        ko: 'grid에서 타일의 모양(너비 ÷ 높이)이자, 자기 ratio가 없는 항목이 다른 곳에서 되돌아가는 값',
        en: 'The shape of a tile in grid, width over height, and what an item with no ratio of its own falls back to elsewhere'
      }
    }),
    from('Gallery', 'rowHeight', { type: 'double' }),
    from('Gallery', 'rounded', {
      type: 'NebaSize?',
      default: 'NebaSize.md',
      description: {
        ko: '타일의 모서리를 radius 사다리의 한 단계로 둥글게. null이면 각진 타일',
        en: 'Rounds the tiles at this step of the radius ladder. null is square'
      }
    }),
    from('Gallery', 'fit', {
      type: 'BoxFit',
      default: 'BoxFit.cover',
      description: {
        ko: '각 사진이 타일을 채우는 방식. contain과 scaleDown은 사진 전체를 남깁니다',
        en: 'How each picture fills its tile. contain and scaleDown keep the whole picture'
      }
    }),
    from('Gallery', 'letterbox', {
      type: 'NebaImageLetterbox',
      default: 'NebaImageLetterbox.none'
    }),
    from('Gallery', 'priority', {
      type: 'int',
      description: {
        ko: '첫 항목부터 몇 장이 화면의 평가 기준이 되는 그림인지. 그 타일들은 priority를 켠 Image처럼 페이드나 Skeleton 없이 그립니다',
        en: 'How many tiles, from the first item, are pictures the screen is judged by. Each is drawn as an Image with priority is, with no fade and no Skeleton'
      }
    }),
    from('Gallery', 'caption', {
      type: 'NebaGalleryCaption',
      default: 'NebaGalleryCaption.none',
      description: {
        ko: '항목의 title과 description이 놓이는 곳. below는 사진 아래, overlay는 사진 위 그러데이션, hover는 pointer나 keyboard focus와 함께 나타나는 overlay이며 마우스가 연결되지 않았을 때는 늘 보입니다',
        en: "Where an item's title and description go. below is under the picture, overlay is across the foot of it, hover is overlay that arrives with the pointer or the keyboard focus, and stays up with no mouse connected"
      }
    }),
    from('Gallery', 'hover', { type: 'NebaGalleryHover', default: 'NebaGalleryHover.lift' }),
    from('Gallery', 'preview', {
      type: 'bool',
      description: {
        ko: '타일을 누르면 Dialog의 시트에 원래 크기로 열고 나머지는 방향키로 넘깁니다. 위에 Overlay가 있어야 하며, 누르기 전까지는 아무것도 빌드하지 않습니다',
        en: 'Opens the picture full size on the sheet a Dialog draws when a tile is pressed, with the rest of the set an arrow key away. Needs an Overlay above it, and builds nothing of it until a tile is pressed'
      }
    }),
    from('Gallery', 'onItemSelect', { type: 'NebaGalleryItemCallback?' }),
    from('Gallery', 'filter · frame · watermark · protect', {
      type: 'see NebaImage',
      description: {
        ko: '각 타일의 NebaImage로 그대로 전달됩니다. watermark와 protect는 크게 보기 화면까지 따라갑니다',
        en: "Passed straight through to every tile's NebaImage. watermark and protect follow the picture into the viewer"
      }
    }),
    from('Gallery', 'label', { type: 'String?' }),
    from('Gallery', 'locale', {
      type: 'Locale?',
      description: {
        ko: '목록, 타일의 위치, 크게 보기 화면의 버튼이 쓰이는 언어. 기본값은 NebaProvider의 것, 그다음 앱의 locale입니다',
        en: "Which language the list, the tiles' places and the viewer's buttons are named in. Defaults to NebaProvider's, then the app's"
      }
    }),
    from('Gallery', 'empty', { type: `${WIDGET}?` })
  ],

  NebaGalleryItem: [
    renamed('NebaGalleryItem', 'src', 'image', {
      type: 'ImageProvider',
      description: {
        ko: '그림. AssetImage, NetworkImage처럼 어떤 ImageProvider든 됩니다',
        en: 'The picture, as any ImageProvider: an AssetImage, a NetworkImage'
      }
    }),
    from('NebaGalleryItem', 'alt', { type: 'String' }),
    from('NebaGalleryItem', 'ratio', {
      type: 'double?',
      description: {
        ko: '사진 자체의 비율(너비 ÷ 높이). masonry와 justified가 이 값으로 배치를 계산하며, 그 계산은 파일이 도착하기 전에 끝납니다',
        en: "The picture's own proportion, width over height. masonry and justified are laid out from it, before a single file has arrived"
      }
    }),
    from('NebaGalleryItem', 'rotate · flip', {
      type: 'int · NebaImageFlip',
      default: '0 · NebaImageFlip.none'
    }),
    from('NebaGalleryItem', 'position', { type: 'Alignment?' }),
    from('NebaGalleryItem', 'placeholder', { type: 'NebaImagePlaceholder?' }),
    from('NebaGalleryItem', 'title', {
      type: 'String?',
      description: {
        ko: '캡션의 첫 줄이자 크게 보기 화면의 제목',
        en: "The first line of the caption, and the viewer's heading"
      }
    }),
    from('NebaGalleryItem', 'description', { type: 'String?' }),
    from('NebaGalleryItem', 'full', {
      type: 'ImageProvider?',
      description: {
        ko: '타일이 썸네일일 때 크게 보기 화면이 쓸 원본. 없으면 image',
        en: 'A larger file for the viewer, when the tile is a thumbnail. Falls back to image'
      }
    }),
    from('NebaGalleryItem', 'cols · rows', { type: 'int' }),
    from('NebaGalleryItem', 'id', {
      type: 'Object?',
      description: {
        ko: '안정적인 식별자. 기본값은 image',
        en: 'A stable identity. Defaults to image'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
