enum OrderBy { asc, desc }

class OrderParamsModel<T> {
  final T field;
  final OrderBy? order;

  OrderParamsModel({required this.field, this.order});
}
