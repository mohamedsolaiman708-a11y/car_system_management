import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/investor_transaction_type.dart';

class InvestorDetailsScreen extends ConsumerWidget {
  final String id;
  const InvestorDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailsControllerProvider(id));
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(investorDetailsControllerProvider(id).notifier).refresh();
            },
          ),
        ],
      ),
      body: investorAsync.when(
        data: (investor) {
          if (investor == null) return const Center(child: Text('Investor not found'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, investor),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Financial Statement',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A192F),
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.deposit),
                          icon: const Icon(Icons.add),
                          label: const Text('Deposit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showTransactionDialog(context, investor.id, InvestorTransactionType.withdrawal),
                          icon: const Icon(Icons.remove),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTransactionsList(context, transactionsAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, investor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF0A192F),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investor.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(investor.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 40),
            Row(
              children: [
                _buildBalanceItem(context, 'Available Balance', investor.availableBalance, Colors.green),
                const SizedBox(width: 48),
                _buildBalanceItem(context, 'Deployed Capital', investor.deployedCapital, Colors.blue),
                const SizedBox(width: 48),
                _buildBalanceItem(context, 'Total Balance', investor.availableBalance + investor.deployedCapital, const Color(0xFF0A192F)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context, transactionsAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No transactions recorded yet.'),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isPositive = tx.type == InvestorTransactionType.deposit || 
                                 tx.type == InvestorTransactionType.contractReturn ||
                                 tx.type == InvestorTransactionType.financeProfitDistribution;
              
              return ListTile(
                leading: Icon(
                  isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                title: Text(tx.type.label),
                subtitle: Text('${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} - ${tx.description ?? ""}'),
                trailing: Text(
                  '${isPositive ? "+" : "-"}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error loading transactions: $err'),
    );
  }

  void _showTransactionDialog(BuildContext context, String investorId, InvestorTransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(investorId: investorId, type: type),
    );
  }
}
