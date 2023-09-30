import 'reflect-metadata';
import { ClassType, Instance, InstanceFactory } from '../types/classes';
import { ModuleInjectionGraph, RootInjectionGraph } from '../types/common';
import { DEFAULT_MODULE_NAME } from '../constants/common';
import { MetadataKey } from '../constants/enums';
import { TargetMetadata } from '../types/metadata';
import { IRootInjector } from '../types/interfaces';

export class _RootInjector implements IRootInjector {
  private readonly graph: RootInjectionGraph = new Map();

  private getModuleGraph(name: string = DEFAULT_MODULE_NAME): ModuleInjectionGraph {
    if (!this.graph.has(name)) {
      this.graph.set(name, { instances: new Map(), factories: new Map() });
    }

    return this.graph.get(name)!;
  }

  registerInstance(type: Function, instance: Instance, module?: string) {
    this.getModuleGraph(module).instances.set(type, instance);
    console.debug(`[Koin] Registered singleton: ${type.name}`);
  }

  registerFactory(type: Function, factory: InstanceFactory, module?: string) {
    this.getModuleGraph(module).factories.set(type, factory);
    console.debug(`[Koin] Registered factory: ${type.name}`);
  }

  private resolveViaMetadata<Target>(target: ClassType<Target>, module?: string): Target {
    if (!Reflect.hasMetadata(MetadataKey.TARGET_DATA, target)) {
      throw new Error(`Instance of type ${target.name} is not registered yet`);
    }

    const metadata: TargetMetadata = Reflect.getMetadata(MetadataKey.TARGET_DATA, target);
    const paramTypes = Reflect.getMetadata('design:paramtypes', target) || [];
    const params = paramTypes.map((paramType: ClassType<Target>) => this.resolve(paramType));

    if (metadata.isSingleton) {
      const instance: Target = new target(...params);
      this.registerInstance(target, instance, module ?? metadata.module);
      return instance;
    }

    const factory: InstanceFactory<Target> = () => new target(...params);
    this.registerFactory(target, factory, module ?? metadata.module);
    return factory();
  }

  resolve<Target>(target: ClassType<Target>, module?: string): Target {
    const moduleGraph: ModuleInjectionGraph = this.getModuleGraph(module);

    if (moduleGraph.instances.has(target)) {
      return moduleGraph.instances.get(target);
    }

    if (moduleGraph.factories.has(target) && moduleGraph.factories.get(target)) {
      return moduleGraph.factories.get(target)!();
    }

    return this.resolveViaMetadata(target, module);
  }
}
