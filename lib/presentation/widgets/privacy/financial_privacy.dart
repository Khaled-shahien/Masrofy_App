import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/settings/app_settings_cubit.dart';

bool financialAmountsObscured(BuildContext context) {
  try {
    context.read<AppSettingsCubit>();
  } on Object {
    return false;
  }
  return context.select<AppSettingsCubit, bool>(
    (cubit) => cubit.state.shouldMaskFinancialAmounts,
  );
}
