import fetch from 'node-fetch';

const _fetchLatestRelease = (owner: string) => async (repo: string) => {
  const res = await fetch(`https://api.github.com/repos/${owner}/${repo}/releases/latest`);
  return await res.text();
};

export = { _fetchLatestRelease };
