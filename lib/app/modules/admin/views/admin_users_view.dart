import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/themes/app_themes.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/utils/app_utils.dart';
import '../controllers/admin_controller.dart';

class AdminUsersView extends GetView<AdminController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      children: [
        // Search + filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: ext.surface,
          child: Column(
            children: [
              TextField(
                onChanged: (v) => controller.userSearch.value = v,
                style: TextStyle(color: ext.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: ext.textSecondary),
                  prefixIcon: Icon(Icons.search, color: ext.textSecondary),
                  filled: true,
                  fillColor: ext.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: ext.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['all', 'active', 'expired', 'free']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(f.isEmpty ? f : '${f[0].toUpperCase()}${f.substring(1)}'),
                                  selected: controller.userStatusFilter.value == f,
                                  onSelected: (_) {
                                    controller.userStatusFilter.value = f;
                                    controller.fetchUsers();
                                  },
                                  selectedColor: ext.primary.withOpacity(0.2),
                                  checkmarkColor: ext.primary,
                                ),
                              ))
                          .toList(),
                    ),
                  )),
            ],
          ),
        ),

        // Users list
        Expanded(
          child: Obx(() {
            if (controller.isLoadingUsers.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.users.isEmpty) {
              return Center(
                  child: Text('No users found',
                      style: TextStyle(color: ext.textSecondary)));
            }
            return RefreshIndicator(
              onRefresh: controller.fetchUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.users.length,
                itemBuilder: (_, i) =>
                    _UserRow(user: controller.users[i], ext: ext),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _UserRow extends GetView<AdminController> {
  final UserModel user;
  final AppColorExtension ext;

  const _UserRow({required this.user, required this.ext});

  @override
  Widget build(BuildContext context) {
    final sub = user.subscription;
    final hasActive = sub != null && !sub.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ext.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ext.primary.withOpacity(0.2),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: ext.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: TextStyle(
                            color: ext.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text(user.email,
                        style: TextStyle(
                            color: ext.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              _StatusBadge(
                label: hasActive ? 'Active' : sub != null ? 'Expired' : 'Free',
                color: hasActive
                    ? Colors.green
                    : sub != null
                        ? Colors.orange
                        : Colors.grey,
              ),
            ],
          ),

          if (sub != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: ext.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${DateHelper.formatDate(sub.expiryDate)}',
                  style: TextStyle(color: ext.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 12),
                if (!sub.isExpired)
                  Text(
                    '${sub.daysRemaining} days left',
                    style: TextStyle(
                      color: sub.isExpiringSoon
                          ? Colors.orange
                          : ext.textSecondary,
                      fontSize: 12,
                      fontWeight: sub.isExpiringSoon
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                label: 'Extend',
                icon: Icons.add_circle_outline,
                color: ext.primary,
                onTap: () => _showExtendDialog(context),
              ),
              _ActionButton(
                label: 'Deactivate',
                icon: Icons.block,
                color: Colors.orange,
                onTap: () => controller.deactivateUser(user),
              ),
              // Promote / Demote Admin
              if (!user.isAdmin)
                _ActionButton(
                  label: 'Make Admin',
                  icon: Icons.admin_panel_settings_outlined,
                  color: const Color(0xFF6C63FF),
                  onTap: () => _showPromoteDialog(context),
                )
              else
                _ActionButton(
                  label: 'Remove Admin',
                  icon: Icons.person_outlined,
                  color: Colors.deepOrange,
                  onTap: () => _showDemoteDialog(context),
                ),
              _ActionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(BuildContext context) {
    final days = 30.obs;
    Get.dialog(
      AlertDialog(
        title: const Text('Extend Subscription'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Extend for ${days.value} days'),
                Slider(
                  value: days.value.toDouble(),
                  min: 7,
                  max: 365,
                  divisions: 50,
                  onChanged: (v) => days.value = v.round(),
                ),
              ],
            )),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.extendUserSubscription(user, days.value);
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }

  void _showPromoteDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Row(children: [
        Icon(Icons.admin_panel_settings, color: Color(0xFF6C63FF)),
        SizedBox(width: 8),
        Text('Make Admin'),
      ]),
      content: Text(
          'Promote "${user.name}" to Admin?\nThey will have full access to the admin panel.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.promoteToAdmin(user);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white),
          child: const Text('Make Admin 👑'),
        ),
      ],
    ));
  }

  void _showDemoteDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Row(children: [
        Icon(Icons.person, color: Colors.deepOrange),
        SizedBox(width: 8),
        Text('Remove Admin'),
      ]),
      content: Text(
          'Remove admin role from "${user.name}"?\nThey will become a regular user.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.demoteFromAdmin(user);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white),
          child: const Text('Remove Admin'),
        ),
      ],
    ));
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Text('Delete User'),
      content: Text('Delete ${user.name}? This cannot be undone.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteUser(user);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
