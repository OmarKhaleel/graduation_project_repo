import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palmear_application/data/services/provider_services/audio_device_provider.dart';
import 'package:palmear_application/data/services/provider_services/farm_provider.dart';
import 'package:palmear_application/data/services/provider_services/settings_provider.dart';
import 'package:palmear_application/data/services/provider_services/tree_provider.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/theme/app_theme.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

class MainWidgetsProvider extends StatelessWidget {
  final UserModel? currentUser;

  const MainWidgetsProvider({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioDeviceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => FarmProvider(currentUser?.uid ?? ''),
              child: Consumer<FarmProvider>(
                builder: (context, farmProvider, _) {
                  String farmId = farmProvider.farms.isNotEmpty
                      ? farmProvider.farms.first.uid
                      : "specificFarmId";
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (_) => TreeProvider(currentUser!.uid, farmId),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          child:
              currentUser == null ? const SignInScreen() : const MyHomePage(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
