---
title: 관리자 대시보드
order: 3
aside: false
---

# 관리자 대시보드

<p class="neba-lede">실재하지 않는 상점 Grange의 관리 화면입니다. 내비게이션 레일, 필터 줄, 네 개의 수치, 행마다 동작이 달린 표, 설정 묶음이 한 화면에 같은 크기로 놓여 있습니다. size 사다리가 실제로 지켜지는지 가장 잘 드러나는 배치입니다.</p>

<Demo src="concepts/dashboard" min-height="736px" />

소스는 `docs/.vitepress/demos/concepts/dashboard.tsx` 한 파일입니다. 표는 실제로 동작하니 검색해 보고, 채널로 거르고, 행을 선택해 보면 일괄 동작이 나타납니다.

## 무엇으로 만들었는지

| 블록 | 사용된 컴포넌트 | 볼 만한 것 |
| --- | --- | --- |
| 셸 | `Panes` `Pane` | 분할이 곧 레이아웃입니다. 폭을 지키는 레일과 남은 자리를 차지하는 작업 영역, 그 사이는 드래그로 조절됩니다 |
| 내비게이션 레일 | `List` `ListItem` `Icon` `Chip` | 리스트에 `render={<nav />}`, 현재 행에 `selected`, 개수는 `action` 슬롯에 들어갑니다 |
| 레일 하단 | `Pill` `Card` `ProgressLinear` | 동기화 상태는 `title`과 `description`을 가진 `Pill`이고, 사용량은 작은 `Card` 안의 바입니다 |
| 앱 바 | `Toolbar` `Breadcrumb` `Badge` `Avatar` `Tooltip` | `position="sticky"`라서 아래 표가 스크롤되는 동안에도 동작에 계속 닿습니다 |
| 알림 | `Alert` | 살펴야 할 것 하나를 맨 위에서 한 번만 말하고, 자체 `action`을 함께 답니다 |
| 수치 | `GridContainer` `Grid` `Statistic` | 환불률이 떨어졌을 때 초록으로 나오게 만드는 것이 `betterWhen="down"`입니다 |
| 필터 | `TextField` `Select` `DateRangePicker` | 같은 `size`에서 셋의 높이가 같아서 한 줄의 기준선이 유지됩니다 |
| 일괄 동작 | `Button` `Dialog` `Toast` | 선택이 있을 때만 나타나고, 파괴적인 쪽은 `Dialog`로 먼저 확인합니다 |
| 표 | `Tabs` `Table` `Checkbox` `Chip` `Menu` `ContextMenu` `Pagination` | 전체 선택은 머리글 칸에 놓인 `indeterminate` 체크박스입니다. 행마다 `Menu`가, 표 전체에는 `ContextMenu`가 붙습니다 |
| 하단 줄 | `Card` `ProgressLinear` `Timeline` `Switch` `ProgressCircular` | 같은 그리드 위의 카드 셋: 부족한 것, 있었던 일, 설정된 것 |

## 참고

- 표의 `stickyHeader`가 스크롤되는 pane 안에서도 열 머리글을 붙잡아 둡니다.
- 행 메뉴의 trigger는 `label`을 가진 `IconButton`이라, 각 행의 동작마다 어느 행의 것인지 말하는 접근성 이름이 붙습니다.
- 필터링은 평범한 React 상태입니다. 표는 받은 것을 그대로 그리고, 받은 것이 없으면 `empty`를 보여줍니다.
