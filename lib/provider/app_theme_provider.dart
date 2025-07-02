import 'package:budgets/core/constants.dart';
import 'package:budgets/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appThemeProvider = StateProvider((ref) {
    return ThemeMode.system;
},);

final globalThemeProvider = StateProvider<Brightness>((ref) {
  String? storage = storageBox.get(LocalAppStorage.globalTheme);
  if(storage!=null){
    return storage=='light' ? Brightness.light : Brightness.dark;
  }else{

    ThemeMode mode = ref.watch(appThemeProvider);
 
    return mode==ThemeMode.dark ?  Brightness.dark: Brightness.light;
  }
  
},);