export type CustomWormholeMapper<Data = any, StorageType extends Object = {}> = (
  storage: StorageType,
  data: Data,
) => StorageType | Partial<StorageType>;

export type CustomWormholeSpreadMapper<Data = any, StorageType extends Object = {}> = (
  storage: StorageType,
  ...data: Data[]
) => StorageType | Partial<StorageType>;
