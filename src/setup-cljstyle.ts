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

(async () => {
    const cachePath = tc.find('cljstyle', version);
    if (cachePath !== '') return;

    core.info(`Downloading ${url}`);
    const tarPath = await tc.downloadTool(url).catch((err) => {
        core.setFailed('Failed to download tar file');
        console.error(err);
        process.exit(1);
    });

    core.info(`Extracting ${tarPath} into ${binDir}`);
    const extractedDir = await tc
        .extractTar(tarPath, joinPath(binDir, relative('cljstyle')))
        .catch((err) => {
            core.setFailed('Failed to download tar file');
            console.error(err);
            process.exit(1);
        });

    core.info(`Caching ${extractedDir} directory`);
    await tc.cacheDir(extractedDir, 'cljstyle', version).catch((err) => {
        core.setFailed(`Failed to cache ${extractedDir} directory`);
        console.error(err);
        process.exit(1);
    });

    core.info(`Add ${extractedDir} to PATH`);
    core.addPath(extractedDir);
})();
