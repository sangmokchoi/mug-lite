# mug-lite
<img
  src="https://github.com/sangmokchoi/mug-lite/assets/63656142/b499fda1-5612-49f5-9af2-5e42e52c3887"
  width="50%"
/>
</br>

## 00. 개요

- **개발 기간:** 2023.5 - 2023.08

- **Github:** [https://github.com/sangmokchoi/mug-lite](https://github.com/sangmokchoi/mug-lite)

- **App Store:** [<mug-lite> 다운로드 바로가기](https://apps.apple.com/app/mug-lite/id6450693152)

- 기술 구조 요약
  - **UI:** `UIKit`, `Storyboard`
  - **Communication:** `Confluence`
  - **Architecture**: `MVC`
  - **Data Storage**: (Firebase) `Firestore Database`
  - **Library/Framework:**
      - **Firebase**
      `Authentication`, `Firebase Firestore`
      - **API**
      `Microsoft Azure Bing News API`
      - **Google**
      `AdMob`, `Analytics`
      - **In App Purchase**
      `StoreKit`

</br>

## 01. mug-lite 소개 및 기능


<aside>

- 내가 원하는 키워드의 뉴스만 골라 보는 뉴스앱!
- 헤드라인만 쏙! 관련 기사를 쓱-쓱 넘기면서 즐기세요
- 자세한 뉴스 내용은 바로가기 버튼을 눌러주세요
- 뉴스를 불러오고 화면 끝까지 도달하면, 화면 우측 상단의 '새로고침' 버튼을 눌러 새로운 뉴스를 불러올 수 있어요
- 뉴스를 1번 불러오는데 150 포인트가 소모됩니다. 키워드 탭을 누르거나, 새로고침 버튼을 누르면 뉴스가 불러와지기 때문에, 150 포인트가 소모돼요.
('바로가기' 버튼을 누르거나, 좌우로 뉴스를 슬라이드할 때는 포인트가 소모되지 않아요)
- 광고를 보거나 인앱구매를 통해 포인트를 충전할 수 있어요.

</aside>

</br>


## 02. 구현 사항

<table>
  <tr>
    <td align="center"><b>2.1. 키워드 추가</b><br /><br /><img src="https://github.com/sangmokchoi/mug-lite/assets/63656142/ccb8f2a3-343d-4b7b-bd29-599fe0683011" width="200"/></td>
    <td>
    <p>
         키워드 추가
어플리케이션 실행 후 키워드 추가 "+" 버튼을 눌러주세요.
내가 원하는 뉴스 키워드를 입력 후(예: 유재석) 팔로우 버튼을 누르면 끝!
      </p>
   </td>
  </tr>
  <tr>
    <td align="center"><b>2.2. 키워드 관련 뉴스 보기</b><br /><br /><img src="https://github.com/sangmokchoi/mug-lite/assets/63656142/bbe1b588-88ac-4b91-b870-accb35cabfb8" width="200"/></td>
    <td>
      <p>
        키워드를 팔로우 하면 상단에 탭이 생성돼요.
인스타그램 스토리처럼 키워드 탭을 눌러 옆으로 쓱쓱 넘기면서 새로운 소식을 접하세요.
새로고침 버튼은 더이상 불러온 뉴스가 없을 때 나타납니다.
      </p>
    </td>
  </tr>
  <tr>
    <td align="center"><b>2.3. 뉴스 저장하기</b><br /><br /><img src="https://github.com/sangmokchoi/mug-lite/assets/63656142/7950f9cd-8f17-4610-924c-cdddb834ff58" width="200"/></td>
    <td>
    <p>
        뉴스를 보다가 "아! 이건 기억해야돼!" 하는 순간에는 우측 상단에 북마크 탭을 눌러주세요!
북마크한 뉴스는 Safari의 읽기 목록에서 확인 가능해요
      </p>
    </td>

  </tr>
  <tr>
    <td align="center"><b>2.4. 뉴스 새로고침하기</b><br /><br /><img src="https://github.com/sangmokchoi/mug-lite/assets/63656142/44cdcc6f-dd41-4280-a37a-691653c38cde" width="200"/></td>
    <td>
<p>
        뉴스를 끝까지 스와이프해서 더이상 뉴스가 불러와지지 않는다면, 새로고침 버튼을 눌러서 새로운 뉴스를 가져올 수 있어요
      </p>
</td>
</table>



</br>

## 03. **기술적 의사결정**


### 3.1. **Bing News API**
월 1,000건 이하의 API 콜은 무료이며, 그 이상의 콜이 발생하게 되면 비용을 청구하는 API입니다. 월 1,000건은 현재 단계에서 충분이 이용할 수 있다고 여겼기에 해당 API 사용을 결정하게 되었습니다.

### 3.2. In App Purchase
뉴스를 불러오는데 소요되는 포인트를 충전할 수 있게끔 `StoreKit`을 이용해 인앱 구매를 구현했습니다. '광고 보고 포인트 받기'와 인앱 구매를 통해 유저가 뉴스를 볼 수 있는 포인트를 얻을 수 있는 수단을 다양화하고자 했습니다.

### 3.3. CocoaPods
오픈소스 라이센스 고지를 위해 `AcknowList` 라이브러리를 사용했습니다. dependency 관리를 위해 CocoaPods을 사용했습니다.


## 04. **Trouble Shooting**


### 4.1. Instagram Story 형식의 UI
#### 문제점
인스타그램의 스토리 기능을 오마주하여 뉴스의 썸네일을 강조한 화면을 전체 화면에 가득 차게끔 구성했습니다. 이를 통해 흥미로운 썸네일을 발견한 유저가 해당 뉴스를 곧장 읽게끔 하였습니다.

그러나 인스타그램 스토리 화면을 구현하는 화면을 구성하는 데 어려움이 많았습니다.
#### 해결방안
그래서 `OHCubeView`라는 Instagram Story slide를 지원하는 3D형태의 UI 관련 라이브러리를 이용했습니다. 이를 통해 좌우로 유저가 화면을 자유롭게 넘기며 흥미로운 기사를 찾을 수 있게끔 지원했습니다.

### 4.2. AdMob 리워드 광고
#### 문제점
리워드 광고 정책 변경으로 인해, 리워드 광고 요청 시, 명확한 포인트 사용처와 지급 내용을 리워드 광고 요청 시에 유저에게 고지해야 한다는 경고가 발생했습니다. 이로 인해 광고 송출이 제대로 되지 않아 유저가 '광고 보고 포인트 받기' 기능을 이용할 수 없었고, 뉴스를 볼 수 있는 인스타그램 스토리 UI 화면 진입 시, 광고가 송출되지 않는다는 경고문이 강제로 나타났습니다.
#### 해결방안
그래서 광고를 불러오기 전에 유저에게 확인을 받는 알림을 추가했고, 이 과정에서 유저가 확인을 해야만 광고를 요청하게끔 수정했습니다. 다행히 AdMob 측에 재확인 요청을 보낸지 하루만에 빠르게 조치해주어 광고가 다시금 송출될 수 있었습니다.

</br>
