import 'reflect-metadata';
import { MetadataKey } from '../constants/enums';
import { TargetMetadata } from '../types/metadata';
import { BindDecoratorParams } from '../types/decorators';

export function Factory(params?: BindDecoratorParams): ClassDecorator {
  return function (target: Function) {
    const metadata: TargetMetadata = {
      isSingleton: false,
      isPrivate: !!params?.private,
      moduleName: params?.module,
      binding: params?.as,
    };

    Reflect.defineMetadata(MetadataKey.TARGET_DATA, metadata, target);
  };
}
