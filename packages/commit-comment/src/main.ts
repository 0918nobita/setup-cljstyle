import * as core from '@actions/core';
import * as github from '@actions/github';
import parse from 'parse-diff';

export const createCommitComment = async () => {
    const myToken = core.getInput('token');
    const octokit = github.getOctokit(myToken);

    const input = `--- a/example/main.clj
+++ b/example/main.clj
@@ -1,2 +1,2 @@
 (println "Hello, world!")
-  (println "Clojure")
+(println "Clojure")
`;

    const body = parse(input).reduce((accRes, { chunks, from, to }) => {
        const h2 = from === to ? `\`${from}\`` : `\`${from}\` → \`${to}\``;
        const text = chunks.reduce((accChunk, { changes }) => {
            const codeBlock = changes.reduce(
                (acc, { content }) => `${acc}${content}\n`,
                ''
            );
            return `${accChunk}\`\`\`diff\n${codeBlock}\`\`\``;
        }, '');
        return `${accRes}## ${h2}\n\n${text}\n\n`;
    }, '');

    try {
        const {
            data: { html_url: htmlUrl },
        } = await octokit.rest.repos.createCommitComment({
            owner: github.context.repo.owner,
            repo: github.context.repo.repo,
            commit_sha: github.context.sha,
            body: `# Cljstyle Report\n\n${body}`,
        });
        console.log('Commit comment created:', htmlUrl);
    } catch (e) {
        console.error(e);
    }
};
