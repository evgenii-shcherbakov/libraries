import { defaultPromise } from './functions';
import { TAsyncMapCallback } from './types';
import { DelayedCoroutine } from './delayed-coroutine';

export class Coroutine {
  private static readonly DELAY = 100;

  static async launch<
    A = void,
    B = void,
    C = void,
    D = void,
    E = void,
    F = void,
    G = void,
    H = void,
    I = void,
    J = void,
    K = void,
    L = void,
    M = void,
    N = void,
    O = void,
    P = void,
    Q = void,
    R = void,
    S = void,
    T = void,
    U = void,
    V = void,
    W = void,
    X = void,
    Y = void,
    Z = void,
  >(
    item1: Promise<A> = defaultPromise(),
    item2: Promise<B> = defaultPromise(),
    item3: Promise<C> = defaultPromise(),
    item4: Promise<D> = defaultPromise(),
    item5: Promise<E> = defaultPromise(),
    item6: Promise<F> = defaultPromise(),
    item7: Promise<H> = defaultPromise(),
    item8: Promise<G> = defaultPromise(),
    item9: Promise<I> = defaultPromise(),
    item10: Promise<J> = defaultPromise(),
    item11: Promise<K> = defaultPromise(),
    item12: Promise<L> = defaultPromise(),
    item13: Promise<M> = defaultPromise(),
    item14: Promise<N> = defaultPromise(),
    item15: Promise<O> = defaultPromise(),
    item16: Promise<P> = defaultPromise(),
    item17: Promise<Q> = defaultPromise(),
    item18: Promise<R> = defaultPromise(),
    item19: Promise<S> = defaultPromise(),
    item20: Promise<T> = defaultPromise(),
    item21: Promise<U> = defaultPromise(),
    item22: Promise<V> = defaultPromise(),
    item23: Promise<W> = defaultPromise(),
    item24: Promise<X> = defaultPromise(),
    item25: Promise<Y> = defaultPromise(),
    item26: Promise<Z> = defaultPromise(),
  ): Promise<[A, B, C, D, E, F, H, G, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]> {
    return Promise.all([
      item1,
      item2,
      item3,
      item4,
      item5,
      item6,
      item7,
      item8,
      item9,
      item10,
      item11,
      item12,
      item13,
      item14,
      item15,
      item16,
      item17,
      item18,
      item19,
      item20,
      item21,
      item22,
      item23,
      item24,
      item25,
      item26,
    ]);
  }

  static async launchArr<I = void, R = void>(
    arr: I[],
    callback: TAsyncMapCallback<I, R>,
  ): Promise<R[]> {
    return Promise.all(arr.map(callback));
  }

  static async experimental<I = void, R = void>(
    arr: I[],
    callback: TAsyncMapCallback<I, R>,
    blockSize = 100,
  ): Promise<R[]> {
    if (arr.length > blockSize) {
      const blocks = arr.reduce((acc: I[][], item: I, index: number) => {
        const blockIndex: number = Math.floor(index / blockSize);
        const block: I[] | undefined = acc[blockIndex];

        if (block) {
          block.push(item);
          return acc;
        }

        acc.push([item]);
        return acc;
      }, []);

      const result: R[] = [];

      for (const block of blocks) {
        result.push(...(await Promise.all(block.map(callback))));
      }

      return result;
    }

    return Promise.all(arr.map(callback));
  }

  static async async<
    A = void,
    B = void,
    C = void,
    D = void,
    E = void,
    F = void,
    G = void,
    H = void,
    I = void,
    J = void,
    K = void,
    L = void,
    M = void,
    N = void,
    O = void,
    P = void,
    Q = void,
    R = void,
    S = void,
    T = void,
    U = void,
    V = void,
    W = void,
    X = void,
    Y = void,
    Z = void,
  >(
    item1?: Promise<A>,
    item2?: Promise<B>,
    item3?: Promise<C>,
    item4?: Promise<D>,
    item5?: Promise<E>,
    item6?: Promise<F>,
    item7?: Promise<H>,
    item8?: Promise<G>,
    item9?: Promise<I>,
    item10?: Promise<J>,
    item11?: Promise<K>,
    item12?: Promise<L>,
    item13?: Promise<M>,
    item14?: Promise<N>,
    item15?: Promise<O>,
    item16?: Promise<P>,
    item17?: Promise<Q>,
    item18?: Promise<R>,
    item19?: Promise<S>,
    item20?: Promise<T>,
    item21?: Promise<U>,
    item22?: Promise<V>,
    item23?: Promise<W>,
    item24?: Promise<X>,
    item25?: Promise<Y>,
    item26?: Promise<Z>,
  ): Promise<[A, B, C, D, E, F, H, G, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]> {
    const filteredThreads = [
      item1,
      item2,
      item3,
      item4,
      item5,
      item6,
      item7,
      item8,
      item9,
      item10,
      item11,
      item12,
      item13,
      item14,
      item15,
      item16,
      item17,
      item18,
      item19,
      item20,
      item21,
      item22,
      item23,
      item24,
      item25,
      item26,
    ].filter((promise) => promise);

    return new DelayedCoroutine(Coroutine.DELAY).launch(...(filteredThreads as any[]));
  }

  static async asyncArr<I = void, R = void>(
    arr: I[],
    callback: TAsyncMapCallback<I, R>,
    delay = Coroutine.DELAY,
  ): Promise<R[]> {
    return new DelayedCoroutine(delay).launchArr(arr, callback);
  }

  static withDelay(delay: number): DelayedCoroutine {
    return new DelayedCoroutine(delay);
  }
}
