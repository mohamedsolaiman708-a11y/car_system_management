import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3, // زيادة عدد التبويبات لـ 3
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستثمرين'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المستثمرون النشطون'),
              Tab(text: 'طلبات الانضمام'),
              Tab(text: 'طلبات السحب'), // التبويب الجديد
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(investorListControllerProvider);
                ref.invalidate(pendingInvestorsControllerProvider);
                ref.invalidate(withdrawalRequestsControllerProvider());
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            ActiveInvestorsList(),
            PendingInvestorsList(),
            WithdrawalRequestsList(), // القائمة الجديدة
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const CreateInvestorDialog(),
          ),
          label: const Text('إضافة مستثمر'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ActiveInvestorsList extends ConsumerWidget {
  const ActiveInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorsAsync = ref.watch(investorListControllerProvider);

    return investorsAsync.when(
      data: (investors) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: investors.length,
        itemBuilder: (context, index) {
          final investor = investors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person),
            ),
            title: Text(investor.fullName),
            subtitle: Text(investor.email),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'المتاح: ${investor.availableBalance.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  'المستثمر: ${investor.deployedCapital.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
            onTap: () => context.push('/investors/${investor.id}'),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ في تحميل المستثمرين: $err')),
    );
  }
}

class PendingInvestorsList extends ConsumerWidget {
  const PendingInvestorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingInvestorsControllerProvider);

    return pendingAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد طلبات انضمام معلقة حالياً', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(request['full_name'] ?? 'بدون اسم'),
                subtitle: Text(request['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => ref.read(pendingInvestorsControllerProvider.notifier).approveInvestor(request['id']),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('تفعيل'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showRejectDialog(context, ref, request['id']),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('رفض'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('خطأ في تحميل الطلبات: $err')),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String profileId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب الانضمام'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'سبب الرفض', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref.read(pendingInvestorsControllerProvider.notifier).rejectInvestor(profileId, controller.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      ),
    );
  }
}

class WithdrawalRequestsList extends ConsumerWidget {
  const WithdrawalRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(withdrawalRequestsControllerProvider(status: 'pending'));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(child: Text('لا توجد طلبات سحب معلقة'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final investor = req['investors'];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.money_off, color: Colors.red)),
                title: Text(investor['full_name'] ?? 'مستثمر'),
                subtitle: Text('المبلغ: ${req['amount']} ر.س\n${req['bank_account_details'] ?? ""}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => ref.read(withdrawalRequestsControllerProvider().notifier).approveRequest(req['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _showRejectWithdrawalDialog(context, ref, req['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    );
  }

  void _showRejectWithdrawalDialog(BuildContext context, WidgetRef ref, String requestId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض طلب السحب'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'سبب الرفض'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                ref.read(withdrawalRequestsControllerProvider().notifier).rejectRequest(requestId, controller.text);
                Navigator.pop(context);
              },
              child: const Text('رفض الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
