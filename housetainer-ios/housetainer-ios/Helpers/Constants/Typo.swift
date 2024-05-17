//
//  Typo.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/08.
//

import UIKit

struct Typo {
    private init () {}
    static func Heading1() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
    }
    static func Heading2() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)
    }
    static func Heading2Semibold() -> UIFont {
        UIFont(name: "Pretendard-Semibold", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold)
    }
    static func Heading3() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
    }
    static func Title1() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
    }
    static func Title2() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 18) ?? .systemFont(ofSize: 18, weight: .medium)
    }
    static func Title3() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
    }
    static func Title4() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
    }
    static func Title5() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 15) ?? .systemFont(ofSize: 15, weight: .bold)
    }
    static func Title6() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)
    }
    static func Title7() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 15) ?? .systemFont(ofSize: 15, weight: .medium)
    }
    static func Title8() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 15) ?? .systemFont(ofSize: 14, weight: .medium)
    }
    static func Body1() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 16) ?? .systemFont(ofSize: 16, weight: .regular)
    }
    static func Body1Medium() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 18) ?? .systemFont(ofSize: 18, weight: .medium)
    }
    static func Body1SemiBold() -> UIFont {
        UIFont(name: "Pretendard-SemiBold", size: 18) ?? .systemFont(ofSize: 18, weight: .semibold)
    }
    static func Body2() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 15) ?? .systemFont(ofSize: 15, weight: .regular)
    }
    static func Body2Semibold() -> UIFont {
        UIFont(name: "Pretendard-Bold", size: 16) ?? .systemFont(ofSize: 16, weight: .bold)
    }
    static func Body2Medium() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
    }
    static func Body3() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 14) ?? .systemFont(ofSize: 14, weight: .regular)
    }
    static func Body3Medium() -> UIFont {
        UIFont(name: "Pretendard-Medium", size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
    }
    static func Body4() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 13) ?? .systemFont(ofSize: 13, weight: .regular)
    }
    static func Body5() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
    }
    static func Body6() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 11) ?? .systemFont(ofSize: 11, weight: .regular)
    }
    static func Body7() -> UIFont {
        UIFont(name: "Pretendard-Regular", size: 10) ?? .systemFont(ofSize: 10, weight: .regular)
    }
    static func Caption1() -> UIFont{
        UIFont(name: "Pretendard-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
    }
}
