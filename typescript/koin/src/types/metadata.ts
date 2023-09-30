import { ClassType } from './classes';

export type TargetMetadata = {
  isSingleton?: boolean;
  isPrivate?: boolean;
  moduleName?: string;
  binding?: ClassType;
};
