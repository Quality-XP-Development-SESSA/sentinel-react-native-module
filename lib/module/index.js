import { NativeModules } from 'react-native';
const {
  AuthModule,
  SentinelSDKModule
} = NativeModules;

// interface AuthenticationModule {
//   helloKotlin: () => Promise<string>;
// }

// export const authModule = AuthModule as AuthenticationModule;

export function multiply(a, b) {
  return SentinelSDKModule.multiply(a, b);
}

// export function helloKotlinTest(): Promise<string> {
//   return SentinelSDKModule.helloKotlinTest();
// }

export function helloKotlin() {
  return AuthModule.helloKotlin();
}
//# sourceMappingURL=index.js.map