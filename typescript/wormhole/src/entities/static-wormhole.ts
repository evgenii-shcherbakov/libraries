import { StorableRequest, StorageTypeField } from '../types/utility';
import { Request } from 'express';
import { IWormhole } from '../types/interfaces';
import { CustomWormholeMapper, CustomWormholeSpreadMapper } from '../types/custom';

export class StaticWormhole<StorageType extends Object = {}> implements IWormhole<StorageType> {
  protected readonly storableRequest: StorableRequest<StorageType>;
  protected static defaultValue: object | undefined;

  constructor(request: Request) {
    this.storableRequest = request as StorableRequest<StorageType>;
  }

  get storage(): StorageType {
    if (this.storableRequest.storage) {
      return this.storableRequest.storage;
    }

    if (StaticWormhole.defaultValue) {
      return StaticWormhole.defaultValue as StorageType;
    }

    throw new Error('Default value for request storage not provided');
  }

  get<Field extends StorageTypeField<StorageType>>(field: Field): StorageType[Field] {
    return this.storage[field];
  }

  set(data: Partial<StorageType>) {
    this.storableRequest.storage = {
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
