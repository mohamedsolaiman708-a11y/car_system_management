import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../investor_controller.dart';
import '../widgets/create_investor_dialog.dart';

class InvestorsScreen extends ConsumerWidget {
  const InvestorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستثمرين'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المستثمرون النشطون'),
              Tab(text: 'طلبات الانضمام'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(investorListControllerProvider);
                ref.invalidate(pendingInvestorsControllerProvider);
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            ActiveInvestorsList(),
            PendingInvestorsList(),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
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
            decoration: const InputDecoration(
              labelText: 'سبب الرفض',
              hintText: 'اكتب سبب الرفض هنا ليظهر للمستثمر...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
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
