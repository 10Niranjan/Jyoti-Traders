import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../notifications/controllers/broadcast_ingestion_controller.dart';

class SendBroadcastScreen extends ConsumerStatefulWidget {
  const SendBroadcastScreen({super.key});

  @override
  ConsumerState<SendBroadcastScreen> createState() => _SendBroadcastScreenState();
}

class _SendBroadcastScreenState extends ConsumerState<SendBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    await ref.read(broadcastRepositoryProvider).send(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSending = false);
    _titleController.clear();
    _bodyController.clear();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.broadcastSentConfirmation)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final broadcastsAsync = ref.watch(broadcastsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.broadcastTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.broadcastTitleFieldLabel),
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.broadcastTitleFieldLabel : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(labelText: l10n.broadcastBodyFieldLabel),
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.broadcastBodyFieldLabel : null,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.broadcastSendButton,
                    icon: Icons.campaign_outlined,
                    isLoading: _isSending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.broadcastTitle, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: broadcastsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('$e'),
                data: (broadcasts) => broadcasts.isEmpty
                    ? EmptyStateWidget(icon: Icons.campaign_outlined, title: l10n.broadcastHistoryEmpty)
                    : ListView.separated(
                        itemCount: broadcasts.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final b = broadcasts[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(b.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                            subtitle: Text(b.body),
                            trailing: Text(
                              formatOrderDate(b.sentAt),
                              style: GoogleFonts.inter(fontSize: 11),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
