# farmmon_flutter

딸기 탄저병, 잿빛곰팡이병 발생 모니터링을 위한 안드로이드앱
- 충남 논산딸기연구소의 모델을 사용함

1. Layout: 품목을 좌측메뉴에 놓고 품목을 선택하면 우측창에 병해충별 위험도를 나타냄
2. 좌측창의 아이콘 품목아이콘으로 수정할 것
3. 우측창에는 fl_chart를 이용하여 날짜별 막대그래프로 위험도 표시
4. HTTP API post방식을 사용. multi-part data가 잘 안되서 json string 전송방식으로 변경(기상데이터를 압축한 문자열을 json value값으로 전달)
5. 일단, iot포털데이터를 받아서 그래프 업데이트만 구현함
6. 농가 등록메뉴 구성함(사용자편이 무시하고 기능만 구현: 농가명_필수, 장치명_선택, iot포털serviceKey_필수)
7. 시간별 환경데이터 갱신된 데이터만 받아오도록 수정
8. 복수의 농가에 대해 적용되도록 수정필요함

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

<img src="https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/f624db8e-674a-4577-9589-29605d7f01b3.jpg"  width="300" height="600">
<img src="https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/7276478e-0d71-4a80-a8cb-e31aa42e66a3.jpg"  width="300" height="600">

                  
                  
                
