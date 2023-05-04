export type TAsyncMapCallback<Item, Result> = (
  item: Item,
  index: number,
  array: Item[],
) => Promise<Result>;
