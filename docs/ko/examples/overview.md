---
title: 한눈에 보기
order: 1
aside: false
---

# 한눈에 보기

<p class="neba-lede">라이브러리의 모든 컴포넌트를 하나의 화면에 배치한 샘플입니다. 컴포넌트를 낱개로 늘어놓는 대신 실제 제품 화면처럼 구성해서, 함께 놓였을 때의 크기와 정렬을 확인할 수 있게 했습니다.</p>

<Demo src="showcase/app" />

## 이 페이지에서 볼 것

| 블록 | 사용된 컴포넌트 | 볼 만한 것 |
| --- | --- | --- |
| 헤더 | `Toolbar` `Icon` `IconButton` `Pill` | `render={<header />}`로 실제 landmark가 되고, 계속 갱신되는 빌드 상태는 그 용도로 만들어진 `Pill`에 담겨 있습니다 |
| 컨트롤 줄 | `Button` `ButtonGroup` `SegmentedButton` `TextField` `Select` | 같은 `size`에서 버튼과 필드와 셀렉트와 세그먼트는 높이가 같아서 한 줄의 기준선이 유지됩니다 |
| 통계 | `Statistic` `Grid` | 떨어진 수치가 초록으로 나오게 만드는 것이 `betterWhen`입니다 — 실패한 빌드가 줄어든 것은 좋은 소식이니까요 |
| 새 소식 | `Carousel` | scroll snap 기반이라 모바일에서 스와이프가 되고 RTL에서 방향이 뒤집힙니다 |
| 배포 | `Table` `Chip` | 표는 열 목록으로 그려지므로 머리글과 셀이 서로 어긋날 수 없습니다 |
| 프로필 폼 | `Card` `TextField` `Divider` `Chip` `Checkbox` `Button` | 저장은 `loading`을 켜고, 잘못된 주소는 필드에 `error`를 답니다 |
| 사이드바 | `Card` `RadioGroup` `Switch` `Slider` | 설정 목록은 라벨을 한 열로 세우고 스위치를 오른쪽에 정렬합니다 |
| 릴리스 | `Timeline` `Blockquote` `Highlight` `Shortcut` | 순서가 내용이므로 타임라인은 `<ol>`이고, 단축키의 `Mod`는 플랫폼에 따라 해석됩니다 |
| 박스 안의 카드 | `Box` `Card` | `Box`는 묶기만 하고, 구조가 필요한 자리는 `Card`가 맡습니다 |

## 다음으로

- 같은 부품으로 만든 화면 셋: [랜딩 페이지](./concept-landing), [관리자 대시보드](./concept-dashboard), [회원 가입 페이지](./concept-signup).
- 컴포넌트 하나하나의 prop과 예시는 [컴포넌트](../components/) 문서에 있습니다.
