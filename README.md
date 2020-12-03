# 用最简单的方式处理下拉刷新和空白页面处理

## 如何使用

1. 设置``` tableView```或者``collectionView` `的delegate

   ```
   tableView.tdDelegate = self
   ```

2. 实现``` TDScrollviewDelegate```协议 如果需求只需要下拉刷新那么只需要实现``` tdClientBeginRefresh``` 如果只需要上拉加载更多那么只需要实现```tdClientLoadMoreRefresh ```

   ```swift
   extension HomeParttimeListView:TDScrollviewDelegate{
       func tdClientBeginRefresh() {
         page = 1
       }
       func tdClientLoadMoreRefresh() {
         page = page + 1
       }
   }
   ```

3. 刷新数据(无需关心此时是下拉刷新还是上拉加载更多 请直接调用 td_reload()方法)

   ```swift
    if page == 1 {
               dataSource = source
       }else{
               dataSource.append(contentsOf: source)
      }
   tableView.td_reload(source.count)
   ```

   

## 解释

1. ``` td_reload```这个方法传入一个count 如果 count=0 那么认为就没有下一页数据了,就会显示没有更多数据

2. 为什么没有使用gitHub上的 [UIScrollView+EmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet) ？因为这个库有bug，我改了下源码 所以如果你的工程里使用了 ``` DZNEmptyDataSet``` 你可以删除你工程的，使用我这里面的 完全兼容。
3. 为什么没有制作成pod集成？因为每家公司的下拉刷新显示的空白页面或者默认文案都不一样，你可以把这份代码放到你自己的工程里，根据你公司产品的要求 进行定制。

