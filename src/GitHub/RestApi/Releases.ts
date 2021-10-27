import fetch from 'node-fetch';

type FetchLatestReleaseArgs = {
  authToken: string;
  owner: string;
  repo: string;
};

const _fetchLatestRelease = async ({ authToken, owner, repo }: FetchLatestReleaseArgs) => {
  const res = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/releases/latest`,
    {
      headers: {
        'Authorization': `Bearer ${authToken}`,
      }
    }
  );
  return await res.text();
};

export = { _fetchLatestRelease };
