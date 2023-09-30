import { IModule, IRootInjector } from './interfaces';

export type ModuleDefinition = (it: IModule) => IModule;
export type Module = (rootInjector: IRootInjector) => IModule;
