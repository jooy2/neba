import { from, renamed, WIDGET, type PropRow } from './shared';

export default {
  Portal: [
    renamed('Portal', 'children', 'child', { type: WIDGET }),
    renamed('Portal', 'container', 'rootOverlay', {
      type: 'bool',
      default: 'true',
      description: {
        ko: '앱의 root overlay, 즉 모든 route와 중첩된 navigator 위에 그릴지 여부. false면 portal 위쪽에서 가장 가까운 Overlay에 그립니다',
        en: "Whether the child goes into the app's root overlay, above every route and nested navigator, rather than the nearest Overlay above the portal"
      }
    }),
    from('Portal', 'disabled', {
      type: 'bool',
      description: {
        ko: 'overlay 대신 제자리에 그립니다. 처음 빌드할 때 한 번만 정하세요. 바꾸면 안의 모든 것이 다시 빌드되고 그 안의 상태가 사라집니다',
        en: 'Draws the child in place instead. Decide it once, when the portal is first built: changing it builds everything inside again and throws away its state'
      }
    })
  ]
} satisfies Record<string, PropRow[]>;
