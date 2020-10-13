export type Branded<K, T> = K & { __brand: T };

export type WithoutBrand<T> = T extends { __brand: unknown } ? never : T;
