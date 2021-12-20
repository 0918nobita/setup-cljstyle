export * from './models/dirPath';
export * from './models/filePath';
export * from './models/url';
export * from './models/version';

import type { DirPath } from './models/dirPath';
import type { Version } from './models/version';

export type Installer = (arg: { version: Version }) => Promise<DirPath>;

export type RawInputs = {
    cljstyleVersion: string;
    authToken: string;
    runCheck: string;
};

export type RawInputSource = () => Promise<RawInputs>;
