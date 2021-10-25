import { mkdirP, mv } from '@actions/io';

export = {
  _mkdirP: mkdirP,
  _mv: (source: string) => (dest: string) => mv(source, dest),
};
