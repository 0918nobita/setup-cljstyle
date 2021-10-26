import fetch from 'node-fetch';

const _fetchLatestRelease = (authToken: string) => (owner: string) => async (repo: string) => {
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
