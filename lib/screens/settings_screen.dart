import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';
import 'auth_entry_screen.dart';

/// Screen 6 of 6 — profile summary, relationship status, account
/// fields, and partner linking. Log Out actually signs out of Supabase.
/// Name comes from public.profiles, email from the Supabase auth user,
/// and the couple row (if any) from public.couples — including the
/// invite-code flow for actually creating that couple row.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _statusController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _joinCodeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCreatingInvite = false;
  bool _isJoining = false;
  String _displayName = '';
  String _originalStatus = '';
  String? _loadError;

  Map<String, dynamic>? _coupleRow; // null = not part of any couple yet
  String? _partnerName;
  DateTime? _pendingStartDate; // picked in the "create invite" dialog

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _statusController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is AuthException
        ? error.message
        : (error is PostgrestException ? error.message : error.toString());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool get _isLinked => _coupleRow != null && _coupleRow!['user2_id'] != null;
  bool get _isPendingInvite => _coupleRow != null && _coupleRow!['user2_id'] == null;

  Future<void> _loadProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      // Shouldn't normally happen (this screen only shows once logged
      // in), but bail out safely rather than querying with a null id.
      setState(() {
        _isLoading = false;
        _loadError = 'Not signed in.';
      });
      return;
    }

    _emailController.text = user.email ?? '';

    try {
      final profileRow = await client
          .from('profiles')
          .select('name, status')
          .eq('id', user.id)
          .maybeSingle();

      final coupleRow = await client
          .from('couples')
          .select('id, user1_id, user2_id, invite_code, relationship_start_date')
          .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
          .maybeSingle();

      String? partnerName;
      if (coupleRow != null) {
        final partnerId =
            coupleRow['user1_id'] == user.id ? coupleRow['user2_id'] as String? : coupleRow['user1_id'] as String;
        if (partnerId != null) {
          final partnerRow = await client
              .from('profiles')
              .select('name')
              .eq('id', partnerId)
              .maybeSingle();
          partnerName = partnerRow?['name'] as String?;
        }
      }

      if (!mounted) return;
      final status = (profileRow?['status'] as String?) ?? '';
      setState(() {
        _displayName = (profileRow?['name'] as String?)?.trim().isNotEmpty == true
            ? profileRow!['name'] as String
            : (user.email ?? 'You');
        _coupleRow = coupleRow;
        _partnerName = partnerName;
        _originalStatus = status;
        _statusController.text = status;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Couldn\'t load your profile.';
      });
      _showError(e);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String get _togetherSinceText {
    if (_isLinked) {
      final startDate = _coupleRow!['relationship_start_date'] as String?;
      final who = _partnerName ?? 'your partner';
      return startDate != null
          ? 'Together with $who since ${_formatDate(DateTime.parse(startDate))}'
          : 'Linked with $who';
    }
    if (_isPendingInvite) return 'Waiting for your partner to join';
    return 'Not linked with a partner yet';
  }

  Future<void> _pickStartDateThenCreateInvite() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'When did you two get together? (optional)',
    );
    // picked == null just means they skipped it — still create the
    // invite, just without a relationship_start_date yet.
    _pendingStartDate = picked;
    await _createInvite();
  }

  Future<void> _createInvite() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    setState(() => _isCreatingInvite = true);
    try {
      final row = await client
          .from('couples')
          .insert({
            'user1_id': uid,
            if (_pendingStartDate != null)
              'relationship_start_date': _pendingStartDate!.toIso8601String().split('T').first,
          })
          .select('id, user1_id, user2_id, invite_code, relationship_start_date')
          .single();
      if (!mounted) return;
      setState(() {
        _coupleRow = row;
        _partnerName = null;
      });
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isCreatingInvite = false);
    }
  }

  Future<void> _copyInviteCode() async {
    final code = _coupleRow?['invite_code'] as String?;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied.')),
    );
  }

  Future<void> _joinWithCode() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      final result = await Supabase.instance.client.rpc(
        'join_couple_by_code',
        params: {'p_invite_code': code},
      );
      final row = Map<String, dynamic>.from(result as Map);
      _joinCodeController.clear();
      // Re-run the full load so we also pick up the partner's name.
      await _loadProfile();
      if (!mounted) return;
      setState(() => _coupleRow = row);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You\'re linked!')),
      );
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _handleSaveAccount() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text;

    if (currentUser == null) return;

    final emailChanged = newEmail.isNotEmpty && newEmail != currentUser.email;
    final passwordChanged = newPassword.isNotEmpty;
    final newStatus = _statusController.text.trim();
    final statusChanged = newStatus != _originalStatus;

    if (!emailChanged && !passwordChanged && !statusChanged) return;

    setState(() => _isSaving = true);
    try {
      if (emailChanged || passwordChanged) {
        // Changing the email re-triggers Supabase's confirmation flow (a
        // confirmation link goes to the NEW address before it takes
        // effect) — same email-sending path as sign-up, so it's subject
        // to the same rate limit if hit repeatedly.
        await client.auth.updateUser(
          UserAttributes(
            email: emailChanged ? newEmail : null,
            password: passwordChanged ? newPassword : null,
          ),
        );
      }
      if (statusChanged) {
        await client.from('profiles').update({'status': newStatus}).eq('id', currentUser.id);
        _originalStatus = newStatus;
      }
      if (!mounted) return;
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailChanged
                ? 'Check your new email to confirm the change.'
                : (passwordChanged ? 'Password updated.' : 'Status updated.'),
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthEntryScreen()),
      (route) => false,
    );
  }

  Widget _buildPartnerSection(TextTheme textTheme) {
    if (_isLinked) {
      // Nothing more to do here — the avatar card up top already
      // shows the "Together with ... since ..." line.
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Partner', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          if (_isPendingInvite) ...[
            const Text('Share this code with your partner:'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgPeach,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _coupleRow!['invite_code'] as String? ?? '',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(letterSpacing: 4),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _copyInviteCode,
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Waiting for them to join...', style: textTheme.labelSmall),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            const Text("Not linked with a partner yet."),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _isCreatingInvite ? 'Creating...' : 'Create Invite Code',
              style: AppButtonStyle.secondary,
              onPressed: _isCreatingInvite ? null : _pickStartDateThenCreateInvite,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Shown either way while unlinked: if you created a code AND
          // your partner separately created their own, you still need a
          // way to paste theirs in rather than just wait on yours.
          Row(
            children: [
              Expanded(
                child: LabeledTextField(
                  label: 'Have a code?',
                  controller: _joinCodeController,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 90,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: Size.zero),
                  onPressed: _isJoining ? null : _joinWithCode,
                  child: Text(_isJoining ? '...' : 'Join'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: textTheme.headlineLarge),
            if (_loadError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_loadError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _togetherSinceText,
                          style: textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPartnerSection(textTheme),
            if (!_isLinked) const SizedBox(height: AppSpacing.lg),
            LabeledTextField(label: 'Status', controller: _statusController),
            const SizedBox(height: AppSpacing.xl),
            Text('Change Password / Email', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'New Password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: _isSaving ? 'Saving...' : 'Save Changes',
              style: AppButtonStyle.secondary,
              onPressed: _isSaving ? null : _handleSaveAccount,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Log Out', onPressed: _handleLogOut),
          ],
        ),
      ),
    );
  }
}
