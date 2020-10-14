import * as core from '@actions/core';

export const addPath = (inputPath: string): void => {
    core.info(`Add ${inputPath} to PATH`);
    core.addPath(inputPath);
};
