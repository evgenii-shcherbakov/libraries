import { IWormhole } from './interfaces';
import { StorageTypeNonNullableField } from './utility';

export type DynamicGetters<StorageType extends Object> = {
  [Getter in StorageTypeNonNullableField<StorageType> as `get${Capitalize<Getter>}`]: () => StorageType[Getter];
};

export type DynamicSetters<StorageType extends Object> = {
  [Setter in StorageTypeNonNullableField<StorageType> as `set${Capitalize<Setter>}`]: (
    value: StorageType[Setter],
  ) => void;
};

export type DynamicWormhole<StorageType extends Object> = IWormhole<StorageType> &
  DynamicGetters<StorageType> &
  DynamicSetters<StorageType>;
