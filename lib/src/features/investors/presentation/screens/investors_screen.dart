import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(investorListControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: investorsAsync.when(
        data: (investors) => ListView.builder(
          itemCount: investors.length,
          itemBuilder: (context, index) {
            final investor = investors[index];
            return ListTile(
              title: Text(investor.fullName),
              subtitle: Text(investor.email),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Available: \$${investor.availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    'Deployed: \$${investor.deployedCapital.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
              onTap: () => context.go('/investors/${investor.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CreateInvestorDialog(),
        ),
        label: const Text('Add Investor'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
