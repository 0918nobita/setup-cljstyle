import * as path from 'path';
import { Branded, WithoutBrand } from './branded-types';

type Path<T extends 'absolute' | 'relative'> = Branded<string, T>

export const absolute =
    <T extends string>(path: WithoutBrand<T>) => path as unknown as Path<'absolute'>;
export const relative =
    <T extends string>(path: WithoutBrand<T>) => path as unknown as Path<'relative'>;

export const joinPath = (base: Path<'absolute'>, relativePath: Path<'relative'>) =>
    path.join(base, relativePath) as Path<'absolute'>;
