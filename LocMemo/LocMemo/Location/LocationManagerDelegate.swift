//
//  LocationManagerDelegate.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreLocation

/**
 * The system calls this delegate object’s methods from the thread in which we started the corresponding
 * location services. That thread must itself have an active run loop, like the app's main thread.
 */
class LocationManagerDelegate: CLLocationManagerDelegate {
    func isEqual(_ object: Any?) -> Bool {
        <#code#>
    }

    var hash: Int

    var superclass: AnyClass?

    func `self`() -> Self {
        <#code#>
    }

    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        <#code#>
    }

    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }

    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        <#code#>
    }

    func isProxy() -> Bool {
        <#code#>
    }

    func isKind(of aClass: AnyClass) -> Bool {
        <#code#>
    }

    func isMember(of aClass: AnyClass) -> Bool {
        <#code#>
    }

    func conforms(to aProtocol: Protocol) -> Bool {
        <#code#>
    }

    func responds(to aSelector: Selector!) -> Bool {
        <#code#>
    }

    var description: String
}
