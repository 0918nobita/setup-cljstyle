"use strict";

const { cacheDir, extractTar, downloadTool, find } = require('@actions/tool-cache');

exports._cacheDir = (sourceDir) => (tool) => (version) => cacheDir(sourceDir, tool, version);

exports._extractTar = (file) => (dest) => extractTar(file, dest);

exports._downloadTool = (url) => downloadTool(url);

exports._find = (toolName) => (versionSpec) => () => find(toolName, versionSpec);
