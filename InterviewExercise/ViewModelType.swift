import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    
    func emit(_ action: Action)
}
