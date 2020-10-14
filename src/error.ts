import * as core from '@actions/core';

export const error = (msg: string, err?: Error): never => {
    core.setFailed(msg);
    if (err) console.error(err);
    process.exit(1);
};
