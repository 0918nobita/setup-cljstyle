import type { Branded } from '../utils/branded';
import { iso } from '../utils/iso';

declare const version: unique symbol;

export type Version = Branded<string, typeof version>;

export const versionIso = iso<typeof version>();
