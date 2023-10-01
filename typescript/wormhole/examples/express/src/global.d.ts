import { StorageProvider } from '../../../src';
import { State } from './index';

declare global {
  namespace Express {
    interface Request extends StorageProvider<State> {}
  }
}

export {};
