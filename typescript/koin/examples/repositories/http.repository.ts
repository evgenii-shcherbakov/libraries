import { inject, Single } from '../../src';
import { UserService } from '../services/user.service';

@Single()
export class HttpRepository {
  constructor(private readonly userService: UserService) {
    console.log('hello http', this.userService.getUsername());
  }
}
