import { DynamicWormholeClass } from '../types/classes';
import { createDynamicWormhole } from '../functions';

export class WormholeService {
  private static wormhole: DynamicWormholeClass<any> | undefined;

  static create<StorageType extends Object>(
    defaultValue: StorageType,
  ): DynamicWormholeClass<StorageType> {
    if (this.wormhole) {
      throw new Error('Only one instance of wormhole class allowed per application');
    }

    const wormhole: DynamicWormholeClass<StorageType> = createDynamicWormhole(defaultValue);
    this.wormhole = wormhole;
    return wormhole;
  }

  static get instance(): DynamicWormholeClass<any> {
    if (!this.wormhole) {
      throw new Error('Wormhole class instance is missing. Create one via method create first');
    }

    return this.wormhole;
  }

  static getTypedInstance<StorageType extends Object>(): DynamicWormholeClass<StorageType> {
    return this.instance;
  }
}
