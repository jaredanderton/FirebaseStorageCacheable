
import FirebaseStorage

@objc public protocol FirebaseStorageCacheable {
    static var targetPath: String { set get }
    static var remotePath: String { set get }
    @objc optional static var bundledFileName: String { set get }
}

public enum FirebaseStorageCacheableStatus {
    case upToDate, updateAvailable
}

public enum FirebaseStorageCacheableError: Error {
    case unresolveableTargetUrl,
    unresolveableBundledUrl,
    bundledFileNameMissing,
    bundledFileNotFound,
    copyBundledToTargetFailed,
    unresolveableStorageReference,
    missingRemoteModified,
    remoteFileError,
    writeUpdateToTargetFailed
}

public extension FirebaseStorageCacheable {
    public static func writeFromBundle(
        onComplete: @escaping (() -> Void),
        onError: @escaping ((_: FirebaseStorageCacheableError?) -> Void)) {
        
        guard bundledFileName != nil else {
            onError(.bundledFileNameMissing)
            return
        }
        
        guard let targetUrl = targetUrl else {
            onError(.unresolveableTargetUrl)
            return
        }
        
        guard let sourceUrl = bundleSourceUrl else {
            onError(.unresolveableBundledUrl)
            return
        }
        
        do {
            let subDir = targetUrl.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true, attributes: [:])
            try FileManager.default.copyItem(atPath: sourceUrl.path, toPath: targetUrl.path)
            onComplete()
        } catch {
            onError(.copyBundledToTargetFailed)
        }
    }
    
    public static func getRemoteModified(
        onComplete: @escaping ((_: Date) -> Void),
        onError: @escaping ((_: FirebaseStorageCacheableError?) -> Void)) {
        
        guard let storageReference = storageReference else {
            onError(.unresolveableStorageReference)
            return
        }
        
        storageReference.metadata { metadata, error in
            guard error == nil else {
                onError(.remoteFileError)
                return
            }
            
            guard let remoteModified = metadata?.updated else {
                onError(.missingRemoteModified)
                return
            }
            
            onComplete(remoteModified)
        }
    }
    
    public static func checkForUpdate(
        onComplete: @escaping ((_: FirebaseStorageCacheableStatus) -> Void),
        onError: @escaping ((_: FirebaseStorageCacheableError?) -> Void)) {
        
        getRemoteModified(onComplete: { remoteModified in
            
            guard let targetModified = targetModified else {
                onComplete(.updateAvailable)
                return
            }
            
            let status: FirebaseStorageCacheableStatus = remoteModified < targetModified ? .upToDate : .updateAvailable
            onComplete(status)
        }, onError: { error in
            onError(error)
        })
    }
    
    public static func update(
        onComplete: @escaping ((_: Bool) -> Void),
        onError: @escaping ((_: FirebaseStorageCacheableError?) -> Void),
        inProgress: ((_: Double?) -> Void)? = nil) {
        
        guard let storageReference = storageReference else {
            onError(.unresolveableStorageReference)
            return
        }
        
        guard let targetUrl = targetUrl else {
            onError(.unresolveableTargetUrl)
            return
        }
        
        inProgress?(nil)
        let downloadTask = storageReference.write(toFile: targetUrl) { url, error in
            guard error == nil else {
                onError(.writeUpdateToTargetFailed)
                return
            }
            onComplete(true)
        }
        let _ = downloadTask.observe(.progress) { snapshot in
            inProgress?(snapshot.progress?.fractionCompleted)
        }
    }
    
    public static var targetFileExists: Bool {
        guard let targetUrl = targetUrl else { return false }
        return (try? targetUrl.checkResourceIsReachable()) ?? false
    }
    
    public static var targetUrl: URL? {
        guard let firstDocumentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return firstDocumentsUrl.appendingPathComponent(targetPath)
    }
    
    public static var targetModified: Date? {
        guard let targetUrl = targetUrl else { return nil }
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: targetUrl.path)
            return attr[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
    
    private static var storageReference: FIRStorageReference? {
        return FIRStorage.storage().reference(forURL: remotePath)
    }
    
    private static var bundleSourceUrl: URL? {
        guard let bundledFileName = bundledFileName else { return nil }
        return Bundle.main.resourceURL?.appendingPathComponent(bundledFileName)
    }
}
