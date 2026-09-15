---
title: AnimateShake
order: 9
---

# AnimateShake

<p class="neba-lede">세트에서 유일하게 아니라고 말하는 효과입니다. 틀린 비밀번호, 보내지지 않은 양식, 놓은 자리에 놓일 수 없던 행. 여기 있는 다른 애니메이션이 전부 도착하는 내용이라면 이것은 대답입니다.</p>

<Demo src="animate-shake/hero" minHeight="180" />

```tsx
import { AnimateShake } from 'neba';

<AnimateShake play={attempts}>
  <TextField label="Passphrase" error={message} />
</AnimateShake>;
```

## Props

<PropsTable name="AnimateShake" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [prop 규약](../../design/prop-conventions)에 있습니다.

여기 있는 다른 효과와 달리 기본값이 `trigger="manual"`입니다. mount에서 실행되는 흔들림은 장식이고, 움직이는 장식은 독자가 무시하는 법을 배우는 것입니다. 실패한 횟수를 `play`에 묶으세요. 숫자가 바뀔 때마다 안의 것을 remount하지 않고 흔들림을 다시 재생하므로, 두 번째 오답도 첫 번째만큼 움직이고 focus도 제자리에 남습니다.

`mode`는 없습니다. 요소가 앉아 있는 자리에서 시작해 그 자리에서 끝나므로 도중에 끊겨도 어긋난 채 남지 않고, `repeat`는 절대 주지 마세요.

## 예시

### distance

가장 크게 흔들릴 때의 이동 거리입니다. CSS 길이나 픽셀 숫자를 받습니다. 기본값은 `6`입니다. 고개를 젓는 정도이지 물건을 흔드는 정도가 아닙니다.

## 접근성

- 모션 감소 설정에서는 흔들림이 아무것도 움직이지 않은 마지막 프레임으로 바로 넘어가므로, 흔들림이 메시지를 나르는 유일한 수단이어서는 안 됩니다. 말로도 적으세요. 필드의 `error`가 스크린 리더가 읽는 것입니다.
- 실패한 컨트롤로 focus도 옮기세요. 그것을 보고 있지 않은 독자에게 움직임은 아무것도 전하지 못합니다.
