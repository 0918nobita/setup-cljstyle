import * as path from 'path';

export type Path<T extends 'absolute' | 'relative'> = string & { _brand: T };

export const absolute = (path: string) => path as Path<'absolute'>;
export const relative = (path: string) => path as Path<'relative'>;

export const joinPath = (base: Path<'absolute'>, relativePath: Path<'relative'>) =>
    path.join(base, relativePath) as Path<'absolute'>;
