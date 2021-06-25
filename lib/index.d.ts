type ShareData = Array<string | undefined>;

export type ShareExtensionPosition = {
  x: number;
  y: number;
  width: number;
  height: number;
  safeAreaTop: number;
  safeAreaBottom: number;
}

interface ShareExtension {
  close(): void;
  closeWithDelay(timeout?: number): Promise<void>;
  data(): Promise<ShareData>;
  openURL(uri: string): void;
  getShareExtensionPosition(): Promise<ShareExtensionPosition | null>
}

declare const RNShareExtension: ShareExtension;
export default RNShareExtension;
