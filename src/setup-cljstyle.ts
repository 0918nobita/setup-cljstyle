import * as core from '@actions/core';
import * as tc from '@actions/tool-cache';
import * as os from 'os';
import { absolute, relative, joinPath } from './path';

const version = core.getInput('cljstyle-version');

const homeDir = absolute(os.homedir());
const binDir = joinPath(homeDir, relative('bin'));

const tarName = relative(`cljstyle_${version}_linux.tar.gz`);

const url = `http://github.com/greglook/cljstyle/releases/download/${version}/${tarName}`;

(async () => {
    const tarPath = await tc.downloadTool(url);
    await tc.extractTar(tarPath, binDir);
    core.addPath(binDir);
})();
