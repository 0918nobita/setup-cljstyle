import type { Branded } from '../utils/branded';
import { iso } from '../utils/iso';

declare const url: unique symbol;

export type Url = Branded<string, typeof url>;

export const urlIso = iso<typeof url>();
