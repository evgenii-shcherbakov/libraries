import { IModule, IModuleInternal, IRootInjector } from '../types/interfaces';
import { ClassType, Instance, InstanceFactory } from '../types/classes';
import { DEFAULT_MODULE_NAME } from '../constants/common';
import { MetadataKey } from '../constants/enums';
import { TargetMetadata } from '../types/metadata';
import { ModuleDefinition } from '../types/api';
import { BindFunctionParams } from '../types/functions';
import { TargetDefinition } from '../types/common';

export class _Module implements IModule, IModuleInternal {
  private readonly instances: Map<Function, TargetDefinition<Instance>> = new Map();
  private readonly factories: Map<Function, TargetDefinition<InstanceFactory>> = new Map();
  private readonly modules: (typeof this)[] = [];

  private constructor(
    // private readonly rootInjector: IRootInjector,
    private readonly name: string = DEFAULT_MODULE_NAME,
  ) {}

  static new(name?: string): IModule {
    return new this(name);
  }

  single<Type = any>(
    input: Instance<Type> | InstanceFactory<Type>,
    params?: BindFunctionParams<Type>,
  ): IModule {
    const instance: Instance<Type> = typeof input === 'function' ? input() : input;
    const classType = params?.as ?? instance['constructor'];
    this.instances.set(classType, { target: instance, isPrivate: !!params?.private });
    // this.rootInjector.registerInstance(classType, instance, this.name);
    return this;
  }

  factory<Type = any>(factory: InstanceFactory<Type>, params?: BindFunctionParams<Type>): IModule {
    const instance: Instance<Type> = factory();
    const classType = params?.as ?? instance['constructor'];
    this.factories.set(classType, { target: factory, isPrivate: !!params?.private });
    // this.rootInjector.registerFactory(classType, factory, this.name);
    return this;
  }

  includes(...modules: ModuleDefinition[]): IModule {
    this.modules.push(
      ...modules.map((module: ModuleDefinition) => module(_Module.new()) as typeof this),
    );

    return this;
  }

  private getViaInnerModules<Target>(target: ClassType<Target>): Target {
    const innerTarget: Target | null = this.modules.reduce(
      (acc: Target | null, innerModule: typeof this) => {
        return acc ?? innerModule.getOrNull<Target>(target, false);
      },
      null,
    );

    if (!innerTarget) {
      throw new Error(`Instance of type ${target.name} is not registered yet`);
    }

    return innerTarget;
  }

  private getViaMetadata<Target>(target: ClassType<Target>, withPrivate: boolean): Target {
    if (!Reflect.hasMetadata(MetadataKey.TARGET_DATA, target)) {
      return this.getViaInnerModules(target);
    }

    const metadata: TargetMetadata = Reflect.getMetadata(MetadataKey.TARGET_DATA, target);
    const paramTypes = Reflect.getMetadata('design:paramtypes', target) || [];

    const params = paramTypes.map((paramType: ClassType<Target>) => {
      return this.get(paramType, withPrivate);
    });

    const type: ClassType = metadata?.binding ?? target;

    if (metadata.isSingleton) {
      const instance: Instance<Target> = new target(...params);
      this.instances.set(type, { target: instance, isPrivate: metadata?.isPrivate });
      return instance;
    }

    const factory: InstanceFactory<Target> = () => new target(...params);
    this.factories.set(type, { target: factory, isPrivate: metadata?.isPrivate });
    return factory();
  }

  private getFromInstancesOrNull<Type = any>(
    target: ClassType<Type>,
    withPrivate: boolean,
  ): Instance<Type> | null {
    const definition: TargetDefinition<Instance<Type>> = this.instances.get(target);
    if (!withPrivate && definition.isPrivate) return null;
    return definition.target;
  }

  private getFromFactoriesOrNull<Type = any>(
    target: ClassType<Type>,
    withPrivate: boolean,
  ): Instance<Type> | null {
    const definition: TargetDefinition<InstanceFactory<Type>> = this.factories.get(target);
    if ((!withPrivate && definition.isPrivate) || definition.target) return null;
    return definition.target();
  }

  get<Type = any>(target: ClassType<Type>, withPrivate = true): Type {
    const hasInstance: boolean = this.instances.has(target);
    const hasFactory: boolean = this.factories.has(target);

    const instance: Instance<Type> | null = hasInstance
      ? this.getFromInstancesOrNull(target, withPrivate)
      : null;

    const factory: Instance<Type> | null = hasFactory
      ? this.getFromFactoriesOrNull(target, withPrivate)
      : null;

    return instance ?? factory ?? this.getViaMetadata(target, withPrivate);

    // return this.rootInjector.resolve(target, this.name);
  }

  getOrNull<Type = any>(target: ClassType<Type>, withPrivate = true): Type | null {
    try {
      return this.get(target, withPrivate);
    } catch (error) {
      return null;
    }
  }
}
