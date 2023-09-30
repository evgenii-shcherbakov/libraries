import { IRootInjector } from '../types/interfaces';
import { _RootInjector } from '../entities/root-injector';

export class _InjectionService {
  private static injector: IRootInjector | undefined;

  static getInjector(): IRootInjector {
    if (!this.injector) {
      throw new Error('Root injector is not initialized yet');
    }

    return this.injector;
  }

  static init() {
    this.injector = new _RootInjector();
  }

  static destroy() {
    this.injector = undefined;
  }
}
