//
//  Title.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/11.
//

struct Title {
    private init () {}
    static let invite = "초대 회원가입"
    static let verify = "초대코드 인증"
    static let noInvite = "초대코드가 없어요"
    static let alreadySigned = "이미 다른 SNS 계정으로 가입했나요?"
    static let signup = "초대코드가 없으신가요?"
    static let signin = "SNS계정으로\n간편하게 시작하세요"
    static let agree = "개인정보 제공 동의 (필수)"
    static let magazine = "인터스타일 매거진 둘러보기"
    static let nickname = "닉네임 설정"
    static let pick = "PICK"
    static let main = "홈"
    static let socialCalendar = "소셜 캘린더"
    static let openHouse = "오픈하우스"
    static let moment = "초대의 순간"
    static let more = "더 보기"
    static let register = "등록"
    static let nicknameRegister = "닉네임 등록"
    static let socialMember = "소셜링 멤버"
    static let homeLetter = "홈 레터"
    static let complaint = "신고하기"
    static let asking = "문의하기"
    static let wondering = " 님의 오픈하우스가 궁금하다면?"
    static let writer = "작성자"
    static let subject = "대상"
    static let reportReason = "신고 사유"
    static let warning = "신고는 반대 의견을 표시하는 기능이 아닙니다."
    static let terms = "약관 동의"
    static let start = "시작하기"
    static let notMyProfileEmptyHouses = "아직 소개중인 공간이 없어요.\n좋은 공간이 소개되기를 기대해주세요!"
    static let checkBoxArray: [String] = ["스팸홍보/도배글",
                                          "음란성/선정성",
                                          "개인정보 노출",
                                          "불법정보 포함",
                                          "청소년에게 유해한 내용",
                                          "욕설/생명경시/혐오/차별적 표현",
                                          "불쾌한 표현",
                                          "기타"]
    static func modal(type: ModalType) -> String {
        "회원님의 \(type.word)가 접수되었습니다!"
    }
    static func modalContent(type: ModalType, email: String) -> String {
            """
                회원님의 소중한 의견 감사합니다 :)
                \(type.word) 내용에 대한 답변은 회원님의 이메일인\n \(email)\n 으로 전송해드립니다. 최대한 빠른 답변을
                원칙으로 하지만, 사안에 따라 시간이 소요될 수 있다는 점 안내드려요!
            """
    }
}
