import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'sentinelsdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const AuthModule = NativeModules.AuthModule
  ? NativeModules.AuthModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

//AUTH MODULE
export function signIn(userName: string, password: string): Promise<Boolean> {
  return AuthModule.signIn(userName, password);
}

export function recoverPassword(email: string): Promise<Boolean> {
  return AuthModule.recoverPassword(email);
}

export function signOut(): Promise<Boolean> {
  return AuthModule.signOut();
}

export function accountType():  Promise<string> {
  return AuthModule.accountType();
}
