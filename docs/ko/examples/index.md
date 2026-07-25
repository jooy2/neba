---
title: 예제
order: 3
aside: false
---

# 예제

<p class="neba-lede">라이브러리의 모든 컴포넌트를 한 화면에 배치한 샘플입니다. 아크릴 표면은 실제 콘텐츠 위에 놓였을 때만 뜻이 생기므로, 낱개로 늘어놓는 대신 제품 화면처럼 짰습니다.</p>

<Demo src="showcase/app" />

## 이 페이지에서 볼 것

| 블록 | 사용된 컴포넌트 | 볼 만한 것 |
| --- | --- | --- |
| 툴바 | `Button` `ButtonGroup` `TextField` `Select` | 같은 `size`에서 버튼과 필드와 셀렉트는 높이가 같아서 한 줄의 기준선이 유지됩니다 |
| 통계 | `Box` `Typography` | `solid`도 색으로 가득 채우지 않기 때문에 그 위의 글자가 그대로 읽힙니다 |
| 배포 | `Table` `Chip` | 표는 열 목록으로 그려지므로 머리글과 셀이 서로 어긋날 수 없습니다 |
| 프로필 폼 | `Card` `TextField` `Divider` `Chip` `Checkbox` `Button` | 저장은 `loading`을 켜고, 잘못된 주소는 필드에 `error`를 답니다 |
| 사이드바 | `Card` `RadioGroup` `Switch` `Slider` | 설정 목록은 라벨을 한 열로 세우고 스위치를 오른쪽에 정렬합니다 |
| 박스 안의 카드 | `Box` `Card` | 박스는 묶고, 카드는 구조를 만듭니다 |

컴포넌트 하나하나의 prop과 예시는 [컴포넌트](../components/) 문서에 있습니다.
