import { ClassType } from './classes';

export type BindDecoratorParams = {
  private?: boolean;
  module?: string;
  as?: ClassType;
};

export type InjectDecoratorParams = {
  module?: string;
};
