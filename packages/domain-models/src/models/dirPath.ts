import type { Branded } from '../utils/branded';
import { iso } from '../utils/iso';

declare const dirPath: unique symbol;

export type DirPath = Branded<string, typeof dirPath>;

export const dirPathIso = iso<typeof dirPath>();
