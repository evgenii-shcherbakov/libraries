import { StorageProvider } from '../types/utility';
import { DynamicWormholeEntity } from '../entities/dynamic-wormhole.entity';
import { StaticWormholeEntity } from '../entities/static-wormhole.entity';
import { DynamicWormholeFactory, WormholeFactory } from '../types/factories';

export class WormholeBuilder<StorageType extends object = object> {
  constructor(private readonly defaultValue: StorageType) {}

  get static(): WormholeFactory<StorageType> {
    return (provider: StorageProvider<StorageType>) => {
      return new StaticWormholeEntity(provider, this.defaultValue);
    };
  }

  get dynamic(): DynamicWormholeFactory<StorageType> {
    return (provider: StorageProvider<StorageType>) => {
      return new DynamicWormholeEntity(provider, this.defaultValue).instance;
    };
  }
}
