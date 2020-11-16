type ShareData = Array<string | undefined>;

interface ShareExtension {
  close(): void;
  data(): Promise<ShareData>;
  openURL(uri: string): void;
}

declare const RNShareExtension: ShareExtension;
export default RNShareExtension;
