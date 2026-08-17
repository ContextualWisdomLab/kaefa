# r-lib/actions v2.12.1 공급망 추적

## 결정

세 개의 R 검증 workflow에서 사용하는 setup-pandoc, setup-r,
setup-r-dependencies, check-r-package를 v2.12.1 release commit
d3c5be51b12e724e68f33216ca3c148b66d5f0b6으로 통일한다. 전체 commit SHA 외의 태그·브랜치·짧은 SHA는
회귀 계약이 거부한다.

## 호환성 범위

공식 NEWS에 따르면 v2.12는 Node.js 24 전환, public RSPM 기본값 조정,
아키텍처별 cache key와 Pandoc 3.8.3을 포함하고, v2.12.1은 setup-r URL parser
경고와 Quarto action을 갱신한다. 현재 workflow의 R matrix, 권한, testthat 실행,
--no-tests 분리와 scheduled full-suite 계약은 변경하지 않는다.

## 되돌리기

runner 또는 package 호환성 회귀가 확인되면 네 action을 함께 마지막 검증 SHA로
되돌리고 R-CMD-check, fast/full test suite와 중앙 보안 검사를 같은 헤드에서 다시
수행한다. 일부 action만 되돌리거나 이동 태그로 우회하지 않는다.

## 참고문헌

R-lib. (2026, June 23). *r-lib/actions v2.12.1* [Software release notes].
[NEWS.md](https://github.com/r-lib/actions/blob/d3c5be51b12e724e68f33216ca3c148b66d5f0b6/NEWS.md)

R-lib. (2026). *Update NEWS for v1.12.1* [Source code commit].
[d3c5be51b12e724e68f33216ca3c148b66d5f0b6](https://github.com/r-lib/actions/commit/d3c5be51b12e724e68f33216ca3c148b66d5f0b6)
