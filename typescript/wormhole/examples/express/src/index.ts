import { Express, Request, Response, NextFunction } from 'express';
import { AxiosInstance } from 'axios';
import express from 'express';
import axios from 'axios';
import { DynamicWormhole, DynamicWormholeFactory, WormholeBuilder } from '../../../src';

type Todo = {
  userId: number;
  id: number;
  title: string;
  completed: boolean;
};

type Post = {
  id: number;
  userId: string;
  title: string;
  body: string;
};

export type State = {
  todos: Todo[];
  posts: Post[];
  isPostsSame?: boolean;
  isTodosSame?: boolean;
};

const state: State = {
  todos: [],
  posts: [],
};

const httpClient: AxiosInstance = axios.create({ baseURL: 'https://jsonplaceholder.typicode.com' });
const app: Express = express();
const Wormhole: DynamicWormholeFactory<State> = new WormholeBuilder(state).dynamic;

const getFirstTodo = async (): Promise<Todo> => {
  return (await httpClient.get<Todo>('todos/1')).data;
};

const getTodos = async (): Promise<Todo[]> => {
  return (await httpClient.get<Todo[]>('todos')).data;
};

const getPosts = async (): Promise<Post[]> => {
  return (await httpClient.get<Post[]>('posts')).data;
};

const loadPostsMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(req);
  const posts: Post[] = await getPosts();

  wormhole.setPosts(posts);
  next();
};

const loadTodosMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(req);
  const todos: Todo[] = await getTodos();

  wormhole.setTodos(todos);
  next();
};

const customSettersMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(req);
  const todo: Todo = await getFirstTodo();
  const posts: Post[] = await getPosts();

  const setter = wormhole.createSetter((state: State, todo: Todo) => {
    return { todos: [...state.todos, todo] };
  });

  const spreadSetter = wormhole.createSpreadSetter((state: State, ...posts: Post[]) => {
    return { posts: [...state.posts, ...posts] };
  });

  setter(todo);
  spreadSetter(posts[0], posts[1], posts[2]);
  next();
};

const checkStateMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  const wormhole: DynamicWormhole<State> = Wormhole(req);
  console.log('Get posts #1 method', `${wormhole.getPosts().length} items`);
  console.log('Get posts #2 method', `${wormhole.get('posts').length} items`);

  const isPostsSame: boolean = wormhole.getPosts() === wormhole.get('posts');

  console.log('Is result same?', isPostsSame);

  console.log('Get todos #1 method', `${wormhole.getTodos().length} items`);
  console.log('Get todos #2 method', `${wormhole.get('todos').length} items`);

  const isTodosSame: boolean = wormhole.getPosts() === wormhole.get('posts');

  console.log('Is result same?', isTodosSame);

  wormhole.set({ isPostsSame, isTodosSame });
  next();
};

const endpoint = async (req: Request, res: Response) => {
  const wormhole: DynamicWormhole<State> = Wormhole(req);

  res.json({
    todos: wormhole.getTodos(),
    posts: wormhole.getPosts(),
    isAllSame: wormhole.get('isTodosSame') && wormhole.get('isPostsSame'),
  });
};

app.use(checkStateMiddleware);

app.use(
  '/',
  loadPostsMiddleware,
  loadTodosMiddleware,
  customSettersMiddleware,
  checkStateMiddleware,
  endpoint,
);

app.listen(8000, () => console.log('Example wormhole/express started at 8000 port...'));
