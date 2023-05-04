export function defaultPromise<T>(): Promise<T> {
  return (async () => Promise.resolve())() as unknown as Promise<T>;
}

export function delay(duration: number): Promise<unknown> {
  return new Promise((resolve) => setTimeout(resolve, duration));
}
