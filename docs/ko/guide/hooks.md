---
title: Hooks
order: 2
---

# Hooks

<p class="neba-lede">컴포넌트가 이미 쓰고 있는 hook을 애플리케이션에서도 쓸 수 있도록 공개한 것입니다. <code>neba/hooks</code>에서 가져오거나, 나머지와 함께 패키지 루트에서 가져옵니다.</p>

```tsx
import { useDisclosure, useMediaQuery, useShortcut } from 'neba/hooks';
```

여기 있는 것은 전부 라이브러리가 스스로 쓰려고 만든 hook입니다. 선정 기준은 그것 하나뿐입니다. 범용 hook 모음은 여기 없고 앞으로도 없습니다. debounce나 `localStorage` 래퍼는 컴포넌트 라이브러리의 일이 아닙니다.

## useDisclosure

[Dialog](../components/feedback/dialog), [Drawer](../components/surfaces/card), [Popover](../components/surfaces/popover), [Tour](../components/feedback/tour), [Menu](../components/inputs/menu)와 네 개의 picker가 받는 `open` / `onOpenChange` 쌍을 호출하는 쪽에서 만들어 줍니다.

```tsx
const { open, onOpen, onClose, onToggle, setOpen } = useDisclosure();

<Button onClick={onOpen}>편집</Button>
<Dialog open={open} onOpenChange={setOpen} title="편집">…</Dialog>
```

`useDisclosure(true)`는 열린 채로 시작합니다. 네 함수 모두 컴포넌트가 사는 동안 identity가 고정이므로, `onClose`를 memo된 자식에 넘겨도 패널이 열릴 때마다 다시 렌더되지 않습니다.

## useMediaQuery · useBreakpoint

```tsx
const wide = useMediaQuery('(width >= 60rem)');
const desktop = useBreakpoint('lg');
```

`useBreakpoint('lg')`는 class name의 `lg:`와 같은 질문을 JavaScript에서 합니다. 너비 표가 하나이므로 이 hook으로 갈라지는 컴포넌트와 CSS에서 갈라지는 utility가 같은 픽셀에서 바뀝니다. `xs`는 `0rem`이라 항상 참입니다.

query 문자열 하나당 살아 있는 `MediaQueryList`가 페이지 전체에 하나뿐입니다. 몇 개의 컴포넌트가 묻든 그렇습니다. 두 hook 모두 서버에서는 `false`를 답합니다. 서버에는 창이 없어 답할 근거가 없기 때문입니다. **깜빡이면 안 되는 레이아웃은 CSS에 적으세요.** 이 hook은 CSS가 내릴 수 없는 결정, 즉 애초에 어떤 컴포넌트를 렌더할지를 정할 때 씁니다. 같은 질문의 CSS 쪽 절반은 [Show](../components/layout/show)입니다.

## useCurrentBreakpoint · useBreakpointValue

```tsx
const current = useCurrentBreakpoint(); // 'xs' | 'sm' | 'md' | 'lg' | 'xl'
const columns = useBreakpointValue({ xs: 1, md: 3 }) ?? 1;
```

`useBreakpointValue`는 breakpoint별 map을 `span`·`spacing`·`maxWidth` 뒤의 cascade와 정확히 같은 방식으로 읽습니다. 모든 항목이 바닥이므로 현재 너비 이하에서 가장 가까운 항목이 적용됩니다. 컴포넌트의 반응형 prop과 직접 계산하는 값이 같은 규칙을 쓰도록 맞춘 것입니다. 값 하나를 그냥 주면 그대로 돌아오고, `undefined`는 이 너비에 해당하는 항목이 map에 없다는 뜻입니다. 위 예시에 `??`를 적어 둔 것도 그래서입니다.

CSS 쪽과 달리 이 hook은 크기가 바뀔 때 다시 렌더합니다. 몇 개를 fetch할지, 차트에 무엇을 넘길지처럼 JavaScript가 알아야 하는 값에 쓰고, 레이아웃은 stylesheet에서 풀리는 prop에 맡기세요. 그 경계는 [breakpoints](../design/breakpoints)에서 설명합니다.

## usePrefersReducedMotion

```tsx
const still = usePrefersReducedMotion();
```

CSS 쪽은 이미 처리되어 있어서, 스타일시트의 모든 keyframe이 한꺼번에 꺼집니다. 이 hook은 끌 rule 자체가 없는, JavaScript로 쓴 움직임에 씁니다. carousel을 넘기는 타이머, 애니메이션되는 숫자, 직접 굴리는 스크롤이 그렇습니다.

## useElementSize

```tsx
const [ref, { width, height }] = useElementSize<HTMLDivElement>();

<div ref={ref} />;
```

구독자마다 하나가 아니라 페이지당 하나의 `ResizeObserver`를 공유합니다. 통보를 기다리지 않고 element가 붙는 즉시 한 번 측정하므로 첫 렌더부터 크기가 잡혀 있습니다. `ResizeObserver`는 첫 entry를 한 task 뒤에 알려 주고, 그때까지 `0 × 0`으로 그리는 컴포넌트는 레이아웃을 두 번 하게 됩니다.

## useOnScreen

```tsx
const [ref, seen] = useOnScreen<HTMLDivElement>({ threshold: 0.2 });
```

`once`의 기본값은 `true`이며, 처음 화면에 들어온 뒤로는 관찰을 멈춥니다. 마운트하기, 시작하기, 불러오기처럼 흔한 용도에는 한 번이면 충분하기 때문입니다. 계속 따라가려면 `once: false`를 주세요.

`IntersectionObserver`가 없는 브라우저에서는 `false`가 아니라 `true`를 답합니다. 관찰할 방법이 없을 때 `false`를 답하면 내용이 영영 보이지 않기 때문입니다.

## useShortcut

```tsx
useShortcut('Mod+K', () => setOpen(true));
useShortcut('?', () => setHelpOpen(true));
```

window에 거는 키 조합이며, 표기는 [Shortcut](../components/display/shortcut)이 그리는 것과 같습니다. 화면의 키캡과 실제로 발동하는 키를 한 문자열로 씁니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control이며 modifier는 정확히 일치해야 합니다.

| 옵션                | 기본값 | 하는 일                                                      |
| ------------------- | ------ | ------------------------------------------------------------ |
| `enabled`           | `true` | unmount 없이 듣기를 멈춤                                     |
| `ignoreWhileTyping` | `true` | focus가 input · textarea · `contenteditable`에 있으면 건너뜀 |
| `preventDefault`    | `true` | 일치하면 `preventDefault` 호출                               |

`ignoreWhileTyping` 덕분에 맨 `/`나 `?`를 바인딩할 수 있습니다. 검색창 안에서 발동하는 한 글자 shortcut은 입력 중인 글자를 가로채기 때문입니다. modifier가 붙은 조합은 보통 어디서나 동작해야 하므로 이 옵션을 끄세요.

핸들러는 ref에 담기므로 listener는 조합당 한 번만 바인딩되고, 렌더마다 다시 걸리지 않습니다. 그러면서도 항상 최신 핸들러를 호출합니다.

window가 아니라 필드 안의 키라면 [TextField](../components/inputs/text-field) · [NumberField](../components/inputs/number-field) · [Combobox](../components/inputs/combobox)의 `shortcuts` prop을 쓰세요. 표기는 같고 control에 붙습니다.
