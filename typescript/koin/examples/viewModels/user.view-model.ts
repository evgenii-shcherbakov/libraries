import { UserService } from '../services/user.service';
import { Factory, Inject } from '../../src';

@Factory()
export class UserViewModel {
  // constructor(private readonly userService: UserService) {}

  @Inject(UserService)
  private readonly userService: UserService;

  username = '';

  setUsername() {
    this.username = this.userService?.getUsername() ?? '';
  }
}
