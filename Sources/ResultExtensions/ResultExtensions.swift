// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

public extension Result where Success == Data {
    func decode<T: Decodable>(decoder: T.Type) -> Result<T, Error> {
        do {
            let successData = try get()
            let dataModel = try JSONDecoder().decode(decoder, from: successData)
            return .success(dataModel)
            
        } catch let error {
            return .failure(error)
        }
    }
}

public extension Result where Success: Encodable {
    func encode() -> Result<Data, Error> {
        do {
            let successDataModel = try get()
            let rawData = try JSONEncoder().encode(successDataModel)
            return .success(rawData)
            
        } catch let error {
            return .failure(error)
        }
    }
}

public extension Result {
    func fold(success successHandler: (Success) -> Void,
                     failure failureHandler: (Error) -> Void) {
        
        switch self {
        case .success(let successValue):
            successHandler(successValue)
        case .failure(let error):
            failureHandler(error)
        }
    }
}

public extension Result {
    func send(through subject: PassthroughSubject<Self, Never>) {
        subject.send(self)
    }
}

public extension Result {
    func asyncMap<NewSuccess>(_ transform: (Success) async -> NewSuccess) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await .success(transform(success))
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func asyncMapError(_ transform: (Failure) async -> Failure) async -> Result<Success, Failure> {
        switch self {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return await .failure(transform(failure))
        }
    }
}

public extension Result {
    func asyncFlatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await transform(success)
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func asyncFlatMapError(_ transform: (Failure) async -> Result<Success, Failure>) async -> Result<Success, Failure> {
        switch self {
        case .success(let success):
            return .success(success)
        case .failure(let failure):
            return await transform(failure)
        }
    }
}
