export * from '../generated';

import type { DirPath, InputName, InputValue, Version } from '../generated';

export type Installer = (arg: { version: Version }) => Promise<DirPath>;

export type RawInputs = {
    cljstyleVersion: string;
    authToken: string;
    runCheck: string;
};

export type RawInputSource = () => Promise<RawInputs>;

export type GitHubActions = {
    addPath: (p: DirPath) => void;
    cacheDir: (p: DirPath) => void;
    getInput: (name: InputName) => InputValue;
};
