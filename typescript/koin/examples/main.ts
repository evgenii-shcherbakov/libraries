import { inject, module, startKoin, IModule, Inject } from '../src';
// import { UserService } from './user.service';
import { UserViewModel } from './viewModels/user.view-model';
import { HttpRepository } from './repositories/http.repository';
import { UserService } from './services/user.service';

startKoin(
  module((it: IModule) =>
    it
      .single(new UserService())
      .single(() => new UserService())
      .factory(() => new UserViewModel()),
  ),
);

function main() {
  const userViewModel = inject(UserViewModel);
  const httpRepository = inject(HttpRepository);

  userViewModel.setUsername();

  console.log(userViewModel.username);
}

main();
