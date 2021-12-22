import * as core from '@actions/core';
import { createCommitComment } from '@setup-cljstyle/commit-comment';
import {
    GitHubActions,
    wrapInputValue,
    wrapVersion,
} from '@setup-cljstyle/domain-models';
import parse from 'parse-diff';
import { platform } from 'process';

import { getInstaller } from './installer';

const input = `--- a/example/main.clj
+++ b/example/main.clj
@@ -1,2 +1,2 @@
 (println "Hello, world!")
-  (println "Clojure")
+(println "Clojure")
`;

const body = parse(input).reduce((accRes, { chunks, from, to }) => {
    if (!from || !to) return accRes;

    const h2 = from === to ? `\`${from}\`` : `\`${from}\` → \`${to}\``;

    const text = chunks.reduce((accChunk, { changes }) => {
        const codeBlock = changes.reduce(
            (acc, { content }) => `${acc}${content}\n`,
            ''
        );
        return `${accChunk}\`\`\`diff\n${codeBlock}\`\`\``;
    }, '');

    return `${accRes}## ${h2}\n\n${text}\n\n`;
}, '# Cljstyle Report\n\n');

void (async () => {
    const githubActions: GitHubActions = {
        /* eslint-disable @typescript-eslint/no-unused-vars, @typescript-eslint/no-empty-function */
        addPath: (_) => {},
        cacheDir: (_) => {},
        /* eslint-enable @typescript-eslint/no-unused-vars, @typescript-eslint/no-empty-function */
        getInput: (name) => wrapInputValue(core.getInput(name)),
    };

    await getInstaller(platform)({
        version: wrapVersion('0.15.0'),
    });

    await createCommitComment({ githubActions, body });

    console.log('Complete!');
})();
