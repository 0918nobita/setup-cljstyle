"use strict";

const { mkdirP, mv } = require('@actions/io');

exports._mkdirP = mkdirP;

exports._mv = (source) => (dest) => mv(source, dest);
