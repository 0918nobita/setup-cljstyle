import { addPath, getInput, InputOptions } from '@actions/core';

export = {
  addPath: (inputPath: string) => () => addPath(inputPath),
  getInput: (name: string) => (options: { value0: InputOptions }) => () => getInput(name, options.value0),
};
