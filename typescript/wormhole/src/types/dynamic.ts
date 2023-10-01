import { Wormhole } from './interfaces';
import { StorageTypeNonNullableField } from './utility';

type DynamicGetters<StorageType extends Object> = {
  [Getter in StorageTypeNonNullableField<StorageType> as `get${Capitalize<Getter>}`]: () => StorageType[Getter];
};

type DynamicSetters<StorageType extends Object> = {
  [Setter in StorageTypeNonNullableField<StorageType> as `set${Capitalize<Setter>}`]: (
    value: StorageType[Setter],
  ) => void;
};

export type DynamicWormhole<StorageType extends Object> = Wormhole<StorageType> &
  DynamicGetters<StorageType> &
  DynamicSetters<StorageType>;
