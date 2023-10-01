import { StorageProvider, StorageTypeField } from '../types/utility';
import { Wormhole } from '../types/interfaces';
import { CustomWormholeMapper, CustomWormholeSpreadMapper } from '../types/custom';

export class StaticWormholeEntity<StorageType extends object = object>
  implements Wormhole<StorageType>
{
  constructor(
    protected readonly provider: StorageProvider<StorageType>,
    protected readonly defaultValue: StorageType = {} as StorageType,
  ) {}

  protected get storage(): StorageType {
    if (this.provider.storage) {
      return this.provider.storage;
    }

    return this.defaultValue;
  }

  get<Field extends StorageTypeField<StorageType>>(field: Field): StorageType[Field] {
    return this.storage[field];
  }

  set(data: Partial<StorageType>) {
    this.provider.storage = {
      ...this.storage,
      ...data,
    };
  }

  createSetter<Data = any>(mapper: CustomWormholeMapper<Data, StorageType>): (data: Data) => void {
    return (data: Data) => this.set(mapper(this.storage, data));
  }

  createSpreadSetter<Data = any>(
    mapper: CustomWormholeSpreadMapper<Data, StorageType>,
  ): (...data: Data[]) => void {
    return (...data: Data[]) => this.set(mapper(this.storage, ...data));
  }
}
