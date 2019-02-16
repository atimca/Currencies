//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

protocol RepeatingTimer {
    init(timeInterval: TimeInterval, eventHandler: @escaping (() -> Void))
    func go()
}

class DispatchTimer: RepeatingTimer {

    private enum State {
        case resumed
    }

    private var state: State?

    private let timer: DispatchSourceTimer

    required init(timeInterval: TimeInterval, eventHandler: @escaping (() -> Void)) {
        timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: timeInterval)
        timer.setEventHandler(handler: {
            eventHandler()
        })
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        go()
    }

    func go() {
        if state == .resumed { return }
        state = .resumed
        timer.resume()
    }
}
