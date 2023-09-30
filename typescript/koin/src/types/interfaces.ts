import { ClassType, Instance, InstanceFactory } from './classes';
import { BindFunctionParams } from './functions';
import { ModuleDefinition } from './api';

export interface IRootInjector {
  registerInstance(type: Function, instance: Instance, module?: string): void;
  registerFactory(type: Function, factory: InstanceFactory, module?: string): void;
  resolve<Target>(target: ClassType<Target>, module?: string): Target;
}

export interface IModuleInternal {
  single<Type = any>(
    input: Instance<Type> | InstanceFactory<Type>,
    params?: BindFunctionParams<Type>,
  ): IModule;

  factory<Type = any>(factory: InstanceFactory<Type>, params?: BindFunctionParams<Type>): IModule;
  includes(...modules: ModuleDefinition[]): IModule;
  get<Type = any>(target: ClassType<Type>, withPrivate: boolean): Type;
  getOrNull<Type = any>(target: ClassType<Type>, withPrivate: boolean): Type | null;
}

export interface IModule {
  single<Type = any>(input: Instance<Type> | InstanceFactory<Type>): IModule;
  factory<Type = any>(factory: InstanceFactory<Type>): IModule;
  includes(...modules: ModuleDefinition[]): IModule;
  get<Type = any>(target: ClassType<Type>): Type;
  getOrNull<Type = any>(target: ClassType<Type>): Type | null;
}
