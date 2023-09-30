import { ClassType } from './classes';

export type BindFunctionParams<Target> = {
  private?: boolean;
  as?: ClassType<Target>;
};
