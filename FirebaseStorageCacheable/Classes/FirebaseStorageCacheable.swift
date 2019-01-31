
import FirebaseStorage

public protocol FirebaseStorageCacheable {
    static var targetFileName: String { set get }
    static var remoteFileName: String { set get }
}

public enum FirebaseStorageCacheableError: Error {
    case invalidTargetUrl,
    invalidBundleUrl,
    bundleWriteFailed,
    
    invalidStorageReference,
    invalidTargetModificationDate,
    
    remoteMetaDataFailure,
    invalidRemoteModificationTimestamp,
    
    cacheWriteFailed
}

public extension FirebaseStorageCacheable {
    public static func copyBundledIfNeeded(onComplete: (() -> Void)? = nil, onError: ((_: FirebaseStorageCacheableError?) -> Void)? = nil) {
        if targetExists { return }
        
        guard let targetUrl = targetUrl else {
            onError?(.invalidTargetUrl)
            return
        }
        
        guard let sourceUrl = bundleSourceUrl else {
            onError?(.invalidBundleUrl)
            return
        }
        
        do {
            try fileManager.copyItem(atPath: sourceUrl.path, toPath: targetUrl.path)
            onComplete?()
        } catch {
            onError?(.bundleWriteFailed)
        }
    }
    
    public static func replaceIfAvailable(
        inProgress: ((_: Double?) -> Void)? = nil,
        onComplete: ((_: Bool) -> Void)? = nil,
        onError: ((_: FirebaseStorageCacheableError?) -> Void)? = nil) {
        
        guard let storageReference = storageReference else {
            onError?(.invalidStorageReference)
            return
        }
        
        guard let targetUrl = targetUrl else {
            onError?(.invalidTargetUrl)
            return
        }
        
        
        guard let targetModificationDate = targetModificationDate else {
            onError?(.invalidTargetModificationDate)
            return
        }
        
        storageReference.metadata { metadata, error in
            guard error == nil else {
                onError?(.remoteMetaDataFailure)
                return
            }
            
            
            guard let remoteUpdateDate = metadata?.updated else {
                onError?(.invalidRemoteModificationTimestamp)
                return
            }
            
            if remoteUpdateDate < targetModificationDate {
                onComplete?(false)
                return
            }
            
            inProgress?(nil)
            
            let downloadTask = storageReference.write(toFile: targetUrl) { url, error in
                
                guard error == nil else {
                    onError?(.cacheWriteFailed)
                    return
                }
                
                onComplete?(true)
            }
            
            let _ = downloadTask.observe(.progress) { snapshot in
                inProgress?(snapshot.progress?.fractionCompleted)
            }
        }
    }
    
    private static var storage: FIRStorage {
        return FIRStorage.storage()
    }
    
    private static var targetUrl: URL? {
        guard let firstDocumentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return firstDocumentsUrl.appendingPathComponent(targetFileName)
    }
    
    private static var storageReference: FIRStorageReference? {
        return storage.reference(forURL: remoteFileName)
    }
    
    private static var fileManager: FileManager {
        return FileManager.default
    }
    
    private static var bundleSourceUrl: URL? {
        return Bundle.main.resourceURL?.appendingPathComponent(targetFileName)
    }
    
    private static var targetExists: Bool {
        guard let targetUrl = targetUrl else { return false }
        return (try? targetUrl.checkResourceIsReachable()) ?? false
    }
    
    private static var targetModificationDate: Date? {
        guard let targetUrl = targetUrl else { return nil }
        
        do {
            let attr = try fileManager.attributesOfItem(atPath: targetUrl.path)
            return attr[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
}
