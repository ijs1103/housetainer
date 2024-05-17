//
//  MemeberType.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/14/24.
//

import Foundation

enum MemberType: String{
    case housetainer = "H"
    case hometainer = "h"
    case normal = "a"
    
    var isHouseTainer: Bool{
        self == .housetainer
    }
}

extension MemberType{
    var description: String{
        switch self{
        case .housetainer: "하우스테이너"
        case .hometainer: "홈테이너"
        case .normal: "일반회원"
        }
    }
}
