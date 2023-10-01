import { StaticWormholeEntity } from './static-wormhole.entity';
import { StorageTypeField } from '../types/utility';
import { DynamicWormholeClass } from '../types/classes';
import { DynamicWormhole } from '../types/dynamic';

export class DynamicWormholeEntity<
  StorageType extends object = object,
> extends StaticWormholeEntity<StorageType> {
  private getStorageFields(defaultValue: StorageType): StorageTypeField<StorageType>[] {
    return Object.keys(defaultValue) as StorageTypeField<StorageType>[];
  }

  private dynamicGetterFactory<Field extends StorageTypeField<StorageType>>(field: Field) {
    return (): StorageType[Field] => this.storage[field];
  }

  private dynamicSetterFactory<Field extends StorageTypeField<StorageType>>(field: Field) {
    return (value: StorageType[Field]) => {
      this.provider.storage = {
        ...this.storage,
        [field]: value,
      };
    };
  }

  private fieldMethodsFactory(field: StorageTypeField<StorageType>) {
    const symbols: string[] = field.split('');

    const capitalizedFirstLetter: string = symbols[0].toUpperCase();
    const allLettersExceptFirst: string = symbols
      .filter((_: string, index: number) => index !== 0)
      .join('');

    const nameWithoutPrefix: string = capitalizedFirstLetter + allLettersExceptFirst;

    this[`set${nameWithoutPrefix}`] =
      this.dynamicSetterFactory<StorageTypeField<StorageType>>(field).bind(this);

    this[`get${nameWithoutPrefix}`] =
      this.dynamicGetterFactory<StorageTypeField<StorageType>>(field).bind(this);
  }

  get instance(): DynamicWormhole<StorageType> {
    this.getStorageFields(this.defaultValue).forEach((field) => {
      this.fieldMethodsFactory(field);
    });

    return this as unknown as DynamicWormhole<StorageType>;
  }

  get class(): DynamicWormholeClass<StorageType> {
    return this as any;
  }
}
