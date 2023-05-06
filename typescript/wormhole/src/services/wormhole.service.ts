import { DynamicWormholeClass } from '../types/classes';
import { createDynamicWormhole } from '../functions';
import { Request } from 'express';
import { DynamicWormhole } from '../types/dynamic';

export class WormholeService {
  private static wormholeClass: DynamicWormholeClass<any> | undefined;

  static create<StorageType extends Object>(
    defaultValue: StorageType,
  ): DynamicWormholeClass<StorageType> {
    if (this.wormholeClass) {
      throw new Error('Only one instance of wormhole class allowed per application');
    }

    const wormholeClass: DynamicWormholeClass<StorageType> = createDynamicWormhole(defaultValue);
    this.wormholeClass = wormholeClass;
    return wormholeClass;
  }

  static get class(): DynamicWormholeClass<any> {
    if (!this.wormholeClass) {
      throw new Error('Wormhole class instance is missing. Create one via method create first');
    }

    return this.wormholeClass;
  }

  static get initialized(): boolean {
    return !!this.wormholeClass;
  }

  static getInstance<StorageType extends Object>(request: Request): DynamicWormhole<StorageType> {
    return new this.class(request);
  }
}
