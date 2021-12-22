import type { Branded } from './branded';

type Iso<T> = {
    wrap: <V>(v: V) => Branded<V, T>;
    unwrap: <V>(b: Branded<V, T>) => V;
};

export const createIso = <T>(): Iso<T> => ({
    wrap: <V>(v: V) => v as Branded<V, T>,
    unwrap: <V>(b: Branded<V, T>) => b,
});
