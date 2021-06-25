import { NativeModules } from 'react-native'

export default {
  data: () => NativeModules.ReactNativeShareExtension.data(),
  close: () => NativeModules.ReactNativeShareExtension.close(),
  closeWithDelay: (timeout) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        NativeModules.ReactNativeShareExtension.close();
        resolve();
      }, timeout || 200);
    })
  },
  openURL: (url) => NativeModules.ReactNativeShareExtension.openURL(url),
  getShareExtensionPosition: () => NativeModules.ReactNativeShareExtension.getShareExtensionPosition(),
}
