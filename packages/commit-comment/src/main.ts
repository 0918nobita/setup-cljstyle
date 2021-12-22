import * as github from '@actions/github';
import { gha } from '@setup-cljstyle/domain-models';

type Args = {
    githubActions: gha.GitHubActions;
    body: string;
};
export const createCommitComment = async ({ githubActions, body }: Args) => {
    const token = githubActions.getInput(gha.inputName.iso.wrap('token'));
    const octokit = github.getOctokit(token);

    try {
        const { owner, repo } = github.context.repo;
        const commit_sha = github.context.sha;
        const { data } = await octokit.rest.repos.createCommitComment({
            owner,
            repo,
            commit_sha,
            body,
        });

        console.log('Commit comment created:', data.html_url);
    } catch (e) {
        console.error(e);
    }
};
