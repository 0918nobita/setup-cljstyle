import { cacheDir, extractTar, downloadTool, find } from '@actions/tool-cache';

export = {
  _cacheDir: (sourceDir: string) => (tool: string) => (version: string) => cacheDir(sourceDir, tool, version),
  _extractTar: (file: string) => (dest: string) => extractTar(file, dest),
  _downloadTool: downloadTool,
  _find: (toolName: string) => (versionSpec: string) => () => find(toolName, versionSpec),
};
