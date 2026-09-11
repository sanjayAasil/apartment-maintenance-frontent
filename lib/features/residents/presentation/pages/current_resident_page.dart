import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/current_resident_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/widgets/resident_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentResidentPage extends StatelessWidget {
  const CurrentResidentPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<CurrentResidentBloc>()..add(const CurrentResidentRequested()),
    child: const _CurrentResidentView(),
  );
}

class _CurrentResidentView extends StatelessWidget {
  const _CurrentResidentView();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CurrentResidentBloc, CurrentResidentState>(
        builder: (context, state) {
          if (state.status == CurrentResidentStatus.initial ||
              state.status == CurrentResidentStatus.loading) {
            return const LoadingView(label: 'Loading your resident profile');
          }
          if (state.status == CurrentResidentStatus.failure) {
            return ErrorView(
              message: state.failure!.message,
              onRetry: () => context.read<CurrentResidentBloc>().add(
                const CurrentResidentRequested(),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'My apartment',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ResidentProfileCard(resident: state.resident!),
                ),
              ),
            ],
          );
        },
      );
}
