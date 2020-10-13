import * as core from '@actions/core';
import * as tc from '@actions/tool-cache';
import * as os from 'os';
import * as process from 'process';

import { absolute, joinPath, relative } from './path';

const version = core.getInput('cljstyle-version');

const versionPattern = /^([1-9]\d*|0)\.([1-9]\d*|0)\.([1-9]\d*|0)$/;

if (!versionPattern.test(version)) {
    core.setFailed('The format of cljstyle-version is invalid.');
    process.exit(1);
}

const homeDir = absolute(os.homedir());
const binDir = joinPath(homeDir, relative('bin'));

const tarName = relative(`cljstyle_${version}_linux.tar.gz`);

const url = `http://github.com/greglook/cljstyle/releases/download/${version}/${tarName}`;

const error = (msg: string, err: Error) => {
    core.setFailed(msg);
    console.error(err);
    process.exit(1);
};

const addPath = (inputPath: string) => {
    core.info(`Add ${inputPath} into PATH`);
    core.addPath(inputPath);
};

(async () => {
    const cachePath = tc.find('cljstyle', version);
    if (cachePath !== '') {
        addPath(cachePath);
        return;
    }

    core.info(`Downloading ${url}`);
    const tarPath = await tc
        .downloadTool(url)
        .catch((err) => error('Failed to download tar file', err));

    core.info(`Extracting ${tarPath} into ${binDir}`);
    const extractedDir = await tc
        .extractTar(tarPath, joinPath(binDir, relative('cljstyle')))
        .catch((err) => error('Failed to extract tar file', err));

    core.info(`Caching ${extractedDir} directory`);
    await tc
        .cacheDir(extractedDir, 'cljstyle', version)
        .catch((err) =>
            error(`Failed to cache ${extractedDir} directory`, err)
        );

    addPath(extractedDir);
})();
