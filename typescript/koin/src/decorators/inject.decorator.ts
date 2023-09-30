import { ClassType } from '../types/classes';
import { _InjectionService } from '../services/injection.service';
import { InjectDecoratorParams } from '../types/decorators';

export function Inject(type: ClassType, params?: InjectDecoratorParams): PropertyDecorator {
  return (target: Object, propertyKey: string | symbol) => {
    // @ts-ignore
    target[propertyKey] = _InjectionService.getInjector().resolve(type, params?.module);
  };
}
