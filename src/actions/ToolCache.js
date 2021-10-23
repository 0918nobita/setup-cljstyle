"use strict";

const { find } = require('@actions/tool-cache');

exports.find = (toolName) => (versionSpec) => () => find(toolName, versionSpec);
