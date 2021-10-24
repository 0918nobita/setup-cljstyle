"use strict";

const { extractTar, downloadTool, find } = require('@actions/tool-cache');

exports._extractTar = (file) => (dest) => extractTar(file, dest);

exports._downloadTool = (url) => downloadTool(url);

exports.find = (toolName) => (versionSpec) => () => find(toolName, versionSpec);
