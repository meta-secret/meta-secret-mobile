<h1 align="center">Meta Secret Mobile Application</h1>

#### vault-server api
  http://api.meta-secret.org


### STEPS TO BUILD

1. Download Meta-Secret-Core project from [here](https://github.com/meta-secret/meta-secret-core)
2. Download Meta-Secret-Mobile project from [here](https://github.com/meta-secret/meta-secret-mobile)
3. Move to the folder where you downloaded Meta-Secret-Core project
4. In terminal do this commands:
  - `cargo clean`
  - `cargo lipo --release`
  - `cp target/universal/release/libmeta_secret_core_mobile.a ..(#choose your destiny)/metasecret-mobile/MetaSecret/RustLib `
5. Go to the folder where you downloaded Meta-Secret-Mobile project
6. In terminal do `pod install` command
7. Open `MetaSecret.xcworkspace` in XCode
8. Add file `libmeta_secret_core_mobile.a` to the RustLib folder (just drag-n-drop it)
9. Select MetaSecret project file in xcode
10. In oppened window select `TARGETS: MetaSecret`
11. Switch to `BuildPhases`
12. In `Link Binary With Libraries` press `+` sign and select added `libmeta_secret_core_mobile.a` if it wasn't added automaticaly
13. Build a project (Cmd+B)


***IMPORTANT!!!***
DO NOT COMMIT THIS LIB!
