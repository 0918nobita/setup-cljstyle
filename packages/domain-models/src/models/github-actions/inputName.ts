import { Branded } from '../../utils/branded';
import { createIso } from '../../utils/iso';

declare const sym: unique symbol;

export type T = Branded<string, typeof sym>;

export const iso = createIso<typeof sym>();
