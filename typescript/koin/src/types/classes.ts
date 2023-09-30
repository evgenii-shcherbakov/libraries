export type ClassType<Type = any> = new (...args: any[]) => Instance<Type>;
export type Instance<Type = any> = object & Type;
export type InstanceFactory<Type = any> = () => Instance<Type>;
