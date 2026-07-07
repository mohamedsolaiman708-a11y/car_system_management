import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../investor_controller.dart';
import '../../../authentication/presentation/auth_controller.dart';

class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final investorAsync = ref.watch(investorDetailsControllerProvider(user.id));
    final transactionsAsync = ref.watch(investorTransactionsControllerProvider(user.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة استثماراتك'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: investorAsync.when(
          data: (investor) {
            if (investor == null) return const Center(child: Text('لم يتم العثور على بيانات المستثمر.'));
            
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(investorDetailsControllerProvider(user.id));
                ref.invalidate(investorTransactionsControllerProvider(user.id));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBalanceCard(investor),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'آخر العمليات المالية',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionsList(transactionsAsync),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(investor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text('إجمالي الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '${investor.availableBalance.toStringAsFixed(2)} ر.س',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('رأس المال المستثمر', investor.deployedCapital),
                _buildStatItem('إجمالي الأرباح', investor.totalProfitEarned),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} ر.س',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(transactionsAsync) {
    return transactionsAsync.when(
      data: (txs) {
        if (txs.isEmpty) return const Center(child: Text('لا توجد عمليات مسجلة.'));
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: txs.length,
          itemBuilder: (context, index) {
            final tx = txs[index];
            return Card(
              child: ListTile(
                title: Text(tx.type.label),
                subtitle: Text(tx.createdAt.toString().split(' ')[0]),
                trailing: Text(
                  '${tx.amount} ر.س',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tx.amount > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
