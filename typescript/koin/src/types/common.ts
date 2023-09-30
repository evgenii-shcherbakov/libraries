import { Instance, InstanceFactory } from './classes';

export type ModuleInjectionGraph = {
  instances: Map<Function, Instance>;
  factories: Map<Function, InstanceFactory>;
};

export type RootInjectionGraph = Map<string, ModuleInjectionGraph>;

export type TargetDefinition<TargetType> = {
  isPrivate: boolean;
  target: TargetType;
};
