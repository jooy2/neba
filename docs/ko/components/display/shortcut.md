---
title: Shortcut
order: 10
---

# Shortcut

<p class="neba-lede">키보드 단축키를 키캡 형태로 표시합니다. 플랫폼에 따라 수식 키의 표기가 자동으로 바뀝니다.</p>

<Demo src="shortcut/hero" />

```tsx
import { Shortcut } from 'neba';

<Shortcut keys="Mod+K" />
<Shortcut keys="Ctrl+Alt+Delete" os="windows" />
<Shortcut keys={['Mod', '+']} />;
```

## Props

<PropsTable name="Shortcut" />

[MenuItem](../inputs/menu)의 `shortcut` prop이 이 컴포넌트를 넣도록 마련된 자리입니다.

```tsx
<MenuItem shortcut={<Shortcut keys="Mod+E" />}>이름 바꾸기</MenuItem>
```

## 예시

### keys

문자열은 `+`를 기준으로 나뉩니다. 키 자체가 `+`일 때만 배열 형태가 필요합니다. 한 글자 토큰은 키캡 표기에 맞춰 대문자로 올라가고, 인식하지 못한 토큰은 넘긴 그대로 출력됩니다.

<Demo src="shortcut/keys">

<<< @/.vitepress/demos/shortcut/keys.tsx

</Demo>

### os와 `Mod`

`Mod`는 "그 플랫폼의 기본 수식 키"를 뜻하는 토큰입니다. macOS에서는 Command(`⌘`), 그 외에서는 Control로 해석됩니다. 표기만 바뀌는 다른 토큰과 달리 `Mod`는 가리키는 키 자체가 달라지는 유일한 토큰입니다.

`os`의 기본값 `auto`는 브라우저에 현재 플랫폼을 물어봅니다. `mac` · `windows` · `linux`를 명시하는 것은 특정 플랫폼을 설명하는 문서를 위한 것입니다.

같은 문자열을 라이브러리가 **바인딩**에도 씁니다. [CommandPalette](../inputs/command-palette)의 `shortcut`, [TextField](../inputs/text-field) · [NumberField](../inputs/number-field) · [Combobox](../inputs/combobox)의 `shortcuts`가 모두 이 어휘를 읽습니다. 별칭도 마찬가지입니다 — `Cmd` · `Command` · `Meta` · `Win`은 한 키이고, `Esc` · `Return` · `Opt` · `Up`은 각각 `Escape` · `Enter` · `Alt` · `ArrowUp`의 다른 표기입니다. 화면에 그린 키캡과 실제로 발동하는 키가 같은 문자열입니다.

<Demo src="shortcut/platforms">

<<< @/.vitepress/demos/shortcut/platforms.tsx

</Demo>

### separator와 variant

`separator`를 생략하면 플랫폼 관례를 따릅니다. macOS는 기호를 붙여 쓰고(`⇧⌘P`), 나머지 플랫폼은 `+`로 잇습니다. 직접 넘기면 그 문자를 씁니다.

키캡은 [Chip](./chip)처럼 컨트롤 높이보다 한 단계 아래이고, 고정폭으로 조판됩니다.

<Demo src="shortcut/variants">

<<< @/.vitepress/demos/shortcut/variants.tsx

</Demo>

## 서버 렌더링

`os="auto"`는 브라우저에 의존하므로 SSR에서는 첫 프레임이 기본값으로 렌더링된 뒤 hydration 이후 실제 플랫폼 표기로 바뀝니다. macOS에서는 `Ctrl`이 잠깐 보였다가 `⌘`로 교체됩니다. 이 전환을 피해야 하는 화면에서는 `os`를 명시하세요.

## 접근성

- `⌘` 같은 기호는 screen reader가 키 이름으로 읽지 못합니다. 글리프로 그려지는 키는 시각적으로 숨긴 이름을 함께 담고 있어 "Command K"로 읽힙니다.
