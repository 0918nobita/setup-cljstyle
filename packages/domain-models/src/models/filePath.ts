import type { Branded } from '../utils/branded';
import { iso } from '../utils/iso';

declare const filePath: unique symbol;

export type FilePath = Branded<string, typeof filePath>;

export const filePathIso = iso<typeof filePath>();
