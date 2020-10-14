import * as core from '@actions/core';
import * as tc from '@actions/tool-cache';
import * as process from 'process';

import { addPath } from './add-path';
import { error } from './error';
import { setupOnLinux, setupOnMacOS, setupOnWindows } from './installers';

const version = core.getInput('cljstyle-version');

const versionPattern = /^([1-9]\d*|0)\.([1-9]\d*|0)\.([1-9]\d*|0)$/;

if (!versionPattern.test(version))
    error('The format of cljstyle-version is invalid.');

const cachePath = tc.find('cljstyle', version);
if (cachePath !== '') {
    addPath(cachePath);
    process.exit(0);
}

switch (process.platform) {
    case 'win32':
        setupOnWindows();
        break;
    case 'darwin':
        setupOnMacOS({ version });
        break;
    default:
        setupOnLinux({ version });
}
