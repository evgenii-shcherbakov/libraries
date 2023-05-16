# Coroutine
TypeScript library for emulate multithreading. It uses Promise.all() as emulator and provides dynamic types return

# Installation

```shell
npm install @iipekolict/coroutine
```

# Usage

Parallel execution of few promises with different return types

```typescript
import { Coroutine } from '@iipekolict/coroutine';

const numberPromise: Promise<number> = Promise.resolve(42);
const stringPromies: Promise<string> = Promise.resolve('text');

const [numberValue, stringValue] = await Coroutine.launch(numberPromise, stringPromise);

console.log(numberValue); // 42
console.log(stringValue); // text

// Same as Coroutine.launch(), but with delay in 100ms between every thread
const [numberValueAsync, stringValueAsync] = await Coroutine.async(numberPromise, stringPromise);

// Same as Coroutine.launch(), but with custom delay in 42ms between every thread
const [numberValueCustomDelay, stringValueCustomDelay] = await Coroutine
  .withDelay(42)
  .launch(numberPromise, stringPromise);
```

Parallel execution of few promises with different return types (as a side effect)

```typescript
import { Coroutine } from '@iipekolict/coroutine';

const first: Promise<void> = async () => {};
const second: Promise<void> = async () => {};

await Coroutine.launch(first, second);
```

Parallel execution of few promises with different return types (get only need return values)

```typescript
import { Coroutine } from '@iipekolict/coroutine';

const first: Promise<number> = async () => Promise.resolve(42);
const second: Promise<void> = async () => {};

const [value] = await Coroutine.launch(first, second);

console.log(value); // 42
```

Parallel execution of same async callback on items array

```typescript
import { Coroutine, TAsyncMapCallback } from '@iipekolict/coroutine';

const items: string[] = ['bob', 'ivan', 'oleg'];

const callback: TAsyncMapCallback<string, number> = async (item: string, index: number, array: string[]) => {
  return Promise.resolve(array.length + index);
}

const results: number[] = await Coroutine.launchArr(items, callback);

console.log(results); // [3,4,5]

// Same as Coroutine.launchArr(), but with delay in 100ms between every thread
const resultsAsync: number[] = await Coroutine.asyncArr(items, callback);

// Same as Coroutine.launchArr(), but with delay in 42ms between every thread
const resultsAsyncCustomDelay: number[] = await Coroutine.asyncArr(items, callback, 42);

// Same as previous, but with builder-pattern syntax
const resultsAsyncCustomDelaySecond: number[] = await Coroutine.withDelay(42).launchArr(items, callback);
```

Parallel execution of same async callback on items array with split into fixed chunks (for cases with many array items)

```typescript
import { Coroutine, TAsyncMapCallback } from '@iipekolict/coroutine';

const items: string[] = new Array(1000).fill(Date.now());

const callback: TAsyncMapCallback<string, string> = async (item: string, index: number, array: string[]) => {
  return Promise.resolve(item + array.length + index);
}

// split base arr into chunks with 100 items and execute them one by one
const resultsBy100: string[] = await Coroutine.experimental(items, callback);

// split base arr into chunks with 420 items and execute them one by one
const resultsBy420: string[] = await Coroutine.experimental(items, callback, 420);
```
