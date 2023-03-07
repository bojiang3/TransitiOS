//
//  CSVLocationDataInfo.swift
//  AWSDemo
//
//  Created by Jun Wan on 2022/4/26.
//

import Foundation
class CSVLocationDataInfo : Codable {
    var  fileName:String = ""
    var  Longitude:String = ""
    var  Latitude:String = ""
    var   Obstacle:String = ""
    
}

extension  JSONDecoder {
    func toModel<T>(_ type: T.Type, value: Any?) -> T? where T: Decodable {
        guard let value = value else { return nil }
        return toModel(type, value: value)
    }
    /// 字典转模型
    func toModel<T>(_ type: T.Type, value: Any) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "+Infinity", negativeInfinity: "-Infinity", nan: "NaN")
        return try? decoder.decode(type, from: data)
    }
}
