//
//  Observable.swift
//  MySTC

import Foundation

public protocol Disposable {
    func dispose()
}

public class Event<T, R> {

    public typealias EventHandler = (T, R) -> ()
    fileprivate var eventHandlers = [Invocable]()
    weak var eventRaiser: AnyObject?
    public init() {
    }

    public func raise(data: T) {
        for handler in self.eventHandlers {
            handler.invoke(data: data, eventRaiser: eventRaiser as Any)
        }
    }

    public func addHandler<U: AnyObject>(target: U, handler: @escaping  EventHandler) -> Disposable {
        let wrapper = EventHandlerWrapper(target: target, handler: handler, event: self)
        eventHandlers.append(wrapper)
        return wrapper
    }
}

private protocol Invocable: class {
    func invoke(data: Any, eventRaiser: Any)
}

private class EventHandlerWrapper<T: AnyObject, U, R>: Invocable, Disposable {
    func invoke(data: Any, eventRaiser: Any) {
        handler(data as! U, eventRaiser as! R)
    }

    weak var target: T?
    let handler: (U, R) -> Void
    let event: Event<U, R>

    init(target: T?, handler: @escaping (U, R) -> Void, event: Event<U, R>) {
        self.target = target
        self.handler = handler
        self.event = event
    }

    func dispose() {
        event.eventHandlers = event.eventHandlers.filter { $0 !== self }
    }
}

public class Observable<T, U> {

    public let didChange: Event<(T, T), U>
    private var value: T
    public init(_ initialValue: T, eventRaiser: AnyObject) {
        value = initialValue
        didChange = Event()
        didChange.eventRaiser = eventRaiser
    }

    public func set(newValue: T) {
        let oldValue = value
        value = newValue
        didChange.raise(data: (oldValue, newValue))
    }

    public func get() -> T {
        return value
    }
}
