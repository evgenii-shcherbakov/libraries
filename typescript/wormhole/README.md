# Wormhole
TypeScript library for handle backend state between middlewares in TypeScript frameworks

# Installation

```shell
npm install @evgenii-shcherbakov/wormhole
```

# Usage

Configure dynamic wormhole based on initial state object

```typescript
// project.ts

import { WormholeBuilder, DynamicWormholeFactory } from '@evgenii-shcherbakov/wormhole';

export type State = {
  todos: object[];
  posts: object[];
  missing?: boolean;
};

// initial state object
const state: State = {
  todos: [],
  posts: [],
};

// create dynamic wormhole class with utility methods based on initial state object
const Wormhole: DynamicWormholeFactory<State> = new WormholeBuilder(state).dynamic;
```

If you use Express, declare type top-level declarations for Request object

```typescript
// global.d.ts

import { StorageProvider } from '@evgenii-shcherbakov/wormhole';
import { State } from 'project';

declare global {
  namespace Express {
    interface Request extends StorageProvider<State> {}
  }
}

export {};
```

Then use it inside middlewares and endpoints for set / get state fields

```typescript
// project.ts

import { Wormhole, WormholeBuilder, DynamicWormhole, DynamicWormholeFactory } from '@evgenii-shcherbakov/wormhole';
import express, { Request, Response, NextFunction } from 'express';
import { fetchTodos } from 'any'

// ...previous example

const app = express();

app.use(async (request: Request, response: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(request);
  const todos: object[] = await fetchTodos();
  
  wormhole.set({ todos }); // set todos field in backend state
  wormhole.setTodos(todos); // same as previous, method generates dynamically based on initial state object
  next();
});

app.use(async (request: Request, response: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(request);
  
  console.log(wormhole.get('todos')); // [...todos]
  console.log(wormhole.getTodos()); // [...todos]
  console.log(wormhole.get('posts')); // []
  console.log(wormhole.getPosts()); // []
  
  next();
});

app.get('/', async (request: Request, response: Response, next: NextFunction) => {
  // static wormhole (without auto-generation of methods)
  const wormhole: Wormhole<State> = new WormholeBuilder(state).static(request);
  
  console.log(wormhole.get('missing')); // undefined
  
  response.json({ todos: wormhole.getTodos() });
});

app.listen(5000);
```

Creating custom setter

```typescript
const wormhole: DynamicWormhole<State> = Wormhole(request);

const setter = wormhole.createSetter((state: State, todo: object) => {
  return { todos: [...state.todos, todo] };
});

setter({ text: 'some text' });
```

Creating custom spread setter

```typescript
const wormhole: DynamicWormhole<State> = Wormhole(request);

const spreadSetter = wormhole.createSpreadSetter((state: State, ...posts: Post[]) => {
  return { posts: [...state.posts, ...posts] };
});

spreadSetter({ text: 'some text' }, { text: 'another text' });
```

# Examples

[Express](https://github.com/IIPEKOLICT/libraries/blob/main/typescript/wormhole/examples/express)
