# sentinel-react-native-module 
Plugin repository for React Native, using native modules for both iOS and Android.

# Requirements
- > Node >= 16
- > Sentinel SDK xcframework

# Project Setup
- > Add `s.vendored_frameworks = "ADD THE PATH OF SDK XCFRAMEWORK"` into podspect file
- > `npm install` to install all dependencies
- > `cd ios` to move to the IOS folder
- > Do `pod install` to setup Pods for IOS project
- > `npm pack` to create the *.tgz file, which ca be installled locally in  a React Native project

# Install local
- > Do `npm install with the path of *.tgz file`

# Publish Module
First, needs to create an account on NPM
After creating the account:
- > `npm login` to login into NPM account
- > `npm publish` to publish the plugin into NPM

