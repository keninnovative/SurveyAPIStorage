//
//  SurveyOffer.swift
//  TapResearchTest
//
//  Created by Ken Nyame on 6/30/21.
//

import Foundation

struct SurveyOffer: Codable {
    let hasOffer: Bool
    let offerReason: Int
    let reasonComment: String?
    let offerUrl: URL?
    let abandonUrl: URL?
    var messageHash: MessageHash?
}

struct MessageHash: Codable {
    let min: String
    let max: String
    let currency: String
}
