"use strict";

const { addPath, getInput } = require('@actions/core')

exports.addPath = (inputPath) => () => addPath(inputPath);

exports.getInput = (name) => (options) => () => getInput(name, options.value0);
