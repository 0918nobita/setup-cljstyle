// Testing on GitHub Actions

const core = require("@actions/core");
const github = require("@actions/github");
// const parse = require("parse-diff");

const myToken = core.getInput("token");
const octokit = github.getOctokit(myToken);

(async () => {
  try {
    const { data: commitComments } =
      await octokit.rest.repos.listCommentsForCommit({
        owner: "0918nobita",
        repo: "setup-cljstyle",
        commit_sha: "36a179b3abc8a6f8f74db423ea169845523cfed7",
      });
    console.log("commit comments:", commitComments);
  } catch (e) {
    console.error(e);
  }
})();

/*
let input = "";

process.stdin.on("data", (data) => {
  input += data;
});

process.stdin.on("end", () => {
  const results = parse(input);

  for (const { chunks, from, to } of results) {
    console.log(
      `## ${from === to ? `\`${from}\`` : `\`${from}\` → \`${to}\``}\n`
    );
    console.log("```diff");

    for (const { changes } of chunks)
      for (const { content } of changes) console.log(content);

    console.log("```");
  }

  process.exit(0);
});
*/
