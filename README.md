
# 하우스테이너 앱

## 목차
- [🏠 프로젝트 소개](#-프로젝트-소개)
- [🏠 Architecture](#-architecture)
- [🏠 순서도](#-순서도)
- [🏠 Feature-0. 공통기능](#-feature-0-공통기능)
    + [고민한 점](#0-1-고민한-점) 
    + [키워드](#0-2-키워드)
- [🏠 Feature-1. 회원가입/로그인](#-feature-1-회원가입/로그인)
    + [고민한 점](#1-1-고민한-점) 
    + [키워드](#1-2-키워드)
- [🏠 Feature-2. 홈 화면](#-feature-2-상품-목록화면-구현)
    + [고민한 점](#2-1-고민한-점)
    + [키워드](#2-2-키워드)
- [🏠 Feature-3. 리스트 화면](#-feature-3-리스트-화면)
    + [고민한 점](#3-1-고민한-점) 
    + [키워드](#3-2-키워드)
- [🏠 Feature-4. 상세 화면](#-feature-4-상세-화면)
    + [고민한 점](#4-1-고민한-점) 
    + [키워드](#4-2-키워드)


## 🏠 프로젝트 소개
인터스타일의 하우스테이너 iOS 앱.
집소개와 이벤트 스케줄을 생성하고 공유하는 커뮤니티입니다.
- 담당 파트 : 로그인,회원가입,회원탈퇴/메인,상세/신고,문의/알림 설정
- 진행 기간 : 2023.11 ~ 진행중 (90% 완료)
- 개발 환경 : swift 5, xcode 15.1
- Deployment Target : iOS 15.0
### 로그인 및 회원가입
<table>
    <tr align="center">
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/b53b12e2-e1ce-4a29-8c7e-02cd5cb2a0bc/></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/d3f6f7ea-f49d-418f-bec4-98be7d9849be/></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/5cff4da9-d13b-43ac-90ba-061c7e971cd9 /></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/e8ed5e2f-cbfb-4738-a7d1-eff80dc60fce/></td>
    </tr>
    <tr align="center">
        <td style="min-width: 175px;">로그인</td>
        <td style="min-width: 175px;">초대코드 인증</td>
        <td style="min-width: 175px;">소식받기</td>
        <td style="min-width: 175px;">닉네임 설정</td>
    </tr>
</table>

### 게시글
<table>
    <tr align="center">
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/dcf9f38a-8c11-466a-ae6b-7d5214509af6 /></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/6bcf07d9-6cd5-4399-b0b3-e677be442215/></td>
      <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/ddc36c69-a4d5-4a45-9b98-11f92ad736ac/></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/893e6d08-b717-489d-bcbf-c9ae8b88dfcc /></td>
    </tr>
    <tr align="center">
        <td style="min-width: 175px;">홈화면</td>
        <td style="min-width: 175px;">홈화면2</td>
       <td style="min-width: 175px;">탭메뉴 - 소셜캘린더 리스트</td>
        <td style="min-width: 175px;">탭메뉴 - 오픈하우스 리스트</td>
    </tr>
</table>

### 소셜캘린더
<table>
    <tr align="center">
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/36965ce6-d181-4d06-a945-10ad408103a6 width="175px"/></td>
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/8a4cbb6f-93b8-401a-84ec-b7fea8cc4d00 width="175px"/></td>
      <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/05783d3e-c283-4ede-bfa3-d61cf355cf46 width="175px"/></td>
    </tr>
    <tr align="center">
        <td>상세 화면</td>
        <td>상세 화면2</td>
      	<td>수정 화면</td>
    </tr>
</table>

### 오픈하우스
<table>
    <tr align="center">
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/ac21c0b2-d5db-4bb1-bf03-5cd024c8e410 width="175px" /></td>
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/e939a642-2293-4f13-a79c-88d75441d1e3 width="175px" /></td>
    </tr>
    <tr align="center">
        <td>상세 화면</td>
        <td>상세 화면2</td>
    </tr>
</table>

### 신고 및 문의하기
<table>
    <tr align="center">
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/f7745d95-e8cb-4fd1-9e11-7e452360bb60 width="175px" /></td>
        <td><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/34937f41-2d37-4b7c-a23a-c1f7cae55cea width="175px" /></td>
    </tr>
    <tr align="center">
        <td>신고하기</td>
        <td>문의하기</td>
    </tr>
</table>


## 🏠 순서도

<table>
    <tr align="center">
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/c5334d9e-030e-4f1b-a1e5-dabe7bb1b8a8 /></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/7efa153f-0df5-4b48-852a-4788bbaaff11 /></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/adca3774-d541-42a3-a05b-79ea4f9d9c98 /></td>
        <td style="min-width: 175px;"><img src=https://github.com/Interstyle/housetainer-ios/assets/42196410/ae51dcab-2fa6-4479-add4-86cd02182a6e /></td>
    </tr>
    <tr align="center">
        <td style="min-width: 175px;">로그인</td>
        <td style="min-width: 175px;">메인화면</td>
        <td style="min-width: 175px;">탭메뉴</td>
        <td style="min-width: 175px;">마이페이지</td>
    </tr>
</table>

## 🏠 Feature-0. 공통기능
### 0-1 고민한 점

#### 1️⃣ 비동기 프로그래밍 및 데이터 바인딩
Combine 프레임워크를 사용하여 비동기적으로 데이터를 처리하고, 뷰 모델과의 데이터 바인딩을 구현하였습니다.
필요시에 Task를 사용하여 비동기 작업을 수행하였고, await를 통해 비동기 호출의 결과를 기다려 콜백 지옥에서 벗어나도록 코드를 작성하였습니다.
                       
#### 2️⃣ 디자인시스템 구축 및 컴포넌트화

디자이너가 정의한 UI컴포넌트, 폰트, 컬러, 아이콘을 디자인 시스템으로 구축하여 개발 편의성을 높이고 재사용성을 높였습니다.
또한, 두번 이상 사용되는 화면의 UI요소들을 커스텀뷰로 생성하거나 extension으로 구현하여 재사용성을 높였습니다.
                       
#### 3️⃣ supabase
슈퍼베이스의 다양한 기능들을 공식문서를 통해 익히고 활용하였습니다.
특히, 단순 쿼리뿐만 아니라 복잡한 join문과 db 최적화를 위한 limit, indexing, filtering 기법들을 익히고 적용하였습니다.                   
                     
### 0-2 키워드
- MVVM, Combine, 디자인시스템
- Supabase: Edge Function, Auth, Storage, CRUD Database                       
## 🏠 Feature-1. 회원가입/로그인
### 1-1 고민한 점

#### 1️⃣ Edge function
슈퍼베이스에서 카카오/네이버 로그인은 기본 Provider로 제공하지 않아서 네이티브로 구현을 하였습니다. 로그인이 성공하면 Edge function에 accessToken과 refreshToken을 넘겨주고 슈퍼베이스의 session을 생성하였습니다.
(애플/구글 로그인은 슈퍼베이스에서 자동으로 session을 생성합니다.)               
#### 2️⃣ 로그인 모달
메인 화면에서 로그인 상태가 아니라면 viewDidAppear 시점에서 로그인 화면(SigninVC)을 풀스크린 모달로 띄워줍니다. 반대로 로그인 상태라면 모달창을 닫고 메인 화면이 나타납니다. 
                       
#### 3️⃣ 로그인 과정
소셜로그인을 성공하여 세션 데이터를 조회하였을때, 기존의 가입자는 메인화면으로 이동을 합니다. 미가입자는 초대코드 입력화면으로 이동합니다. 초대코드의 기한이 만료되었거나 로그인한 계정의 이메일과 db의 저장된 이메일이 다르면 에러메시지를 표시합니다.닉네임 설정 화면에서 닉네임이 중복되면 에러메시지를 표시합니다. 모든 입력을 마치면 회원가입이 완료됩니다.

#### 4️⃣ etc                       
입력필드에 대한 유효성 검사(이메일 형식, 글자수 제한 등)를 적용하였습니다.
에러메시지를 표시하고 유효성 검사를 적용할 수 있는 입력필드(MyTextField)를 컴포넌트화 하여 재사용성을 높였습니다.                       
Combine의 CombineLatest 메서드로 여러 Publisher를 하나의 Publisher로 통합하여 특정 조건에 부합하는 경우에 UIButton을 활성화시켰습니다.
                       
ex) 체크버튼이 체크되어 있고 이메일 필드에 올바른 이메일형식이 입력되어야 UIButton이 활성화됨.           
                       
### 1-2 키워드
- Library : NaverThirdPartyLogin, KakaoSDK, Supabase Auth
- JSON Parsing, WKWebView, CombineLatest, AnyPublisher

## 🏠 Feature-2. 홈 화면
### 2-1 고민한 점 

#### 1️⃣ DiffableDataSource 및 Snapshot 활용
홈화면은 하나의 carousel과 두개의 2X2사이즈 grid로 구성 되어있습니다.
grid 모두 DiffableDataSource 및 Snapshot, CompositionalLayout을 활용하여 높이는 .absolute로 고정값, 너비는 `fractionalWidth`를 활용하여 Cell의 크기가 Device에 따라 유동적으로 조절되게 구현하였습니다.                 
### 2-2 키워드
- CollectionView : DiffableDataSource, CompositionalLayout
- Library : CenteredCollectionView
- UI : Carousel, Grid

## 🏠 Feature-3. 리스트 구현
### 3-1 고민한 점
#### 1️⃣ Underlined TabMenu 구현
기존앱에서 많이 볼수 있는 2depth의 Underlined TabMenu를 구현했습니다.
1. Underlined TabMenu를 탭하면 하나의 CollectionView는 숨기고 나머지 CollectionView를 표시합니다. 
2. 각 CollectionView는 카테고리 버튼을 탭할때 해당되는 데이터를 fetch하고 UI를 업데이트합니다. 
                       
#### 1️⃣ DiffableDataSource, Snapshot, CompositionalLayout 활용
`DiffableDataSource`를 사용하여 데이터와 UI를 동기화시켜 애니메이션과 함께 컬렉션 뷰를 업데이트 하였습니다. 카테고리 버튼을 탭하면 해당되는 데이터를 fetch하고 snapshot을 apply하여 리렌더링 시켜주었습니다.
`CompositionalLayout`을 활용하여 복잡한 레이아웃을 구성하였고 섹션을 쉽게 정의하고 관리할 수 있었습니다.

#### 2️⃣ UI 업데이트 최적화
두개의 UICollectionView가 서로 전환될때 컬렉션 뷰의 높이를 동적으로 계산하고 업데이트하였습니다.
여러개의 카테고리 버튼을 식별하고 관리하기 위하여 상대적으로 더 빠르게 검색할 수 있고 명시적인 딕셔너리 타입를 사용하였습니다.(buttonDictionary)
각 버튼에 대한 참조를 딕셔너리에 저장함으로써, 코드 내에서 버튼을 직접 참조하는 대신 key를 통해 버튼에 접근할 수 있었습니다.
                       
#### 3️⃣ async/await, Task, MainActor.run
`@objc` 메서드 내에서 await 키워드를 사용하기 위해 Task 블록을 사용하였습니다. Task 블록 내부에서는 비동기 코드를 동기적으로 작성할 수 있었습니다.
Task 블록 내부에서 UI업데이트를 일으키는 코드가 사용되었는데 `MainActor.run` 키워드를 사용함으로써 메인스레드에서 작업을 수행할 수 있었습니다.
                       
#### 4️⃣ 즐겨찾기 기능
현재 로그인한 아이디를 통해 각각의 게시물을 즐겨찾기 하였는지 확인하였고 즐겨찾기를 추가/해제하면 즉각적으로 UI를 업데이트 하였습니다.

또한, UIAlertController를 빌더 패턴을 사용하여 구성하였습니다.(AlertBuilder) 옵션을 설정하는 메서드를 연쇄적으로 호출하여 명시적이며 가독성과 재사용성을 높였습니다. 
                       

### 3-2 키워드
- CollectionView : DiffableDataSource, Snapshot, CompositionalLayout
- UI : Underlined TabMenu, Caraousel
- async/await, Task, MainActor.run

## 🏠 Feature-4. 상세 화면
### 4-1 고민한 점 
#### 1️⃣ UX 경험 향상을 위한 작업
- 댓글을 입력할때 뷰의 위치를 조정하여 입력 필드가 가려지지 않도록 하였습니다.
- 댓글에 빈칸을 입력할 때 피드백을 제공하기 위해 토스트 메시지를 표시하였습니다.
- isHidden 속성을 조건부로 사용하여 게시글 수정/삭제 버튼을 숨기거나 표시함으로써, 사용자의 권한에 따라 다른 UI를 제공하였습니다.
- 댓글이 없을때 backgroundView로 상태를 표시하였습니다.                                              
#### 2️⃣ 즉각적인 UI 업데이트
댓글을 등록하면 새로운 댓글 데이터로 UITableView를 업데이트하고 댓글 개수에 따라 UITableView의 높이를 조정하였습니다. 이렇게 한 이유는 댓글 테이블에 스크롤을 없이 보이도록 하기 위함입니다.

#### 3️⃣ 게시글 수정
이미지 슬라이더(HorizontalPhotoSlider)에서 `PHAsset, URL, UIImage`타입을 사용하여 선택된 이미지를 관리하였습니다.이미지는 db최적화를 위해 리사이징하여 jpeg 타입으로 supabase storage에 업로드하였습니다.              
                       
### 4-2 키워드
- UIScrollView, UITableView 
- UI : 이미지 슬라이더
- Supabase storage, PHAsset

