import 'reflect-metadata';
import { IModule, IRootInjector } from './types/interfaces';
import { ModuleDefinition, Module } from './types/api';
import { Single, Factory, Inject } from './decorators';
import { inject, startKoin, module } from './functions';

export {
  IModule,
  IRootInjector,
  ModuleDefinition,
  Module,
  Factory,
  Single,
  Inject,
  inject,
  startKoin,
  module,
};
