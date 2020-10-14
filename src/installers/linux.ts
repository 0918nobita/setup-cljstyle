import * as core from '@actions/core';
import * as tc from '@actions/tool-cache';
import * as os from 'os';

import { addPath } from '../add-path';
import { error } from '../error';
import { absolute, joinPath, relative } from '../path-utils';

interface Args {
    version: string;
}

export const setupOnLinux = async ({ version }: Args): Promise<void> => {
    const homeDir = absolute(os.homedir());
    const binDir = joinPath(homeDir, relative('bin'));

    const tarName = relative(`cljstyle_${version}_linux.tar.gz`);
    const url = `http://github.com/greglook/cljstyle/releases/download/${version}/${tarName}`;

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
};
