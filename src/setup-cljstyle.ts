import * as core from '@actions/core';
import { exec } from 'child_process';
import * as fs from 'fs';
import fetch from 'node-fetch';
import { promisify } from 'util';

const version = core.getInput('cljstyle-version');

const tarFile = `cljstyle_${version}_linux.tar.gz`;

const url = `http://github.com/greglook/cljstyle/releases/download/${version}/${tarFile}`;

async function run() {
    const res = await fetch(url);
    const fileStream = fs.createWriteStream(tarFile);

    await new Promise((resolve, reject) => {
        res.body.pipe(fileStream);
        res.body.on('error', (err) => reject(err));
        fileStream.on('finish', () => resolve());
    });

    const execCmd = promisify(exec);
    await execCmd(`tar -xzf ${tarFile}`);
    fs.unlinkSync(tarFile);
    core.addPath('./');
}

run();
