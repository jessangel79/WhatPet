//
//  WikiProtocol.swift
//  WhatPet
//
//  Created by Angelique Babin on 19/03/2021.
//

import Foundation
import Alamofire

protocol WikiProtocol {
    func request(petName: String, completionHandler: @escaping(AFDataResponse<Any>) -> Void) // @escaping (DataResponse<Any, AFError>)
}

extension WikiProtocol {
    
    var wikipediaUrl: String {
        return "https://en.wikipedia.org/w/api.php"
    }
    
// https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&indexpageids=1&titles=barberton%20daisy&redirects=1&exintro=1&explaintext=1
}
