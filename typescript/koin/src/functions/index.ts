import { ModuleDefinition, Module } from '../types/api';
import { _InjectionService } from '../services/injection.service';
import { IModule, IRootInjector } from '../types/interfaces';
import { ClassType } from '../types/classes';
import { _Module } from '../entities/module';

export const inject = <Type>(target: ClassType<Type>, module?: string): Type => {
  return _InjectionService.getInjector().resolve(target, module);
};

export const module = (
  moduleDefinition: ModuleDefinition = (it: IModule) => it,
  name?: string,
): Module => {
  return (rootInjector: IRootInjector) => moduleDefinition(_Module.new(rootInjector, name));
};

export const startKoin = (...modules: Module[]) => {
  _InjectionService.init();
  const rootInjector: IRootInjector = _InjectionService.getInjector();
  modules.forEach((module: Module) => module(rootInjector));
};
