import { Request } from 'express';

/**
 * @description utility types. Don't change it
 */

export type StorableRequest<StorageType extends Object> = Request & {
  storage?: StorageType;
};

type ObjectDefaultFields =
  | 'constructor'
  | 'toString'
  | 'toLocaleString'
  | 'valueOf'
  | 'hasOwnProperty';

export type StorageTypeField<StorageType extends Object> = Exclude<
  keyof StorageType & string,
  ObjectDefaultFields
>;

export type OptionalFields<StorageType extends Object> = {
  [Field in keyof StorageType]-?: {} extends Pick<StorageType, Field> ? Field : never;
}[keyof StorageType];

export type StorageTypeNonNullableField<StorageType extends Object> = Exclude<
  Exclude<keyof StorageType & string, OptionalFields<StorageType>>,
  ObjectDefaultFields
>;
