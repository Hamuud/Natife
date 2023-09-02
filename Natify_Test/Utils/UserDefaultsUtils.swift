//
//  UserDefaultsUtils.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 02.09.2023.
//

import Foundation

class UserDefaultsUtils {

    static var shared = UserDefaultsUtils()

        func setDarkMode(enable: Bool) {
            let defaults = UserDefaults.standard
            defaults.set(enable, forKey: Constants.DARK_MODE)
        }
    
         func getDarkMode() -> Bool {
             let defaults = UserDefaults.standard
             return defaults.bool(forKey: Constants.DARK_MODE)
         }
}
