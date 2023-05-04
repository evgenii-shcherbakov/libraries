import { TAsyncMapCallback } from './types';
import { delay } from './functions';

export class DelayedCoroutine {
  constructor(private readonly delay: number) {}

  async launch<
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
    const delayValue: number = this.delay;
    // @ts-ignore
    const argumentsAmount: number = arguments.length;

    return Promise.all(
      [
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
      ].map(async (promise, index: number) => {
        // @ts-ignore
        if (argumentsAmount > index) {
          await delay(delayValue * index);
        }

        return promise;
      }) as [
        Promise<A>,
        Promise<B>,
        Promise<C>,
        Promise<D>,
        Promise<E>,
        Promise<F>,
        Promise<H>,
        Promise<G>,
        Promise<I>,
        Promise<J>,
        Promise<K>,
        Promise<L>,
        Promise<M>,
        Promise<N>,
        Promise<O>,
        Promise<P>,
        Promise<Q>,
        Promise<R>,
        Promise<S>,
        Promise<T>,
        Promise<U>,
        Promise<V>,
        Promise<W>,
        Promise<X>,
        Promise<Y>,
        Promise<Z>,
      ],
    );
  }

  async launchArr<I = void, R = void>(arr: I[], callback: TAsyncMapCallback<I, R>): Promise<R[]> {
    return Promise.all(
      arr.map(async (item: I, index: number, array: I[]): Promise<R> => {
        await delay(this.delay * index);
        return callback(item, index, array);
      }),
    );
  }
}
