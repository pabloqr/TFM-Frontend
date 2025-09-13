import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failure.dart';
import 'package:frontend/data/repositories/courts_repository.dart';
import 'package:frontend/features/courts/data/models/court_model.dart';
import 'package:frontend/features/devices/data/models/device_model.dart';

class CourtsUseCases {
  final CourtsRepository _repository;

  CourtsUseCases({required CourtsRepository repository}) : _repository = repository;

  Future<Either<Failure, List<CourtModel>>> getCourts(int complexId, {Map<String, dynamic>? query}) async {
    return await _repository.getCourts(complexId, query: query);
  }

  Future<Either<Failure, CourtModel>> getCourt(int complexId, int courtId) async {
    return await _repository.getCourt(complexId, courtId);
  }

  Future<Either<Failure, List<DeviceModel>>> getCourtDevices(int complexId, int courtId) async {
    return await _repository.getCourtDevices(complexId, courtId);
  }
}
