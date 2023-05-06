import { CustomWormholeMapper, CustomWormholeSpreadMapper } from './custom';

export interface IWormhole<StorageType extends Object> {
  readonly storage: StorageType;

  get<Value extends keyof StorageType>(field: Value): StorageType[Value];
  set(data: Partial<StorageType>): void;

  createSetter<Data = any>(mapper: CustomWormholeMapper<Data, StorageType>): (data: Data) => void;
  createSpreadSetter<Data = any>(
    mapper: CustomWormholeSpreadMapper<Data, StorageType>,
  ): (...data: Data[]) => void;
}
