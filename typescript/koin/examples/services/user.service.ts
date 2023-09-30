import { Single } from '../../src';

@Single()
export class UserService {
  counter = 42;

  getUsername() {
    return 'steve';
  }
}
