<h1 align="center">Meta Secret Mobile Application</h1>

#### vault-server api
  http://api.meta-secret.org


### STEPS TO BUILD

You'll need installed Android Studio & XCode

1. Download Meta-Secret-Core project from [here](https://github.com/meta-secret/meta-secret-core)
2. Download Meta-Secret-Mobile project from [here](https://github.com/meta-secret/meta-secret-mobile)
3. Move to the folder where you downloaded Meta-Secret-Core project

#### FOR IOS
1. Run `sh iosBuild.sh`
2. Go to the folder where you downloaded Meta-Secret-Mobile project
3. In terminal do `pod install` command
4. Open `MetaSecret.xcworkspace` in XCode
5. 4. Open `MetaSecretCore.xcframework` from `Meta-Secret-Core/target` to the RustLib folder (just drag-n-drop it)
6. Select MetaSecret project file in xcode
7. In oppened window select `TARGETS: MetaSecret`
8. Switch to `BuildPhases`
9. In `Link Binary With Libraries` press `+` sign and select added `MetaSecretCore` if it wasn't added automaticaly
10. Build a project (Cmd+B)
