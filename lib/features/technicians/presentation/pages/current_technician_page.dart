import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/current_technician_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentTechnicianPage extends StatelessWidget {
  const CurrentTechnicianPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = getIt<CurrentTechnicianCubit>();
      unawaited(cubit.load());
      return cubit;
    },
    child: const _CurrentTechnicianView(),
  );
}

class _CurrentTechnicianView extends StatelessWidget {
  const _CurrentTechnicianView();
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CurrentTechnicianCubit, CurrentTechnicianState>(
        listener: (context, state) {
          if (state.status == CurrentTechnicianStatus.failure &&
              state.technician != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        builder: (context, state) {
          if (state.technician == null &&
              (state.status == CurrentTechnicianStatus.initial ||
                  state.status == CurrentTechnicianStatus.loading)) {
            return const LoadingView(label: 'Loading your technician profile');
          }
          if (state.technician == null &&
              state.status == CurrentTechnicianStatus.failure) {
            return ErrorView(
              message: state.failure!.message,
              onRetry: context.read<CurrentTechnicianCubit>().load,
            );
          }
          return RefreshIndicator(
            onRefresh: context.read<CurrentTechnicianCubit>().load,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'My Technician Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _profile(
                      context,
                      state.technician!,
                      state.status == CurrentTechnicianStatus.submitting,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _profile(
    BuildContext context,
    Technician technician,
    bool submitting,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            technician.user.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(technician.user.email),
          const Divider(height: 32),
          Text('Phone: ${technician.phone}'),
          const SizedBox(height: 8),
          Text(
            'Experience: ${technician.experienceYears} ${technician.experienceYears == 1 ? 'year' : 'years'}',
          ),
          const SizedBox(height: 12),
          Text(
            'Skills: ${technician.skills.isEmpty ? 'None assigned' : technician.skills.map((skill) => skill.category.name).join(', ')}',
          ),
          const SizedBox(height: 12),
          Text('Profile: ${technician.isActive ? 'Active' : 'Inactive'}'),
          const Divider(height: 32),
          SwitchListTile(
            key: const Key('ownAvailabilitySwitch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Available for assignment'),
            subtitle: const Text(
              'Turn this off when you cannot accept new work.',
            ),
            value: technician.isAvailable,
            onChanged: submitting
                ? null
                : (value) => unawaited(
                    context.read<CurrentTechnicianCubit>().setAvailability(
                      value,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
