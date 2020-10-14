import * as core from '@actions/core';
import * as io from '@actions/io';
import * as tc from '@actions/tool-cache';
import * as fs from 'fs';

import { addPath } from '../add-path';
import { error } from '../error';
import { absolute, joinPath, relative } from '../path-utils';

interface Args {
    version: string;
}

export const setupOnWindows = async ({ version }: Args): Promise<void> => {
    const binDir = absolute('D:\\cljstyle');

    io.mkdirP(binDir);

    const jarFile = `cljstyle-${version}.jar`;
    const url = `https://github.com/greglook/cljstyle/releases/download/${version}/${jarFile}`;

    core.info(`Downloading ${url}`);
    const toolPath = await tc
        .downloadTool(url)
        .catch((err) => error('Failed to download tar file', err));

    const dest = joinPath(binDir, relative(`cljstyle-${version}.jar`));
    core.info(`Move ${toolPath} to ${dest}`);
    io.mv(toolPath, dest);

    core.info(`Caching ${binDir} directory`);
    await tc
        .cacheDir(binDir, 'cljstyle', version)
        .catch((err) => error(`Failed to cache ${binDir} directory`, err));

    fs.writeFileSync(
        joinPath(binDir, relative('cljstyle.bat')),
        `java -jar %~dp0cljstyle-${version}.jar %*`
    );

    addPath(binDir);
};
