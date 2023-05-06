import { Request } from 'express';

/**
 * @description utility types. Don't change it
 */

export type StorableRequest<StorageType extends Object> = Request & {
  storage?: StorageType;
};

export type StorageTypeField<StorageType extends Object> = keyof StorageType & string;
