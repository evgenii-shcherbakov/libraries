import { Wormhole } from './interfaces';
import { DynamicWormhole } from './dynamic';
import { StorageProvider } from './utility';

export type WormholeClass<StorageType extends object> = new (
  provider: StorageProvider<StorageType>,
) => Wormhole<StorageType>;

export type DynamicWormholeClass<StorageType extends object> = new (
  provider: StorageProvider<StorageType>,
) => DynamicWormhole<StorageType>;
