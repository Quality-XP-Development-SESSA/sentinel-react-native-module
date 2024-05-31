"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.helloKotlin = helloKotlin;
exports.multiply = multiply;
var _reactNative = require("react-native");
const {
  AuthModule,
  SentinelSDKModule
} = _reactNative.NativeModules;

// interface AuthenticationModule {
//   helloKotlin: () => Promise<string>;
// }

// export const authModule = AuthModule as AuthenticationModule;

function multiply(a, b) {
  return SentinelSDKModule.multiply(a, b);
}

// export function helloKotlinTest(): Promise<string> {
//   return SentinelSDKModule.helloKotlinTest();
// }

function helloKotlin() {
  return AuthModule.helloKotlin();
}
//# sourceMappingURL=index.js.map