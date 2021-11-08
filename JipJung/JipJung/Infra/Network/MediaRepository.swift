//
//  RemoteServiceRepository.swift
//  JipJung
//
//  Created by turu on 2021/11/08.
//

import Foundation

import RxSwift

enum MediaRepositoryError: Error {
    case notsuchFile
    case failedFileCopy
}

final class MediaRepository {
    private let remoteServiceProvider: RemoteServiceAccessible
    
    init(remoteServiceAccessible: RemoteServiceAccessible) {
        self.remoteServiceProvider = remoteServiceAccessible
    }
    
    func fetch(fileName: String, type: Media) -> Single<Data> {
        if let data = LocalFileManager.shared.read(fileName) {
            return Single.just(data)
        }
        
        return remoteServiceProvider.request(key: fileName, type: type)
            .map { url in LocalFileManager.shared.write(from: url, fileName: fileName) }
            .map { isSucceed in
                switch isSucceed {
                case true:
                    guard let data = LocalFileManager.shared.read(fileName) else {
                        throw MediaRepositoryError.notsuchFile
                    }
                    return data
                case false:
                    throw MediaRepositoryError.failedFileCopy
                }
            }
    }
}
