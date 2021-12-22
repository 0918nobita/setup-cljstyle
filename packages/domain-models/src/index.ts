export * from './models';

import { dirPath, version } from './models';

export type Installer = (arg: { version: version.T }) => Promise<dirPath.T>;

export type RawInputs = {
    cljstyleVersion: string;
    authToken: string;
    runCheck: string;
};

export type RawInputSource = () => Promise<RawInputs>;
