import { createCommitComment } from '@setup-cljstyle/commit-comment';
import { versionIso } from '@setup-cljstyle/domain-models';
import { platform } from 'process';

import { getInstaller } from './installer';

void (async () => {
    await getInstaller(platform)({
        version: versionIso.wrap('0.15.0'),
    });
    await createCommitComment();
    console.log('Complete!');
})();
