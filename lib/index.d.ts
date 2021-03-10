type ShareData = Array<string | undefined>;

type ShareExtensionPosition = {
  x: number;
  y: number;
  width: number;
  height: number;
}

interface ShareExtension {
  close(): void;
  data(): Promise<ShareData>;
  openURL(uri: string): void;
  getShareExtensionPosition(): Promise<ShareExtensionPosition | undefined>
}

declare const RNShareExtension: ShareExtension;
export default RNShareExtension;
