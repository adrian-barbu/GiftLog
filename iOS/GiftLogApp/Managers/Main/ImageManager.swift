//
//  ImageManager.swift
//
//
//  Created by Webs The Word on 11/27/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import FDTake

class ImageManager {
    
    // MARK: Metod
    
    class var fdTakeController:FDTakeController {
        let fdTakeController:FDTakeController = FDTakeController()
        fdTakeController.allowsPhoto = true
        fdTakeController.allowsVideo = false
        fdTakeController.allowsTake = true
        fdTakeController.allowsSelectFromLibrary = true
        fdTakeController.allowsEditing = false
        fdTakeController.defaultsToFrontCamera = false
        return fdTakeController
    }
}
