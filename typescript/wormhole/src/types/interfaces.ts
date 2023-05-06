import { CustomWormholeMapper, CustomWormholeSpreadMapper } from './custom';
import { StorageTypeField } from './utility';

export interface IWormhole<StorageType extends Object> {
  readonly storage: StorageType;

  get<Field extends StorageTypeField<StorageType>>(field: Field): StorageType[Field];
  set(data: Partial<StorageType>): void;

  createSetter<Data = any>(mapper: CustomWormholeMapper<Data, StorageType>): (data: Data) => void;
  createSpreadSetter<Data = any>(
    mapper: CustomWormholeSpreadMapper<Data, StorageType>,
  ): (...data: Data[]) => void;
}
