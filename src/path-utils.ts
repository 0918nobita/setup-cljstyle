import * as path from 'path';

import { Branded, WithoutBrand } from './branded-types';

export type Path<T extends 'absolute' | 'relative'> = Branded<string, T>;

export const absolute = <T extends string>(
    path: WithoutBrand<T>
): Path<'absolute'> => (path as unknown) as Path<'absolute'>;

export const relative = <T extends string>(
    path: WithoutBrand<T>
): Path<'relative'> => (path as unknown) as Path<'relative'>;

export const joinPath = (
    base: Path<'absolute'>,
    relativePath: Path<'relative'>
): Path<'absolute'> => path.join(base, relativePath) as Path<'absolute'>;
