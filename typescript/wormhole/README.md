# Wormhole
TypeScript library for handle backend state between middlewares in Express / Express-based frameworks using Request object

# Installation

```shell
npm install @iipekolict/wormhole
```

# Usage

Configuring dynamic wormhole based on initial state object (highly recommended)

```typescript
import { WormholeBuilder, DynamicWormholeClass } from '@iipekolict/wormhole';

type State = {
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
const Wormhole: DynamicWormholeClass<State> = WormholeBuilder.create(state);
```

Then use it inside middlewares and endpoints for set / get state fields

```typescript
import { WormholeBuilder, DynamicWormhole, DynamicWormholeClass } from '@iipekolict/wormhole';
import express, { Request, Response, NextFunction } from 'express';
import { fetchTodos } from 'project'

// ...previous example

const app = express();

app.use(async (request: Request, response: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = new Wormhole(request);
  const todos: object[] = await fetchTodos();
  
  wormhole.set({ todos }); // set todos field in backend state
  wormhole.setTodos(todos); // same as previous, method generates dynamically based on initial state object
  next();
});

app.use(async (request: Request, response: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = new Wormhole(request);
  
  console.log(wormhole.get('todos')); // [...todos]
  console.log(wormhole.getTodos()); // [...todos]
  console.log(wormhole.get('posts')); // []
  console.log(wormhole.getPosts()); // []
  
  next();
});

app.get('/', async (request: Request, response: Response, next: NextFunction) => {
  // wormhole factory, same as new Wormhole()
  const wormhole: DynamicWormhole<State> = WormholeBuilder.getInstance<State>(request);
  
  console.log(wormhole.get('missing')); // undefined
  
  response.json({ todos: wormhole.getTodos() });
});

app.listen(5000);
```

Creating custom setter

```typescript
const wormhole: DynamicWormhole<State> = new Wormhole(request);

const setter = wormhole.createSetter((state: State, todo: object) => {
  return { todos: [...state.todos, todo] };
});

setter({ text: 'some text' });
```

Creating custom spread setter

```typescript
const wormhole: DynamicWormhole<State> = new Wormhole(request);

const spreadSetter = wormhole.createSpreadSetter((state: State, ...posts: Post[]) => {
  return { posts: [...state.posts, ...posts] };
});

spreadSetter({ text: 'some text' }, { text: 'another text' });
```

# Examples

[Express](https://github.com/IIPEKOLICT/libraries/blob/main/typescript/wormhole/examples/express/index.ts)
