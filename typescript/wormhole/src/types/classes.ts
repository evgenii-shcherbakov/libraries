import { Request } from 'express';
import { IWormhole } from './interfaces';
import { DynamicWormhole } from './dynamic';

export type WormholeClass<StorageType extends Object> = new (
  request: Request,
) => IWormhole<StorageType>;

export type DynamicWormholeClass<StorageType extends Object> = new (
  request: Request,
) => DynamicWormhole<StorageType>;
