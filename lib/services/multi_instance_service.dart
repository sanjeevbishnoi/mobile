import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';

class MultiInstanceService {
  List<ViewModel> _viewmodels = new List<ViewModel>();

  void addViewModel(ViewModel vm, String name) {
    _viewmodels.add(vm);
  }

  void remove(ViewModel vm) {
    vm.dispose();
    _viewmodels.remove(vm);
  }
}
