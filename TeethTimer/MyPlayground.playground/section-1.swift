// Playground - noun: a place where people can play

import UIKit

class Test: NSObject {
    

    var currentlyRunning = false
    var notCurrentlyRunning: Bool {
        get {
            return !currentlyRunning
        }
        set(notRunning) {
            currentlyRunning = !notRunning
        }
        }
}


let aTest = Test()

aTest.currentlyRunning
aTest.notCurrentlyRunning

aTest.notCurrentlyRunning = false
aTest.currentlyRunning
