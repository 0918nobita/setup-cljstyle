"use strict";

const { downloadTool, find } = require('@actions/tool-cache');

exports._downloadTool = (url) => downloadTool(url);

exports.find = (toolName) => (versionSpec) => () => find(toolName, versionSpec);
