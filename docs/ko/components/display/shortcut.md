---
title: Shortcut
order: 10
---

# Shortcut

<p class="neba-lede">키보드 키, 또는 키 조합입니다. 상자보다 라벨이 어려운 컴포넌트입니다.</p>

<Demo src="shortcut/hero" />

```tsx
import { Shortcut } from 'neba';

<Shortcut keys="Mod+K" />
<Shortcut keys="Ctrl+Alt+Delete" os="windows" />
<Shortcut keys={['Mod', '+']} />;
```

## Props

<PropsTable name="Shortcut" />

## 왜 `Kbd`가 아닌가

`<kbd>`는 HTML 요소의 이름이지 개념의 이름이 아닙니다. 이 라이브러리의 컴포넌트 이름은 전부 그것이 **무엇인지**를 말하는 명사이고 — Button, Chip, Badge, Divider, Pill — 축약형은 하나도 없습니다. 그리고 `Shortcut`은 이미 쓰이고 있는 단어이기도 합니다. [MenuItem](../inputs/menu)의 `shortcut` prop이 정확히 이것을 넣으라고 있는 자리입니다.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>이름 바꾸기</MenuItem>
```

## 스타일드 `<kbd>` 이상인 두 가지

둘 다 상자가 아니라 **라벨**에 관한 것입니다.

### `Mod`

`Ctrl+K`라고 쓴 단축키는 모든 Mac 사용자에게 틀렸고, `⌘K`라고 쓴 것은 나머지 모두에게 틀렸습니다. 그래서 "단축키가 얹히는 수식 키"를 뜻하는 토큰 하나가 플랫폼에 따라 해석됩니다. Mac에서는 Command, 그 외에서는 Control입니다.

`os`가 `auto`(기본값)면 브라우저에 묻습니다. `mac` · `windows` · `linux`는 읽는 사람의 플랫폼이 아니라 **특정 플랫폼을 설명해야 하는** 문서를 위한 것입니다 — Windows 빌드를 설명하는 지원 문서, 둘을 나란히 비교하는 표.

`Mod`는 철자가 아니라 **의미**가 바뀌는 유일한 토큰입니다. `Meta`는 Mac에서만 같은 키이고, Windows에서는 Win, Linux에서는 Super입니다.

<Demo src="shortcut/platforms">

<<< @/.vitepress/demos/shortcut/platforms.tsx

</Demo>

### `⌘`는 단어가 아닙니다

스크린 리더는 `⌘`를 "place of interest sign"이라고 읽습니다. 아무의 키보드에도 없는 키입니다. 그래서 글리프로 그려지는 키는 전부 그 옆에 이름을 함께 달고 다니며, 그 이름은 [Badge](./badge)가 쓰는 것과 같은 잘라낸 상자 안에 들어 있어 눈에는 보이지 않습니다. 읽히는 것은 "Command K"이고, 그것이 이 단축키의 이름입니다.

## 예시

### 키

문자열은 `+`로 나뉩니다. 키 자체가 `+`인 경우에만 배열형이 필요합니다. 한 글자짜리 토큰은 대문자로 올라가고 — 키캡에 그렇게 적혀 있으니까요 — 모르는 토큰은 적힌 그대로 나옵니다.

<Demo src="shortcut/keys">

<<< @/.vitepress/demos/shortcut/keys.tsx

</Demo>

### 구분자

macOS는 단축키를 기호의 연속으로 씁니다. `⇧⌘P`이지 `⇧+⌘+P`가 아닙니다. 나머지 둘은 `+`로 잇습니다. `separator`를 생략하면 그 관례를 따르고, 넘기면 넘긴 것을 씁니다.

### 무게와 크기

키캡은 [Chip](./chip)과 같은 이유로 컨트롤 사다리에서 한 단계 아래에 있습니다 — 줄이 기준선을 맞추는 컨트롤이 아니라, 줄 **안에** 들어앉은 토큰입니다. 그리고 고정폭으로 조판되는데, 그것이 칩과 키캡을 한눈에 갈라놓는 신호입니다.

<Demo src="shortcut/variants">

<<< @/.vitepress/demos/shortcut/variants.tsx

</Demo>

## 서버 렌더링

`os="auto"`는 브라우저에 묻고, 서버에는 브라우저가 없습니다. 그래서 `useSyncExternalStore`를 씁니다. 서버 스냅숏으로 하이드레이션한 뒤 브라우저의 답으로 다시 렌더링하는 유일한 API이고, Mac 사용자가 실제로 보는 순서가 바로 그것입니다 — 첫 프레임의 `Ctrl`, 그다음의 `⌘`. 렌더링 중에 `navigator`를 읽으면 하이드레이션 불일치가 되고, 그러면 React가 마크업을 버립니다.

이 순간이 신경 쓰이는 화면이라면 `os`를 명시하면 됩니다.
