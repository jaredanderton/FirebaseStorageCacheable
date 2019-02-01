# FirebaseStorageCacheable

[![CI Status](https://img.shields.io/travis/jaredanderton/FirebaseStorageCacheable.svg?style=flat)](https://travis-ci.org/jaredanderton/FirebaseStorageCacheable)
[![Version](https://img.shields.io/cocoapods/v/FirebaseStorageCacheable.svg?style=flat)](https://cocoapods.org/pods/FirebaseStorageCacheable)
[![License](https://img.shields.io/cocoapods/l/FirebaseStorageCacheable.svg?style=flat)](https://cocoapods.org/pods/FirebaseStorageCacheable)
[![Platform](https://img.shields.io/cocoapods/p/FirebaseStorageCacheable.svg?style=flat)](https://cocoapods.org/pods/FirebaseStorageCacheable)

## Overview
FirebaseStorageCacheable is a libary to that downloads and caches the latest version of a file FirebaseStorage.

This library allows you download and cache files hosted in Firebase storage.

All you need to do is provide the file name to store the file as locally, along with the remote file name, and the library will handle the rest.

It uses timestamps of your local file, compared to the timestamp of the remote file (without downloading the remote file to check), to determine if the remote file is newer.

The replaceIfAvailable, replaces the local file with a copy of the remote one. The API includes onComplete and onError closures as parameters to keep your code loosely coupled.

When replacing a file, you may also provide an onProgress closure to can inform your app of download progress.

It also supports replacing a bundled file, as well.

This does require that you use FirebaseStorage.

## Requirements
This pod has been written to work with [Firebase Storage](https://firebase.google.com/docs/storage/ios/start). 

Currently, version is 3.1 (at time of writing)
```ruby
pod 'Firebase/Storage', '~> 3.1'
```


## Installation

FirebaseStorageCacheable is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FirebaseStorageCacheable'
```

## Usage

### Import the library
```swift
import FirebaseStorageCacheable
```

#### Conform to the FirebaseStorageCacheable protocol
```swift
class MyCacheableFile: FirebaseStorageCacheable {
    static var remotePath: String = "gs://remote/path/to/your/file.json"
    static var targetPath: String = "/local/path/relative/to/your/apps/Documents/cached.json"
    
    // optional parameter, used to locate a bundled copy, that can be copied to the targetPath
    static var bundledFileName: String = "bundled.json"
}
```

#### Determine if the target file has been cached locally (either copy from the bundle or downloaded)
```swift
if MyCacheableFile.targetFileExists {
    // target file exists
} else {
    // target file does not exist
}
```

#### If you bundle a copy of the file with your app, copy it to the target location - if provided 
```swift
MyCacheableFile.writeFromBundle(onComplete: {
    // copy from bundle to app documents directory succeeded
},onError: { (error: FirebaseStorageCacheableError?) in
    // handle error
})
```

#### Get the date of the last time the remote file was modified
```swift
MyCacheableFile.getRemoteModified(onComplete: { date in
    // now you know when the remote file was updated last
}, onError: { error in
    // handle error
})
```

#### Get the date of the last time the target file (local file) was modified
```swift
let date = MyCacheableFile.targetModified
```

#### Check to see if there is an updated version
This method compares the value from `MyCacheableFile.getRemoteModified` and `MyCacheableFile.targetModified` to determine whether or not an update is available
```swift
MyCacheableFile.checkForUpdate(onComplete: { (status: FirebaseStorageCacheableStatus) in
    switch status {
    case .updateAvailable:
        // now would be a great time to trigger the MyCacheableFile.update method here
    case .upToDate:
        // you could display to the user they have up to date information
    }
}, onError: { (error: FirebaseStorageCacheableError?) in
    // handle error
})
```

#### Update the target file with the most recent version of the remote file
```swift
MyCacheableFile.update(onComplete: {
    // the most recent version of the remote file has been downloaded and cached
}, onError: { (error: FirebaseStorageCacheableError?) in
    // handle error
}, inProgress: { (fractionComplete: Double) in
    // Update UI with download progress (this closure param optional)
})
```

#### Open the file and do your thing 
```swift
if let filePath = MyCacheableFile.targetUrl, let contents = try? Data(contentsOf: filePath) {
    // do your thing
} else {
    // loading failed
}
```

## License

FirebaseStorageCacheable is available under the MIT license. See the LICENSE file for more info.
