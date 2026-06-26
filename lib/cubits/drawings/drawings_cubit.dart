import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/drawing.dart';
import '../../repositories/drawings_repository.dart';
import 'drawings_state.dart';

class DrawingsCubit extends Cubit<DrawingsState> {
  final DrawingsRepository _repo;

  DrawingsCubit({DrawingsRepository? repo})
      : _repo = repo ?? DrawingsRepository(),
        super(const DrawingsState(drawings: [], isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final drawings = await _repo.fetchAll();
      emit(state.copyWith(drawings: drawings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setSearch(String query) => emit(state.copyWith(searchQuery: query));

  Future<Drawing?> pickAndUpload({
    String customer = '',
    String rev = '',
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'dwg',
        'dxf',
        'step',
        'sldprt',
      ],
      withData: true,
    );
    if (result == null) return null;

    final file = result.files.first;
    final ext = file.extension ?? 'bin';

    emit(state.copyWith(isUploading: true, error: ''));
    try {
      final drawing = await _repo.upload(
        fileName: file.name,
        customer: customer,
        rev: rev,
        bytes: file.bytes!,
        fileType: ext,
      );
      emit(state.copyWith(
        drawings: [drawing, ...state.drawings],
        isUploading: false,
      ));
      return drawing;
    } catch (e) {
      emit(state.copyWith(isUploading: false, error: e.toString()));
      return null;
    }
  }

  Future<void> delete(Drawing drawing) async {
    try {
      await _repo.delete(drawing.id, drawing.storagePath);
      emit(state.copyWith(
        drawings: state.drawings.where((d) => d.id != drawing.id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Drawing? getById(String id) {
    try {
      return state.drawings.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
