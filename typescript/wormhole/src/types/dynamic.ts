import { IWormhole } from './interfaces';

export type DynamicGetters<StorageType extends Object> = {
  [Getter in keyof StorageType as `get${Capitalize<string & Getter>}`]: () => StorageType[Getter];
};

export type DynamicSetters<StorageType extends Object> = {
  [Setter in keyof StorageType as `set${Capitalize<string & Setter>}`]: (
    value: StorageType[Setter],
  ) => void;
};

export type DynamicWormhole<StorageType extends Object> = IWormhole<StorageType> &
  DynamicGetters<StorageType> &
  DynamicSetters<StorageType>;
