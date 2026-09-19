---
title: A2UI 카탈로그
order: 4
---

# A2UI 카탈로그

<p class="neba-lede">패키지에 A2UI 카탈로그와 그것을 그리는 렌더러가 함께 들어 있습니다. 카탈로그는 에이전트가 어떤 Neba 컴포넌트를 쓸 수 있는지 알려 주고, 어댑터는 에이전트가 써 보낸 것을 그 컴포넌트로 바꿉니다. 에이전트가 JSON으로 화면을 쓰면 여러분의 디자인 시스템으로 나옵니다.</p>

```ts
// 에이전트에게 건네는 것.
import catalog from 'neba/a2ui/catalog.json' with { type: 'json' };

// 에이전트가 써 보낸 것을 그리는 것.
import { createNebaCatalog } from 'neba/a2ui';
```

카탈로그는 스스로를 가리키는 주소에서도 받을 수 있습니다.

```
https://neba.cdget.com/a2ui/catalog.json
```

## A2UI가 무엇인지

[A2UI](https://a2ui.org)는 에이전트가 인터페이스를 JSON으로 서술하고 **호스트**가 자기 디자인 시스템으로 그것을 그리는 프로토콜입니다. 에이전트는 마크업도 CSS도 쓰지 않습니다. ID가 붙은 컴포넌트의 평평한 맵을 쓰고, 렌더러가 그 하나하나를 자기 디자인 시스템의 이름으로 바꿉니다.

카탈로그는 양쪽이 어휘를 맞추는 방법입니다. `catalogId`와 `components`, 렌더러가 실행할 `functions`, 그리고 독자가 아니라 모델을 위해 쓰인 `instructions`가 들어 있는 JSON Schema 파일 하나입니다. 레지스트리는 없습니다. `catalogId`는 URL처럼 생겼을 뿐인 식별자이고, 스펙은 그것이 어디를 가리킬 필요가 없다고 말합니다. 이 파일은 그래도 가리킵니다.

## 반쪽만 가져가도 됩니다

**`neba/a2ui/catalog.json`은 비용이 없습니다.** JSON이라 번들에 들어가지 않으며, 이것을 이 라이브러리의 어댑터로 그릴지 직접 만든 렌더러로 그릴지는 여러분의 결정입니다. 카탈로그만 가져가면 연결은 여러분 몫입니다.

**`neba/a2ui`가 어댑터**이고, 이 라이브러리가 대신 설치해 주지 않는 패키지 셋이 필요합니다.

```bash
npm install @a2ui/react @a2ui/web_core zod
```

셋 다 **optional peer dependency**입니다. `neba/a2ui`가 `neba`에서 다시 export되지 않기 때문에 안전합니다. 번들러가 패키지를 훑을 때 여기까지 오지 않으므로, `Button`만 쓰고 A2UI를 들어 본 적 없는 프로젝트는 새로 해석할 것이 하나도 없습니다. 아래 import를 쓸 때만 딸려 옵니다.

```tsx
import { MessageProcessor } from '@a2ui/web_core/v0_9';
import { A2uiSurface } from '@a2ui/react/v0_9';
import { createNebaCatalog } from 'neba/a2ui';

const processor = new MessageProcessor([createNebaCatalog()]);

processor.processMessages(whateverTheAgentSent);

// …그리고 에이전트가 만든 화면을 하나씩 그립니다.
<A2uiSurface surface={surface} />;
```

이게 전부입니다. 어댑터가 컴포넌트 열여덟 개와 함수 열네 개를 등록하고, 화면이 지정하는 `catalogId`는 에이전트에게 건넨 그 파일의 것입니다. 두 반쪽이 어긋날 수가 없습니다.

### 어댑터가 하는 일과 하지 않는 일

일은 렌더러가 합니다. 에이전트가 리터럴로 썼든 데이터 모델의 경로로 썼든 함수 호출로 썼든, 컴포넌트에 도착할 때는 이미 값으로 풀려 있습니다. 필드에 입력한 것은 데이터 모델에 되돌아가고, 액션은 context까지 모아진 함수로 도착하며, `checks` 규칙은 데이터가 바뀔 때마다 다시 평가됩니다. 이 패키지가 보태는 것은 이름 바꾸기입니다. `Alert`의 `child`는 children이 되고 `Select`의 `options`는 `items`가 됩니다. 그리고 실패한 check의 메시지를 필드가 자기 오류를 그리는 자리에 넣습니다.

렌더러가 바인딩하는 Zod 스키마는 두 번 쓰지 않고 **로드 시점에 `catalog.json`에서 유도합니다.** 그게 핵심입니다. 손으로 쓴 거울은 언젠가 어긋나고, 어긋나는 쪽은 에이전트가 들어 본 적 없는 쪽입니다. 모델은 JSON이 허용하는 것을 정확히 쓰는데 렌더러가 그것을 거부하게 됩니다.

## 열여덟 개

표준 Basic Catalog는 컴포넌트가 열여덟 개이고 스스로를 "의도적으로 성기다"고 말합니다. 이 카탈로그도 열여덟 개이며, 그 숫자는 우연이 아니라 결정입니다. 모델은 138개짜리 목록에서 잘 고르지 못하고, 빠진 것들은 쓸모 있는 prop이 함수나 React 노드, render prop인 컴포넌트들입니다. JSON Schema가 아예 서술할 수 없는 것들입니다.

| 그룹 | 컴포넌트 |
| --- | --- |
| 레이아웃과 표면 | `Flex` `Card` `Divider` `Alert` |
| 표시 | `Typography` `Image` `Chip` `Avatar` `Statistic` `DataList` |
| 입력 | `Button` `TextField` `NumberField` `Checkbox` `Switch` `RadioGroup` `Select` `Slider` |

가장 눈에 띄게 빠진 것은 `Table`이고, 규칙을 가장 잘 보여 주는 예이기도 합니다. Table의 열은 render 함수를 든 객체라서, 카탈로그 항목을 만들려면 컴포넌트가 이미 가진 스키마가 아니라 어댑터가 새로 지어낸 스키마를 써야 합니다.

이름은 Basic Catalog의 것이 아니라 Neba 자신의 것입니다. 그래야 여러분 쪽의 연결이 번역이 아니라 조회가 됩니다.

## 모델에게 하는 말

`instructions`는 스펙이 디자인 지침을 위해 비워 둔 필드이고, 독자가 아니라 모델을 위해 씁니다. 이 카탈로그의 것은 그 말이 없으면 화면이 틀리는 네 가지를 말합니다.

- **여백을 가진 것이 없습니다.** 두 컴포넌트는 `Flex` 안에서만 나란히 놓이고, 사이 간격은 그 `Flex`의 `spacing`입니다.
- **색은 의미입니다.** 여섯 계열이 각각 무언가를 뜻합니다. `danger`는 실패한 것과 파괴하는 것을 위한 것이고, 어느 것도 화면을 다채롭게 만드는 수단이 아닙니다. 한 화면에 `solid` 컨트롤은 하나입니다.
- **사다리는 하나입니다.** `size`는 어디서나 같은 다섯 단계라 컨트롤이 한 줄에 맞춰 섭니다.
- **필드는 자기 말을 들고 있습니다.** `TextField`는 자기 라벨과 자기 오류 메시지를 그립니다. 그 위의 `Typography`는 두 번째 라벨이고, 아래의 것은 필드가 모르는 오류입니다.

## 함수

열네 개이며, 스펙 자신의 이름과 호출 형태를 그대로 씁니다. `required`, `length`, `regex`, `numeric`, `email`, `formatString`, `formatNumber`, `formatCurrency`, `formatDate`, `pluralize`, `openUrl`, `and`, `or`, `not`.

함수를 선언한다는 것은 렌더러가 그것을 구현한다는 주장입니다. 열넷 중 열은 `Intl` 호출 하나이고, 셋은 불 연산이며, 페이지에 무언가를 하는 것은 `openUrl` 하나뿐입니다. 그래서 그것만 `rendererOnly`이고 사용자 활성화를 요구한다고 선언되어 있습니다.

알아 둘 것은 `formatString`입니다. A2UI에는 연산자가 없어서, 값을 문장에 넣는 유일한 방법입니다.

## 버전

카탈로그는 **A2UI v1.0** 기준으로 썼고, 파일이 스스로 `protocolVersion`에 그렇게 적어 둡니다. v0.9 카탈로그에는 `theme` 키가 있었고 모든 컴포넌트를 `ComponentCommon`으로 감쌌습니다. v1.0에는 둘 다 없고 대신 `instructions`와 `anyComponent`·`anyFunction`을 담은 `$defs`가 생겼습니다.

**어댑터는 `@a2ui/react/v0_9`에 등록합니다.** 0.11에는 v1.0 렌더러가 없기 때문입니다. 루트 export는 아직 v0.8입니다. 열여덟 개 컴포넌트는 두 버전이 공유하는 구성만 쓰므로 연결이 번역이 아니라 이름 바꾸기로 끝나고, 실제로 다른 두 가지도 모두 무해합니다. v1.0은 `accessibility`를 카탈로그 항목에서 봉투로 옮겼는데 어댑터가 다시 넣어 주고, v1.0의 `Action`에 생긴 `userMessage`는 v0.9 스키마가 거부하지 않고 떼어 냅니다.

`@a2ui/*` 패키지들은 스펙이 1.0인 지금도 0.11.x에 있으므로, 형식보다 그 주변 도구가 먼저 움직일 것으로 보면 됩니다. v1.0 React 렌더러가 나오면 바뀌는 것은 이 패키지 안의 import 한 줄이고 `catalog.json`은 그대로입니다.

## 다음

- 프로토콜 자체는 [a2ui.org](https://a2ui.org)에, 본보기로 삼은 [Basic Catalog](https://github.com/google/A2UI/blob/main/specification/v1_0/catalogs/basic/catalog.json)는 저장소에 있습니다.
- 컴포넌트 자체의 prop이 무슨 뜻인지는 [컴포넌트](../components/)에 있습니다.
