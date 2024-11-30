abstract class PairFailure{}


class ServerFailure extends PairFailure{
  final String message;

  ServerFailure({required this.message});
}


class PairFullFailure extends PairFailure{
  final String message;

  PairFullFailure({required this.message});
}

class PairNotFoundFailure extends PairFailure{
  final String message;

  PairNotFoundFailure({required this.message});
}