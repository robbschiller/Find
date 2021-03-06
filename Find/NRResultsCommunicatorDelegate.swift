//
//  NRResultsCommunicatorDelegate.swift
//  Find
//
//  Created by Jonathon Toon on 3/1/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

import Foundation

protocol NRResultsCommunicatorDelegate {
    
    func receivedDomainSearchJSON(objectNotation: NSData) -> Void
    func domainSearchJSONFailedWithError(error: NSError) -> Void
}