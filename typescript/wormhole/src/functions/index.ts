import { Request } from 'express';
import { StaticWormhole } from '../entities/static-wormhole';
import { DynamicWormholeClass } from '../types/classes';
import { StorageTypeField } from '../types/utility';

const getStorageFields = <StorageType extends Object>(
  defaultValue: StorageType,
): StorageTypeField<StorageType>[] => {
  return Object.keys(defaultValue) as StorageTypeField<StorageType>[];
};

const dynamicGetterFactory = <
  StorageType extends Object,
  Field extends StorageTypeField<StorageType>,
>(
  field: Field,
) => {
  return function (): StorageType[Field] {
    return this.storage[field];
  };
};

const dynamicSetterFactory = <
  StorageType extends Object,
  Field extends StorageTypeField<StorageType>,
>(
  field: Field,
) => {
  return function (value: StorageType[Field]) {
    this.storableRequest.storage = {
      ...this.storage,
      [field]: value,
    };
  };
};

const storageFieldsHandlerFactory = <StorageType extends Object>(
  wormhole: StaticWormhole<StorageType>,
) => {
  return (field: StorageTypeField<StorageType>) => {
    const symbols: string[] = field.split('');

    const capitalizedFirstLetter: string = symbols[0].toUpperCase();
    const allLettersExceptFirst: string = symbols
      .filter((_: string, index: number) => index !== 0)
      .join('');

    const nameWithoutPrefix: string = capitalizedFirstLetter + allLettersExceptFirst;

    wormhole[`set${nameWithoutPrefix}`] = dynamicSetterFactory<
      StorageType,
      StorageTypeField<StorageType>
    >(field).bind(wormhole);

    wormhole[`get${nameWithoutPrefix}`] = dynamicGetterFactory<
      StorageType,
      StorageTypeField<StorageType>
    >(field).bind(wormhole);
  };
};

export const createDynamicWormhole = <StorageType extends Object>(
  defaultValue: StorageType,
): DynamicWormholeClass<StorageType> => {
  StaticWormhole['defaultValue'] = defaultValue;

  return class extends StaticWormhole<StorageType> {
    constructor(request: Request) {
      super(request);

      getStorageFields<StorageType>(defaultValue).forEach(
        storageFieldsHandlerFactory<StorageType>(this),
      );
    }
  } as unknown as DynamicWormholeClass<StorageType>;
};
