import { Wormhole } from './interfaces';
import { DynamicWormhole } from './dynamic';
import { StorageProvider } from './utility';

export type WormholeFactory<StorageType extends object> = (
  provider: StorageProvider<StorageType>,
) => Wormhole<StorageType>;

export type DynamicWormholeFactory<StorageType extends object> = (
  provider: StorageProvider<StorageType>,
) => DynamicWormhole<StorageType>;
