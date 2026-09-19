---
title: Sources
order: 6
---

# Sources

<p class="neba-lede">답이 무엇을 근거로 만들어졌는지를 모아 둔 목록입니다. 번호가 붙은 줄마다 링크와 인용된 대목이 들어가고, 전체는 개수를 말해 주는 제목 뒤로 접힙니다.</p>

<Demo src="sources/hero" />

```tsx
import { Sources } from 'neba';

<Sources
  items={[
    { title: 'The design language', site: 'neba.cdget.com', href: '/design/design-language' },
    { title: 'Breakpoints', site: 'neba.cdget.com', href: '/design/breakpoints' }
  ]}
/>;
```

## Props

<PropsTable name="Sources" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`, `title`, `onChange`만 제외됩니다.

줄 자체는 [List](../display/list)로도 그릴 수 있습니다. 못 하는 부분이 이것을 컴포넌트로 만듭니다. 줄에는 *번호*가 붙고, 그 번호가 본문의 [InlineCitation](./inline-citation)이 가리키는 대상입니다.

### SourceItem

<PropsTable name="SourceItem" />

## 예시

### collapsible

켜져 있습니다. 출처 목록은 답에서 가장 길고 가장 덜 읽히는 부분이며, 독자가 대개 원하는 것은 몇 개였는지입니다. 그래서 개수는 열려 있든 닫혀 있든 제목 줄에 있습니다.

끄면 제목은 그냥 한 줄이 되고 목록은 열려 있습니다. 그 상태에는 disclosure가 아예 없으므로 누를 것도 없습니다.

<Demo src="sources/folding">

<<< @/.vitepress/demos/sources/folding.tsx

</Demo>

### 번호

주어진 순서대로 1부터 번호를 붙입니다. 항목의 `index`가 이를 덮어씁니다. 더 긴 목록 가운데 실제로 인용된 것만 보여 주는 경우에 필요합니다.

`numbered={false}`는 번호를 없앱니다. 본문에서 아무것도 인용하지 않을 때 쓰세요. 가리키는 것이 없는 번호는 독자가 의미를 찾아 헤매는 번호입니다.

### 링크

`href`가 있는 줄은 진짜 [TextLink](../display/text-link)입니다. 밑줄도 포커스 링도 라이브러리의 다른 링크와 같습니다. `href`가 없는 줄은 평범한 텍스트입니다. 독자가 열 수 없는 파일의 한 대목도 출처입니다.

스킴이 `http`, `https`, `mailto`, `tel` 중 하나가 아닌 `href`는 그대로 쓰이는 대신 링크를 걸지 않습니다. 탭을 벗어나는 `target`에는 `rel="noopener noreferrer"`가 붙습니다.

### variant

기본값이 `text`이며, 라이브러리의 대부분과 다릅니다. 답 아래의 목록은 제목 하나와 링크 몇 줄이고, 그 둘레의 시트는 이미 상자가 여럿인 열에 상자를 하나 더 얹는 일입니다.

<Demo src="sources/variant">

<<< @/.vitepress/demos/sources/variant.tsx

</Demo>

## 접근성

- `role="list"`를 명시한 `<ol>`입니다. Tailwind의 reset이 마커를 없앤 뒤에도 Safari가 목록 의미를 유지합니다.
- 줄 옆의 번호는 `aria-hidden`입니다. 눈을 위한 이정표이고, 그 줄은 이미 번호가 매겨진 목록 안에 있습니다.
- 목록이 접힐 때 제목은 진짜 버튼이며 Base UI가 패널과 연결합니다.
