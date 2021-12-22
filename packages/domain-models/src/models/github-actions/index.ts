export * as inputName from './inputName';
export * as inputValue from './inputValue';

import * as dirPath from '../dirPath';
import * as inputName from './inputName';
import * as inputValue from './inputValue';

export type GitHubActions = {
    addPath: (p: dirPath.T) => void;
    cacheDir: (p: dirPath.T) => void;
    getInput: (name: inputName.T) => inputValue.T;
};
